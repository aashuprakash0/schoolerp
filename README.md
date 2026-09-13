# Adarsh Avasiya School - Fee Management ERP v5

Focused ERP for about 500 students. Admin-only, cash-only fee collection. Parents/students have no portal access.

## Features
- Admin authentication through Supabase Auth
- Student register with sibling/family grouping
- Hostel flag and vehicle flag + vehicle area/route
- Class-wise fee structure
- Hostel-only fee rules
- Vehicle charge rules by area/route
- Separate fee heads for tuition, examination, re-admission, Saraswati Puja, Independence Day, Republic Day, books, dress, ID card, tie + belt, etc.
- Student-specific custom charges
- Generate applicable student fees from class rules
- Partial cash payments with outstanding balance
- Automatic cash PDF receipt with unique receipt number
- Payment history and PDF reprint
- Excel import that INSERTS new students and UPDATES existing students by admission_no
- Excel template download
- Public notice board
- No parent portal and no online/UPI payment

## Excel columns
Required:
admission_no, name, class_name, section, parent_name, parent_phone

Optional:
area, sibling_group, hostel_required, vehicle_required, vehicle_area

Use Yes/No for hostel_required and vehicle_required.

## Supabase setup
1. Create a Supabase project.
2. Run `supabase/schema.sql` in SQL Editor.
3. Create an admin user under Authentication > Users.
4. Insert that user's UUID into `public.profiles` with role `admin`.
5. Add Vercel environment variables:
   - NEXT_PUBLIC_SUPABASE_URL
   - NEXT_PUBLIC_SUPABASE_ANON_KEY
6. Deploy to Vercel.

## Important fee workflow
1. Configure Fee Structure by class.
2. Add students and mark hostel/vehicle status.
3. On Fee Management, select a student and click Generate Applicable Fees.
4. Collect only physical cash.
5. The system creates a receipt and PDF for paid transactions.

No service-role key belongs in the browser.
