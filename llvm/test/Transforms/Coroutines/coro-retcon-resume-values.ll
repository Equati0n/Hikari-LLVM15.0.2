; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes="default<O2>" -aa-pipeline=default -S | FileCheck %s

define i8* @f(i8* %buffer, i32 %n) {
; CHECK-LABEL: @f(
; CHECK-NEXT:  coro.return:
; CHECK-NEXT:    [[TMP0:%.*]] = tail call i8* @allocate(i32 12)
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[BUFFER:%.*]] to i8**
; CHECK-NEXT:    store i8* [[TMP0]], i8** [[TMP1]], align 8
; CHECK-NEXT:    [[N_SPILL_ADDR:%.*]] = bitcast i8* [[TMP0]] to i32*
; CHECK-NEXT:    store i32 [[N:%.*]], i32* [[N_SPILL_ADDR]], align 4
; CHECK-NEXT:    ret i8* bitcast (i8* (i8*, i32, i1)* @f.resume.0 to i8*)
;
entry:
  %id = call token @llvm.coro.id.retcon(i32 8, i32 4, i8* %buffer, i8* bitcast (i8* (i8*, i32, i1)* @prototype to i8*), i8* bitcast (i8* (i32)* @allocate to i8*), i8* bitcast (void (i8*)* @deallocate to i8*))
  %hdl = call i8* @llvm.coro.begin(token %id, i8* null)
  br label %loop

loop:
  %n.val = phi i32 [ %n, %entry ], [ %sum, %resume ]
  %values = call { i32, i1 } (...) @llvm.coro.suspend.retcon.sl_i32i1s()
  %finished = extractvalue { i32, i1 } %values, 1
  br i1 %finished, label %cleanup, label %resume

resume:
  %input = extractvalue { i32, i1 } %values, 0
  %sum = add i32 %n.val, %input
  br label %loop

cleanup:
  call void @print(i32 %n.val)
  call i1 @llvm.coro.end(i8* %hdl, i1 0)
  unreachable
}



define i32 @main() {
; CHECK-LABEL: @main(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = alloca i8*, align 8
; CHECK-NEXT:    [[TMP1:%.*]] = tail call i8* @allocate(i32 12)
; CHECK-NEXT:    store i8* [[TMP1]], i8** [[TMP0]], align 8
; CHECK-NEXT:    [[N_SPILL_ADDR_I:%.*]] = bitcast i8* [[TMP1]] to i32*
; CHECK-NEXT:    store i32 1, i32* [[N_SPILL_ADDR_I]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8** [[TMP0]] to %f.Frame**
; CHECK-NEXT:    [[N_VAL3_SPILL_ADDR_I:%.*]] = getelementptr inbounds i8, i8* [[TMP1]], i64 4
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[N_VAL3_SPILL_ADDR_I]] to i32*
; CHECK-NEXT:    store i32 1, i32* [[TMP3]], align 4, !noalias !0
; CHECK-NEXT:    [[INPUT_SPILL_ADDR_I:%.*]] = getelementptr inbounds i8, i8* [[TMP1]], i64 8
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast i8* [[INPUT_SPILL_ADDR_I]] to i32*
; CHECK-NEXT:    store i32 2, i32* [[TMP4]], align 4, !noalias !0
; CHECK-NEXT:    call void @llvm.experimental.noalias.scope.decl(metadata [[META3:![0-9]+]])
; CHECK-NEXT:    [[FRAMEPTR_I1:%.*]] = load %f.Frame*, %f.Frame** [[TMP2]], align 8, !alias.scope !3
; CHECK-NEXT:    [[INPUT_RELOAD_ADDR13_I:%.*]] = getelementptr inbounds [[F_FRAME:%.*]], %f.Frame* [[FRAMEPTR_I1]], i64 0, i32 2
; CHECK-NEXT:    [[INPUT_RELOAD14_I:%.*]] = load i32, i32* [[INPUT_RELOAD_ADDR13_I]], align 4, !noalias !3
; CHECK-NEXT:    [[N_VAL3_RELOAD_ADDR11_I:%.*]] = getelementptr inbounds [[F_FRAME]], %f.Frame* [[FRAMEPTR_I1]], i64 0, i32 1
; CHECK-NEXT:    [[N_VAL3_RELOAD12_I:%.*]] = load i32, i32* [[N_VAL3_RELOAD_ADDR11_I]], align 4, !noalias !3
; CHECK-NEXT:    [[SUM7_I:%.*]] = add i32 [[N_VAL3_RELOAD12_I]], [[INPUT_RELOAD14_I]]
; CHECK-NEXT:    store i32 [[SUM7_I]], i32* [[N_VAL3_RELOAD_ADDR11_I]], align 4, !noalias !3
; CHECK-NEXT:    store i32 4, i32* [[INPUT_RELOAD_ADDR13_I]], align 4, !noalias !3
; CHECK-NEXT:    call void @llvm.experimental.noalias.scope.decl(metadata [[META6:![0-9]+]])
; CHECK-NEXT:    [[FRAMEPTR_I2:%.*]] = load %f.Frame*, %f.Frame** [[TMP2]], align 8, !alias.scope !6
; CHECK-NEXT:    [[INPUT_RELOAD_ADDR13_I3:%.*]] = getelementptr inbounds [[F_FRAME]], %f.Frame* [[FRAMEPTR_I2]], i64 0, i32 2
; CHECK-NEXT:    [[INPUT_RELOAD14_I4:%.*]] = load i32, i32* [[INPUT_RELOAD_ADDR13_I3]], align 4, !noalias !6
; CHECK-NEXT:    [[N_VAL3_RELOAD_ADDR11_I5:%.*]] = getelementptr inbounds [[F_FRAME]], %f.Frame* [[FRAMEPTR_I2]], i64 0, i32 1
; CHECK-NEXT:    [[N_VAL3_RELOAD12_I6:%.*]] = load i32, i32* [[N_VAL3_RELOAD_ADDR11_I5]], align 4, !noalias !6
; CHECK-NEXT:    [[SUM7_I7:%.*]] = add i32 [[N_VAL3_RELOAD12_I6]], [[INPUT_RELOAD14_I4]]
; CHECK-NEXT:    call void @print(i32 [[SUM7_I7]]), !noalias !6
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast %f.Frame* [[FRAMEPTR_I2]] to i8*
; CHECK-NEXT:    call void @deallocate(i8* [[TMP5]]), !noalias !6
; CHECK-NEXT:    ret i32 0
;
entry:
  %0 = alloca [8 x i8], align 4
  %buffer = bitcast [8 x i8]* %0 to i8*
  %prepare = call i8* @llvm.coro.prepare.retcon(i8* bitcast (i8* (i8*, i32)* @f to i8*))
  %f = bitcast i8* %prepare to i8* (i8*, i32)*
  %cont0 = call i8* %f(i8* %buffer, i32 1)
  %cont0.cast = bitcast i8* %cont0 to i8* (i8*, i32, i1)*
  %cont1 = call i8* %cont0.cast(i8* %buffer, i32 2, i1 zeroext false)
  %cont1.cast = bitcast i8* %cont1 to i8* (i8*, i32, i1)*
  %cont2 = call i8* %cont1.cast(i8* %buffer, i32 4, i1 zeroext false)
  %cont2.cast = bitcast i8* %cont2 to i8* (i8*, i32, i1)*
  call i8* %cont2.cast(i8* %buffer, i32 100, i1 zeroext true)
  ret i32 0
}

;   Unfortunately, we don't seem to fully optimize this right now due
;   to some sort of phase-ordering thing.

declare token @llvm.coro.id.retcon(i32, i32, i8*, i8*, i8*, i8*)
declare i8* @llvm.coro.begin(token, i8*)
declare { i32, i1 } @llvm.coro.suspend.retcon.sl_i32i1s(...)
declare i1 @llvm.coro.end(i8*, i1)
declare i8* @llvm.coro.prepare.retcon(i8*)

declare i8* @prototype(i8*, i32, i1 zeroext)

declare noalias i8* @allocate(i32 %size)
declare void @deallocate(i8* %ptr)

declare void @print(i32)
