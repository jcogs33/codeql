import java

class UsernameType extends Type {
  UsernameType() {
    this.(Array).getComponentType().(PrimitiveType).getName() = "char" or
    this.(Array).getComponentType().(PrimitiveType).getName() = "byte" or
    this instanceof TypeString
  }
}

from Parameter p
where
  not p.getCallable().getDeclaringType() instanceof AnonymousClass and
  p.getName().regexpMatch("(?i)(user|username)") and
  p.getType() instanceof UsernameType
// select p.getCallable().getDeclaringType().getQualifiedName(), p.getCallable().getStringSignature(),
//   p.getType().toString(), p.getName(), p.getPosition()
// convert to MaD output (plus HeuristicInfo)
select p.getCallable().getDeclaringType().getPackage() + ";" +
    p.getCallable().getDeclaringType().getName() + ";" + "false;" + p.getCallable().getName() + ";" +
    p.getCallable().paramsString() + ";;" + "Argument[" + p.getPosition() + "];" + "sensitive-api" +
    " ...HeuristicInfo: " + p.getType().toString() + ", " + p.getName()
