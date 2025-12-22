# Flutter App Structure Documentation

## Overview
This Flutter application is a complete conversion of the PWA inventory management system. It maintains all the functionality while providing a native mobile experience.

## Key Features Implemented

### 1. Data Models
- **InventoryItem**: Manages product inventory with code, name, quantities, batches, roastery info, and notes
- **Order**: Handles order management with status tracking
- **Batch**: Manages expiry date tracking for inventory items

### 2. State Management
- Uses Provider pattern for reactive state management
- **InventoryProvider**: Manages all inventory-related operations
- **OrdersProvider**: Manages order operations for showroom and cafe

### 3. Local Storage
- **StorageService**: Uses SharedPreferences for offline-first data persistence
- Automatically saves data when changes occur
- Supports data import/export (to be implemented)

### 4. Screens

#### Home Screen (Dashboard)
- Displays statistics for inventory, expiry alerts, notes, and pending orders
- Quick navigation to all sections
- Data management buttons (import/export/clear)

#### Inventory Screen
- Real-time search by barcode or name
- Add/subtract quantities
- Item deletion
- Difference calculation (actual vs system)
- Split-pane layout with details on left and table on right

#### Expiry Screen
- Batch management with roast date and expiry tracking
- Visual status indicators (expired, near expiry, valid)
- Automatic date calculations
- Multiple batches per item support

#### Notes Screen
- Roastery name management
- Coffee tasting notes and descriptions
- Full-text search across all fields

#### Orders Screen
- Dual tabs for Showroom and Cafe orders
- Status tracking (pending/completed)
- Overdue warnings (>7 days)
- Full CRUD operations

### 5. UI Components
- **DashboardCard**: Reusable card with icon, count, and navigation
- **SearchField**: Customizable search input with RTL support
- **CustomButton**: Styled button matching the brand theme

## Technical Details

### Dependencies
- `provider`: State management
- `shared_preferences`: Local data persistence
- `intl`: Date formatting and localization
- `flutter_localizations`: Arabic RTL support
- `flutter_barcode_scanner`: Barcode scanning capability

### Theme
- Primary color: #1e1b4b (Brand Navy)
- Accent color: #f59e0b (Amber)
- Showroom color: #0f766e (Teal)
- Cafe color: #8c6b5d (Brown)
- RTL (Right-to-Left) layout support
- Material Design 3

### Data Structure
```json
{
  "inventory": [
    {
      "code": "string",
      "name": "string",
      "sysQty": "number",
      "actualQty": "number",
      "batches": [
        {
          "id": "number",
          "date": "string (ISO)",
          "qty": "number",
          "duration": "number (months)"
        }
      ],
      "roastery": "string",
      "notes": "string"
    }
  ],
  "orders": {
    "showroom": [],
    "cafe": []
  }
}
```

## Future Enhancements
1. Excel import/export functionality
2. Barcode scanner integration
3. Print functionality
4. Data backup to cloud
5. Multi-user support
6. Reports and analytics

## Development Notes

### Adding New Features
1. Create model in `models/` if needed
2. Add business logic to appropriate provider in `providers/`
3. Create or update screen in `screens/`
4. Update UI components in `widgets/` if needed

### Testing
- Run unit tests: `flutter test`
- Run integration tests: `flutter drive`
- Check for issues: `flutter analyze`

### Building
- Debug build: `flutter run`
- Release APK: `flutter build apk --release`
- Release App Bundle: `flutter build appbundle --release`

## Differences from PWA
1. **Navigation**: Uses Flutter navigation instead of view switching
2. **Storage**: Uses SharedPreferences instead of localStorage
3. **UI**: Native Material Design components instead of Tailwind CSS
4. **Fonts**: System fonts (Cairo can be added separately)
5. **Icons**: Material Icons instead of Font Awesome

## Migration Guide (PWA to Flutter)

### Data Migration
The data structure is compatible. To migrate from PWA:
1. Export data from PWA as JSON
2. Import to Flutter app using the storage service
3. Data keys remain the same for compatibility

### Feature Parity
All PWA features have been implemented:
- ✅ Dashboard with statistics
- ✅ Inventory management
- ✅ Expiry tracking
- ✅ Notes/coffee guide
- ✅ Order management (Showroom/Cafe)
- ✅ Search functionality
- ✅ Data persistence
- ⏳ Import/Export (UI ready, implementation pending)
- ⏳ Print functionality (UI ready)

## Troubleshooting

### Common Issues
1. **Build fails**: Run `flutter clean && flutter pub get`
2. **Hot reload not working**: Restart app completely
3. **State not updating**: Check Provider.of vs Consumer usage
4. **RTL issues**: Ensure locale is set to 'ar'

## Contact
Developer: Ahmad Altayeb
Phone: 0550360705
Version: 2.4
