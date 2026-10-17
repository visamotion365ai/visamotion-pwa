# VisaMOTion PWA

VisaMOTion is a mobile-first, installable PWA for destination discovery, visa route planning, document preparation, application tracking, saved destinations, advisor requests, profile sync, and a separate admin workspace.

## Verified URLs

- Live app: https://visamotion-pwa.pages.bu.app/
- Source repository: https://github.com/visamotion365ai/visamotion-pwa
- Supabase project dashboard: https://supabase.com/dashboard/project/qmpuiloswytoycaflbmc

## Product surface

- Home / destination discovery
- Explore search and purpose filters
- Country details and route selection
- Work, study, visit, business, family, and eVisa purpose cards
- Document checklist with local file metadata and optional signed-in Supabase Storage upload
- Application tracker with progress state
- Saved destinations
- Consultation request form
- Profile and passwordless Supabase Auth entry point
- Separate admin overview, country content, and application queue views
- Offline-capable network-first service worker and iOS Add to Home Screen guidance

## Data and safety

`supabase-schema.sql` creates only `visamotion_*` tables and a private `visamotion-documents` bucket. Existing agency tables are not changed. Public destination/content reads are allowed; profiles, applications, documents, and storage objects are restricted to the signed-in owner with RLS policies.

The frontend uses only the Supabase publishable client key. No service-role key is included.

## Local preview

Serve `index.html` or `visamotion.html` from any HTTPS static host. Apply `supabase-schema.sql` to the connected project before testing cross-device sync.
