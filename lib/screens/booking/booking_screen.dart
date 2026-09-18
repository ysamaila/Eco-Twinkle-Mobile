import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/services_catalog.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _step = 0;
  ServiceCategory? _category;
  String? _selectedItem;
  ServiceItem? _selectedService;
  PricingCategory? _selectedPricingCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _receiptFile;




  double get _basePrice =>
      _selectedPricingCategory?.price ?? (_selectedService?.price ?? 0);

  double get _totalPrice {
    final user = ref.read(authProvider).user;
    if (user != null &&
        user.hasLoyaltyDiscount &&
        _basePrice > 0) {
      return _basePrice * (1 - AppConstants.loyaltyDiscountRate);
    }
    return _basePrice;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.black,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.black,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _receiptFile = File(file.path));
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider).user;
    if (user == null ||
        _category == null ||
        _selectedItem == null ||
        _selectedService == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    await ref.read(ordersProvider.notifier).createOrder(
          userId: user.id,
          service: _selectedPricingCategory != null
              ? '${_selectedService!.name} (${_selectedPricingCategory!.category})'
              : _selectedService!.name,
          item: _selectedItem!,
          date: dateStr,
          time: timeStr,
          price: _totalPrice,
          receiptFile: _receiptFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    ref.listen(ordersProvider, (_, next) {
      if (next.submitSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking submitted successfully! 🌿'),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
        ref.read(ordersProvider.notifier).resetSubmit();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppConstants.dashboard);
        }
      } else if (next.submitError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.submitError!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppConstants.dashboard);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            _StepBar(currentStep: _step, totalSteps: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(user),
                ][_step],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(step: 1, title: 'Select Category'),
        const SizedBox(height: 20),
        ...serviceCatalog.map((cat) {
          final icons = {
            'Automotive': Icons.directions_car_rounded,
            'Facility': Icons.business_rounded,
            'Specialized': Icons.science_rounded,
          };
          final desc = {
            'Automotive': 'Vehicle cleaning & detailing',
            'Facility': 'Home, office & industrial cleaning',
            'Specialized': 'Solar & borehole solutions',
          };
          return GestureDetector(
            onTap: () => setState(() {
              _category = cat;
              _selectedItem = null;
              _selectedService = null;
              _step = 1;
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _category?.name == cat.name
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _category?.name == cat.name
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icons[cat.name] ?? Icons.category,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(desc[cat.name] ?? '',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2() {
    if (_category == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(step: 2, title: 'Select Details'),
        const SizedBox(height: 20),
        Text('Item Type',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _category!.items.map((item) {
            final sel = item == _selectedItem;
            return GestureDetector(
              onTap: () => setState(() => _selectedItem = item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                ),
                child: Text(item,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Service Package',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted)),
        const SizedBox(height: 10),
        ..._category!.services.map((svc) {
          final sel = svc.name == _selectedService?.name;
          return Column(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _selectedService = svc;
                  _selectedPricingCategory = null;
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(svc.name,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    sel ? FontWeight.w700 : FontWeight.w500)),
                      ),
                      Text(
                        svc.pricingString != null
                            ? svc.pricingString!
                            : svc.pricingCategories != null
                                ? 'Select Category'
                                : '₦${NumberFormat('#,##0').format(svc.price ?? 0)}${svc.unit != null ? " ${svc.unit}" : ""}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: sel
                                ? AppColors.primary
                                : AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              if (sel && svc.pricingCategories != null)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 0, bottom: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: svc.pricingCategories!.map((cat) {
                      final catSel =
                          _selectedPricingCategory?.category == cat.category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPricingCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: catSel
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: catSel
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            '${cat.category} (₦${NumberFormat('#,##0').format(cat.price)})',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    catSel ? FontWeight.w700 : FontWeight.w500,
                                color: catSel
                                    ? AppColors.primary
                                    : AppColors.textPrimary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _selectedItem != null &&
                  _selectedService != null &&
                  (_selectedService!.pricingCategories == null ||
                      _selectedPricingCategory != null)
              ? () => setState(() => _step = 2)
              : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildStep3(dynamic user) {
    final hasDiscount = user != null &&
        user.hasLoyaltyDiscount &&
        _basePrice > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(step: 3, title: 'Date, Time & Summary'),
        const SizedBox(height: 20),

        // Date picker
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                color: AppColors.primary, size: 20),
          ),
          title: const Text('Preferred Date',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          subtitle: Text(
            _selectedDate == null
                ? 'Select a date'
                : DateFormat('EEEE, dd MMM yyyy').format(_selectedDate!),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          onTap: _pickDate,
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ),
        const Divider(),

        // Time picker
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.access_time_rounded,
                color: AppColors.primary, size: 20),
          ),
          title: const Text('Preferred Time',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          subtitle: Text(
            _selectedTime == null
                ? 'Select a time'
                : _selectedTime!.format(context),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          onTap: _pickTime,
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ),
        const Divider(),

        // Receipt upload
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.attach_file_rounded,
                color: AppColors.primary, size: 20),
          ),
          title: const Text('Payment Receipt',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          subtitle: Text(
            _receiptFile == null
                ? 'Optional — Upload image'
                : _receiptFile!.path.split('/').last,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          onTap: _pickReceipt,
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ),
        const SizedBox(height: 24),

        // Price summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price Summary',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (_selectedService != null) ...[
                _PriceLine(
                    label: _selectedPricingCategory != null
                        ? '${_selectedService!.name} (${_selectedPricingCategory!.category})'
                        : _selectedService!.name,
                    value: _selectedService!.contactForQuote
                        ? 'TBD'
                        : '₦${NumberFormat('#,##0').format(_basePrice)}${_selectedService!.unit != null ? " ${_selectedService!.unit}" : ""}'),
                if (hasDiscount) ...[
                  const SizedBox(height: 8),
                  _PriceLine(
                      label: '🌟 Loyalty Discount (10%)',
                      value:
                          '-₦${NumberFormat('#,##0').format(_basePrice * AppConstants.loyaltyDiscountRate)}',
                      color: AppColors.gold),
                ],
                Divider(
                    color: AppColors.textSubtle.withValues(alpha: 0.3)),
                _PriceLine(
                  label: 'Estimated Total',
                  value: _selectedService!.contactForQuote
                      ? 'Contact for Quote'
                      : '₦${NumberFormat('#,##0').format(_totalPrice)}',
                  bold: true,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: (_selectedDate != null &&
                  _selectedTime != null &&
                  !ref.watch(ordersProvider).isSubmitting)
              ? _submit
              : null,
          child: ref.watch(ordersProvider).isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : const Text('Confirm Booking'),
        ),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(
          totalSteps * 2 - 1,
          (i) {
            if (i.isOdd) {
              return Expanded(
                child: Container(
                  height: 2,
                  color: i ~/ 2 < currentStep
                      ? AppColors.primary
                      : AppColors.surfaceLight,
                ),
              );
            }
            final step = i ~/ 2;
            final done = step < currentStep;
            final active = step == currentStep;
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || active
                    ? AppColors.primary
                    : AppColors.surfaceLight,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : Text(
                        '${step + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.black : AppColors.textMuted,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int step;
  final String title;
  const _StepHeader({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step $step of 3',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _PriceLine(
      {required this.label,
      required this.value,
      this.bold = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: bold ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.w400)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}
