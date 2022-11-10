import java

class CryptoKeyType extends Type {
  CryptoKeyType() {
    this.(Array).getComponentType().(PrimitiveType).getName() = "char" or
    this.(Array).getComponentType().(PrimitiveType).getName() = "byte"
  }
}

class SecurityPackage extends Package {
  SecurityPackage() {
    getName().matches("java.security%") or
    getName().matches("javax.security%") or
    getName().matches("javax.crypto%") or
    getName().matches("sun.security%") or
    getName().matches("com.sun.crypto%")
  }
}

from Parameter p
where
  not p.getCallable().getDeclaringType() instanceof AnonymousClass and
  p.getName()
      .regexpMatch("(?i)(raw|secret|session|wrapped|protected|other|encoded|base)?key(bytes|value|pass)?") and
  p.getType() instanceof CryptoKeyType and
  p.getCallable().getDeclaringType().getPackage() instanceof SecurityPackage
select p.getCallable().getDeclaringType().getQualifiedName(), p.getCallable().getStringSignature(),
  p.getType().toString(), p.getName(), p.getPosition()
