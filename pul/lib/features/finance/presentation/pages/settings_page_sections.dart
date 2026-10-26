part of 'settings_page.dart';

extension on SettingsPage {
  Widget _buildSettingsList(BuildContext context, FinanceState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF43D79A), AppColors.greenDark],
                  ),
                  borderRadius: BorderRadius.circular(19),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PUL',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Şahsy pul dolandyryşy',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '1.0.0',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('GÖRNÜŞ'),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            value: state.isBalanceHidden,
            onChanged: (_) => context.read<FinanceBloc>().add(
              const BalanceVisibilityToggled(),
            ),
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD7DCE0),
            contentPadding: const EdgeInsets.fromLTRB(16, 3, 12, 3),
            secondary: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                state.isBalanceHidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.greenDark,
                size: 19,
              ),
            ),
            title: const Text(
              'Balansy gizle',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Mukdarlary başga kişilerden gizläň',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('KATEGORIÝALAR'),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (
                var index = 0;
                index < state.customCategories.length;
                index++
              ) ...[
                if (index > 0) const Divider(indent: 70, height: 1),
                _CustomCategoryTile(
                  category: state.customCategories[index],
                  onEdit: state.isSaving
                      ? null
                      : () => _editCustomCategory(
                          context,
                          state.customCategories[index],
                        ),
                  onDelete: state.isSaving
                      ? null
                      : () => _confirmDeleteCustomCategory(
                          context,
                          state.customCategories[index],
                        ),
                ),
              ],
              if (state.customCategories.isNotEmpty)
                const Divider(indent: 70, height: 1),
              ListTile(
                onTap: state.isSaving
                    ? null
                    : () => _editCustomCategory(context, null),
                leading: const _TileIcon(
                  icon: Icons.add_rounded,
                  background: AppColors.greenSoft,
                  foreground: AppColors.greenDark,
                ),
                title: const Text(
                  'Täze kategoriýa goş',
                  style: TextStyle(
                    color: AppColors.greenDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('MAGLUMATLAR'),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                onTap: state.isSaving
                    ? null
                    : () => _confirmClear(context),
                contentPadding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.coralSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.coralDark,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Ähli amallary öçür',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Girdejileriňiz we çykdajylaryňyz hemişelik ýok edilýär',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                trailing: state.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.green,
                        ),
                      )
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
              ),
              const Divider(indent: 70),
              const ListTile(
                contentPadding: EdgeInsets.fromLTRB(16, 3, 16, 3),
                leading: _LocalIcon(),
                title: Text(
                  'Ýerli saklaýyş',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Maglumatlar diňe şu enjamda saklanýar',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                trailing: Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.greenDark,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('ÄTIÝAÇLYK'),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                onTap: state.isSaving
                    ? null
                    : () => _exportBackup(
                        context,
                        state.transactions,
                        state.customCategories,
                      ),
                contentPadding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                leading: const _TileIcon(
                  icon: Icons.copy_all_outlined,
                  background: AppColors.greenSoft,
                  foreground: AppColors.greenDark,
                ),
                title: const Text(
                  'Çyktary klipboarda kopyala',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Amallar we kategoriýalar JSON görnüşinde ätiýaçlyk saklamak üçin',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
              const Divider(indent: 70),
              ListTile(
                onTap: state.isSaving
                    ? null
                    : () => _importBackup(context),
                contentPadding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                leading: const _TileIcon(
                  icon: Icons.content_paste_go_outlined,
                  background: Color(0xFFEAF2FD),
                  foreground: Color(0xFF3A6FA8),
                ),
                title: const Text(
                  'Klipboarddan getir',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Klipboarddaky ätiýaçlyk ähli amallaryňyzy çalyşýar',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.greenTint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDF3E8)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.greenDark,
                size: 19,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bu wersiýa üçin internet ýa-da daşarky hasap gerek däl. '
                  'Girdejileriňiz we çykdajylaryňyz telefonda ýerli ýagdaýda saklanýar.',
                  style: TextStyle(
                    color: Color(0xFF3E705D),
                    fontSize: 11.5,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
