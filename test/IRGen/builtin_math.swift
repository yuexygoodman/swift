// RUN: %target-swift-frontend -assume-parsing-unqualified-ownership-sil -emit-ir -O %s | %FileCheck %s

// XFAIL: linux

import Darwin

// Make sure we use an intrinsic for functions such as exp.

// CHECK-LABEL: define {{.*}}test1
// CHECK: call float @llvm.exp.f32

public func test1(f : Float) -> Float {
  return exp(f)
}

// CHECK-LABEL: define {{.*}}test2
// CHECK: call double @llvm.exp.f64

public func test2(f : Double) -> Double {
  return _exp(f)
}

// CHECK-LABEL: define {{.*}}test3
// CHECK: call double @sqrt

public func test3(d : Double) -> Double {
  // This call uses the sqrt function imported from C.
  return sqrt(d)
}

// CHECK-LABEL: define {{.*}}test4
// CHECK-LINUX: call float @llvm.sqrt.f32
// CHECK-WINDOWS: call float @llvm.sqrt.f32

public func test4(f : Float) -> Float {
  // This call does not match the signature for the C sqrt function
  // (as opposed to sqrtf) so instead it gets compiled using the generic
  // sqrt function from the stdlib's tgmath.swift. That translates to
  // _stdlib_squareRootf and then to __builtin_sqrtf via SwiftShims.
  return sqrt(f)
}

// CHECK-LABEL: define {{.*}}test3a
// CHECK: call double @remainder

public func test3a(d : Double) -> Double {
  return remainder(1,d)
}

// CHECK-LABEL: define {{.*}}test4a
// CHECK: call float @remainder

public func test4a(f : Float) -> Float {
  return remainder(1,f)
}

// CHECK-LABEL: define {{.*}}test5
// CHECK: ret float 2

public func test5( ) -> Float {
  return sqrt(4)
}

// CHECK-LABEL: define {{.*}}test6
// CHECK: ret double 2

public func test6( ) -> Double {
  return sqrt(4)
}

// CHECK-LABEL: define {{.*}}test7
// CHECK-NOT: ret float undef

public func test7( ) -> Float {
  return sqrt(-1)
}

// CHECK-LABEL: define {{.*}}test8
// CHECK-NOT: ret double undef

public func test8( ) -> Double {
  return sqrt(-1)
}
