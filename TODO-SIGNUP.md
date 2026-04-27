
## Status: In Progress

1. [x] Add fieldWorker role to signup_screen.dart dropdown (match login_screen).
2. [ ] Improve signup error handling - parse Firebase codes.
3. [x] Add confirm password field.
4. [x] Fix syntax error in _register(), test signup → login → dashboard.
5. [ ] Check Firestore rules for users collection (allow create: if request.auth != null).
6. [ ] User test with new email/password.

**Test creds:** Use new email, NGO or Volunteer role.
**Firebase Console:** Verify users collection has uid doc with role.
