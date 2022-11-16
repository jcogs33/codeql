import java

class PasswordType extends Type {
  PasswordType() {
    this.(Array).getComponentType().(PrimitiveType).getName() = "char" or
    this.(Array).getComponentType().(PrimitiveType).getName() = "byte" or
    this instanceof TypeString
  }
}

from Parameter p
where
  not p.getCallable().getDeclaringType() instanceof AnonymousClass and
  p.getName().regexpMatch("(?i)(encrypted|old|new)?pass(wd|word|code|phrase)(chars|value)?") and
  p.getType() instanceof PasswordType
// select p.getCallable().getDeclaringType().getQualifiedName(), p.getCallable().getStringSignature(),
//   p.getType().toString(), p.getName(), p.getPosition()
// convert to MaD output (plus HeuristicInfo)
select p.getCallable().getDeclaringType().getPackage() + ";" +
    p.getCallable().getDeclaringType().getName() + ";" + "false;" + p.getCallable().getName() + ";" +
    p.getCallable().paramsString() + ";;" + "Argument[" + p.getPosition() + "];" + "sensitive-api" +
    " ...HeuristicInfo: " + p.getType().toString() + ", " + p.getName()
