package com.android.stubs;

public enum InterfaceEnum
        implements com.android.stubs.Parent.Interface {
    VAL();

    public static final java.lang.Object OBJECT;

    static {
        OBJECT = null;
    }

    public void method() {
        throw new RuntimeException("Stub!");
    }
}
