public class TestObjectString {

    void sink(Object o) { }

    Object source() { return null; }

    public void test() throws Exception {

        // Testing for java.lang.StringBuilder#append(ObjectString)
        StringBuilder sb = new StringBuilder();
        String str = "str";
        sb.append(str);
        Object obj = "obj";
        sb.append(obj);

        sb.append((Object)str);
        sb.append((String)obj);
        sb.append(str + obj);
        sb.append(obj + str);
        sb.append(obj.toString());
        sb.append(String.valueOf(obj));

        // String str2 = "str2";
        // Object obj2 = str2;
        // sb.append(obj2);

        // Class clazz = Class.forName("java.lang.String");
        // sb.append(clazz);
        // sb.append(clazz.getName());
        // sb.append(clazz.getSuperclass());

        // Testing for java.lang.String#split(ObjectString)
        String str3 = "boo:and:foo";
        String regex0 = ":";
        str3.split(regex0);

        // String regex1 = "d";
        // str2.split((Object)regex1);

        // Object regex2 = "o";
        // str2.split(regex2);

        Object regex3 = "f";
        str3.split((String)regex3);

        str3.split(null);
    }

}
