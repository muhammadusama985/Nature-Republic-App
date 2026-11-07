# R8 rules for the Nature Republic customer app.

# Stripe's Android SDK references optional push-provisioning classes that are
# not bundled with the Flutter plugin. This app never uses them, so R8 can
# safely ignore the dangling references (these are the rules AGP generates in
# build/app/outputs/mapping/release/missing_rules.txt).
-dontwarn com.stripe.android.pushProvisioning.**
