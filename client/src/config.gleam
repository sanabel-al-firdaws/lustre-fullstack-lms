pub type Lang {
  Lang(
    direction: String,
    university_name: String,
    login: String,
    login_title: String,
    email: String,
    email_placeholder: String,
    password: String,
    password_placeholder: String,
    did_you_forget_password: String,
    hi_admin: String,
    hi_student: String,
  )
}

pub const en = Lang(
  direction: "ltr",
  university_name: "University of Oxford",
  login: "Login",
  login_title: "Students Login",
  email: "Email",
  email_placeholder: "Student's Email",
  password: "Password",
  password_placeholder: "Password",
  did_you_forget_password: "Did you forget your password ?",
  hi_admin: "Welcome back Admin",
  hi_student: "Welcome back Student",
)

pub const ar = Lang(
  direction: "rtl",
  login: "سجل دخولك",
  university_name: "جامعة اكسفورد",
  login_title: "تسجيل دخول الطلاب",
  email: "البريد الإلكتروني",
  email_placeholder: "البريد الإلكتروني للطالب",
  password: "كلمة السر",
  password_placeholder: "كلمة سر الطالب",
  did_you_forget_password: "هل نسيت كلمة السر ؟",
  hi_admin: "أهلا  بك أيها المشرف",
  hi_student: "أهلا  بك أيها الطالب",
)
