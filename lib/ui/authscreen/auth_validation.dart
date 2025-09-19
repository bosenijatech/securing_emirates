class AuthValidation {
  validateFullName(String value) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Full Name is required';
      } else if (value.length < 2) {
        return 'Full Name should be at least 2 characters long';
      } else if (value.length > 50) {
        return 'Full Name should not exceed 50 characters';
      }
      return null;
    };
  }

  errValidateMobileNo(String value) {
    return (value) {
      if (value.isEmpty) {
        return 'Mobile is required';
      } else if (value.length != 10) {
        return 'Mobile number should be 10 digits';
        // return 'Mobile number should have exactly 10 characters';
      }
      return null;
    };
  }

   errValidateReferCode(String value) {
    return (value) {
      if (value.isEmpty) {
        return 'Referral Code is required';
      } 
      return null;
    };
  }

  errValidatePassword(String value) {
    return (value) {
      if (value.isEmpty) {
        return 'Password is required';
      } else if (value.length < 4) {
        return 'Password must be atleast 4 characters';
        // } else if (value.length < 4 || value.length > 20) {
        //   return 'Password must be atleast 4 characters';
      } else if (value.length > 15) {
        return 'Please enter valid password';
      } else if (!containsLetter(value) || !containsNumber(value)) {
        return 'Password must contain letters and numbers';
      }
      // } else if (!containsLetter(value) ||
      //     !containsNumber(value) ||
      //     !containsSymbol(value)) {
      //   return 'Password must contain at least one letter, one number, and one symbol';
      // }
      return null;
    };
  }

  errValidatePasswordForLogin(String value) {
    return (value) {
      if (value.isEmpty) {
        return 'Password is required';
      }
      return null;
    };
  }

  errValidateOTP(String value) {
    return (value) {
      if (value.isEmpty) {
        return 'OTP is required';
      }
      return null;
    };
  }

  bool containsLetter(String value) {
    return RegExp(r'[a-zA-Z]').hasMatch(value);
  }

  bool containsNumber(String value) {
    return RegExp(r'[0-9]').hasMatch(value);
  }

  bool containsSymbol(String value) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
  }
}