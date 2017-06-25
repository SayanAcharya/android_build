package com.android.stubs;

@com.android.stubs.Annot(value = "asdf")
public class Parent {
    public static final byte public_static_final_byte = 42;
    public static final short public_static_final_short = 43;
    public static final int public_static_final_int = 44;
    public static final long public_static_final_long = 45L;
    public static final char public_static_final_char = 4660;
    public static final float public_static_final_float = 42.1f;
    public static final double public_static_final_double = 42.2;
    public static final java.lang.String public_static_final_String = "ps\u1234fS";
    public static final com.android.stubs.Parent public_static_final_Parent;
    public static final com.android.stubs.Parent public_static_final_Parent_null;
    public static int public_static_int;
    public static java.lang.String public_static_String;
    public static com.android.stubs.Parent public_static_Parent;

    static {
        public_static_final_Parent = null;
        public_static_final_Parent_null = null;
    }

    public Parent() {
        throw new RuntimeException("Stub!");
    }

    public java.lang.String methodString() {
        throw new RuntimeException("Stub!");
    }

    public int method(boolean b, char c, int i, long l, float f, double d) {
        throw new RuntimeException("Stub!");
    }

    protected void protectedMethod() {
        throw new RuntimeException("Stub!");
    }

    public static interface Interface {
        public void method();
    }
}
