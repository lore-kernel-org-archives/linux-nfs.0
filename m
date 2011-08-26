Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab1HZWD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:03:28 -0400
Date: Fri, 26 Aug 2011 18:03:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org
Subject: [PATCH] All Arch: remove linkage for sys_nfsservctl system call
Message-ID: <20110826220311.GA18140@fieldses.org>
References: <1312810169.2591.1153.camel@deadeye>
 <20110808155538.GB904@fieldses.org>
 <20110808180658.GC29924@decadent.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110808180658.GC29924@decadent.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: NeilBrown <neilb@suse.de>

The nfsservctl system call is now gone, so we should remove all
linkage for it.

Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---

I don't normally have to deal with this kind of cross-architecture
patch; is this the right etiquette for it?

 arch/alpha/kernel/systbls.S            |    2 +-
 arch/arm/kernel/calls.S                |    2 +-
 arch/avr32/kernel/syscall_table.S      |    2 +-
 arch/blackfin/mach-common/entry.S      |    2 +-
 arch/cris/arch-v10/kernel/entry.S      |    2 +-
 arch/cris/arch-v32/kernel/entry.S      |    2 +-
 arch/frv/kernel/entry.S                |    2 +-
 arch/h8300/kernel/syscalls.S           |    2 +-
 arch/ia64/kernel/entry.S               |    2 +-
 arch/m32r/kernel/syscall_table.S       |    2 +-
 arch/m68k/kernel/syscalltable.S        |    2 +-
 arch/microblaze/kernel/syscall_table.S |    2 +-
 arch/mips/kernel/scall32-o32.S         |    2 +-
 arch/mips/kernel/scall64-64.S          |    2 +-
 arch/mips/kernel/scall64-n32.S         |    2 +-
 arch/mips/kernel/scall64-o32.S         |    2 +-
 arch/mn10300/kernel/entry.S            |    2 +-
 arch/s390/kernel/compat_wrapper.S      |    6 ------
 arch/s390/kernel/syscalls.S            |    2 +-
 arch/sh/kernel/syscalls_32.S           |    2 +-
 arch/sh/kernel/syscalls_64.S           |    2 +-
 arch/sparc/kernel/sys32.S              |    1 -
 arch/sparc/kernel/systbls_32.S         |    2 +-
 arch/sparc/kernel/systbls_64.S         |    2 +-
 arch/x86/ia32/ia32entry.S              |    2 +-
 arch/x86/include/asm/unistd_64.h       |    2 +-
 arch/x86/kernel/syscall_table_32.S     |    2 +-
 arch/xtensa/include/asm/unistd.h       |    2 +-
 fs/compat.c                            |    5 -----
 include/asm-generic/unistd.h           |    2 +-
 include/linux/compat.h                 |    1 -
 include/linux/syscalls.h               |    3 ---
 kernel/sys_ni.c                        |    1 -
 33 files changed, 27 insertions(+), 44 deletions(-)

diff --git a/arch/alpha/kernel/systbls.S b/arch/alpha/kernel/systbls.S
index b9c28f3..6acea1f 100644
--- a/arch/alpha/kernel/systbls.S
+++ b/arch/alpha/kernel/systbls.S
@@ -360,7 +360,7 @@ sys_call_table:
 	.quad sys_newuname
 	.quad sys_nanosleep			/* 340 */
 	.quad sys_mremap
-	.quad sys_nfsservctl
+	.quad sys_ni_syscall			/* old nfsservctl */
 	.quad sys_setresuid
 	.quad sys_getresuid
 	.quad sys_pciconfig_read		/* 345 */
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 80f7896..9943e9e 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -178,7 +178,7 @@
 		CALL(sys_ni_syscall)		/* vm86 */
 		CALL(sys_ni_syscall)		/* was sys_query_module */
 		CALL(sys_poll)
-		CALL(sys_nfsservctl)
+		CALL(sys_ni_syscall)		/* was nfsservctl */
 /* 170 */	CALL(sys_setresgid16)
 		CALL(sys_getresgid16)
 		CALL(sys_prctl)
diff --git a/arch/avr32/kernel/syscall_table.S b/arch/avr32/kernel/syscall_table.S
index c7fd394..6eba535 100644
--- a/arch/avr32/kernel/syscall_table.S
+++ b/arch/avr32/kernel/syscall_table.S
@@ -158,7 +158,7 @@ sys_call_table:
 	.long	sys_sched_rr_get_interval
 	.long	sys_nanosleep
 	.long	sys_poll
-	.long	sys_nfsservctl		/* 145 */
+	.long	sys_ni_syscall		/* 145 was nfsservctl */
 	.long	sys_setresgid
 	.long	sys_getresgid
 	.long	sys_prctl
diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-common/entry.S
index 225d311..e413729 100644
--- a/arch/blackfin/mach-common/entry.S
+++ b/arch/blackfin/mach-common/entry.S
@@ -1543,7 +1543,7 @@ ENTRY(_sys_call_table)
 	.long _sys_ni_syscall	/* for vm86 */
 	.long _sys_ni_syscall	/* old "query_module" */
 	.long _sys_ni_syscall	/* sys_poll */
-	.long _sys_nfsservctl
+	.long _sys_ni_syscall   /* old nfsservctl */
 	.long _sys_setresgid	/* setresgid16 */	/* 170 */
 	.long _sys_getresgid	/* getresgid16 */
 	.long _sys_prctl
diff --git a/arch/cris/arch-v10/kernel/entry.S b/arch/cris/arch-v10/kernel/entry.S
index 1161883..592fbe9 100644
--- a/arch/cris/arch-v10/kernel/entry.S
+++ b/arch/cris/arch-v10/kernel/entry.S
@@ -771,7 +771,7 @@ sys_call_table:
 	.long sys_ni_syscall	/* sys_vm86 */
 	.long sys_ni_syscall	/* Old sys_query_module */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall    /* old nfsservctl */
 	.long sys_setresgid16	/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/cris/arch-v32/kernel/entry.S b/arch/cris/arch-v32/kernel/entry.S
index 84fed7e..c3ea469 100644
--- a/arch/cris/arch-v32/kernel/entry.S
+++ b/arch/cris/arch-v32/kernel/entry.S
@@ -714,7 +714,7 @@ sys_call_table:
 	.long sys_ni_syscall	/* sys_vm86 */
 	.long sys_ni_syscall	/* Old sys_query_module */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall	/* Old nfsservctl */
 	.long sys_setresgid16	/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/frv/kernel/entry.S b/arch/frv/kernel/entry.S
index 017d6d7..5ba23f7 100644
--- a/arch/frv/kernel/entry.S
+++ b/arch/frv/kernel/entry.S
@@ -1358,7 +1358,7 @@ sys_call_table:
 	.long sys_ni_syscall	/* for vm86 */
 	.long sys_ni_syscall	/* Old sys_query_module */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall	/* Old nfsservctl */
 	.long sys_setresgid16	/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/h8300/kernel/syscalls.S b/arch/h8300/kernel/syscalls.S
index f4b2e67..4be2ea2 100644
--- a/arch/h8300/kernel/syscalls.S
+++ b/arch/h8300/kernel/syscalls.S
@@ -183,7 +183,7 @@ SYMBOL_NAME_LABEL(sys_call_table)
 	.long SYMBOL_NAME(sys_ni_syscall)	/* for vm86 */
 	.long SYMBOL_NAME(sys_ni_syscall)	/* sys_query_module */
 	.long SYMBOL_NAME(sys_poll)
-	.long SYMBOL_NAME(sys_nfsservctl)
+	.long SYMBOL_NAME(sys_ni_syscall)	/* old nfsservctl */
 	.long SYMBOL_NAME(sys_setresgid16)	/* 170 */
 	.long SYMBOL_NAME(sys_getresgid16)
 	.long SYMBOL_NAME(sys_prctl)
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 97dd2ab..198c753 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1614,7 +1614,7 @@ sys_call_table:
 	data8 sys_sched_get_priority_min
 	data8 sys_sched_rr_get_interval
 	data8 sys_nanosleep
-	data8 sys_nfsservctl
+	data8 sys_ni_syscall			// old nfsservctl
 	data8 sys_prctl				// 1170
 	data8 sys_getpagesize
 	data8 sys_mmap2
diff --git a/arch/m32r/kernel/syscall_table.S b/arch/m32r/kernel/syscall_table.S
index 528f2e6..f365c19 100644
--- a/arch/m32r/kernel/syscall_table.S
+++ b/arch/m32r/kernel/syscall_table.S
@@ -168,7 +168,7 @@ ENTRY(sys_call_table)
 	.long sys_tas			/* vm86 syscall holder */
 	.long sys_ni_syscall		/* query_module syscall holder */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall		/* was nfsservctl */
 	.long sys_setresgid		/* 170 */
 	.long sys_getresgid
 	.long sys_prctl
diff --git a/arch/m68k/kernel/syscalltable.S b/arch/m68k/kernel/syscalltable.S
index 00d1452..c468f2e 100644
--- a/arch/m68k/kernel/syscalltable.S
+++ b/arch/m68k/kernel/syscalltable.S
@@ -189,7 +189,7 @@ ENTRY(sys_call_table)
 	.long sys_getpagesize
 	.long sys_ni_syscall		/* old "query_module" */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall		/* old nfsservctl */
 	.long sys_setresgid16		/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/microblaze/kernel/syscall_table.S b/arch/microblaze/kernel/syscall_table.S
index d915a12..8789daa 100644
--- a/arch/microblaze/kernel/syscall_table.S
+++ b/arch/microblaze/kernel/syscall_table.S
@@ -173,7 +173,7 @@ ENTRY(sys_call_table)
 	.long sys_ni_syscall		/* sys_vm86 */
 	.long sys_ni_syscall		/* Old sys_query_module */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall		/* old nfsservctl */
 	.long sys_setresgid		/* 170 */
 	.long sys_getresgid
 	.long sys_prctl
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-o32.S
index e521420..865bc7a 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -424,7 +424,7 @@ einval:	li	v0, -ENOSYS
 	sys	sys_getresuid		3
 	sys	sys_ni_syscall		0	/* was sys_query_module */
 	sys	sys_poll		3
-	sys	sys_nfsservctl		3
+	sys	sys_ni_syscall		0	/* was nfsservctl */
 	sys	sys_setresgid		3	/* 4190 */
 	sys	sys_getresgid		3
 	sys	sys_prctl		5
diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64-64.S
index 85874d6..fb7334b 100644
--- a/arch/mips/kernel/scall64-64.S
+++ b/arch/mips/kernel/scall64-64.S
@@ -299,7 +299,7 @@ sys_call_table:
 	PTR	sys_ni_syscall			/* 5170, was get_kernel_syms */
 	PTR	sys_ni_syscall			/* was query_module */
 	PTR	sys_quotactl
-	PTR	sys_nfsservctl
+	PTR	sys_ni_syscall			/* was nfsservctl */
 	PTR	sys_ni_syscall			/* res. for getpmsg */
 	PTR	sys_ni_syscall			/* 5175  for putpmsg */
 	PTR	sys_ni_syscall			/* res. for afs_syscall */
diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall64-n32.S
index b85842f..f9296e8 100644
--- a/arch/mips/kernel/scall64-n32.S
+++ b/arch/mips/kernel/scall64-n32.S
@@ -294,7 +294,7 @@ EXPORT(sysn32_call_table)
 	PTR	sys_ni_syscall			/* 6170, was get_kernel_syms */
 	PTR	sys_ni_syscall			/* was query_module */
 	PTR	sys_quotactl
-	PTR	compat_sys_nfsservctl
+	PTR	sys_ni_syscall			/* was nfsservctl */
 	PTR	sys_ni_syscall			/* res. for getpmsg */
 	PTR	sys_ni_syscall			/* 6175  for putpmsg */
 	PTR	sys_ni_syscall			/* res. for afs_syscall */
diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall64-o32.S
index 46c4763..4d7c982 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -392,7 +392,7 @@ sys_call_table:
 	PTR	sys_getresuid
 	PTR	sys_ni_syscall			/* was query_module */
 	PTR	sys_poll
-	PTR	compat_sys_nfsservctl
+	PTR	sys_ni_syscall			/* was nfsservctl */
 	PTR	sys_setresgid			/* 4190 */
 	PTR	sys_getresgid
 	PTR	sys_prctl
diff --git a/arch/mn10300/kernel/entry.S b/arch/mn10300/kernel/entry.S
index ae435e1..3e3620d 100644
--- a/arch/mn10300/kernel/entry.S
+++ b/arch/mn10300/kernel/entry.S
@@ -589,7 +589,7 @@ ENTRY(sys_call_table)
 	.long sys_ni_syscall	/* vm86 */
 	.long sys_ni_syscall	/* Old sys_query_module */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall	/* was nfsservctl */
 	.long sys_setresgid16	/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index 08ab9aa..7526db6 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -665,12 +665,6 @@ ENTRY(sys32_poll_wrapper)
 	lgfr	%r4,%r4			# long
 	jg	sys_poll		# branch to system call
 
-ENTRY(compat_sys_nfsservctl_wrapper)
-	lgfr	%r2,%r2			# int
-	llgtr	%r3,%r3			# struct compat_nfsctl_arg*
-	llgtr	%r4,%r4			# union compat_nfsctl_res*
-	jg	compat_sys_nfsservctl	# branch to system call
-
 ENTRY(sys32_setresgid16_wrapper)
 	llgfr	%r2,%r2			# __kernel_old_gid_emu31_t
 	llgfr	%r3,%r3			# __kernel_old_gid_emu31_t
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 6ee39ef..73eb08c 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -177,7 +177,7 @@ SYSCALL(sys_getresuid16,sys_ni_syscall,sys32_getresuid16_wrapper)	/* 165 old get
 NI_SYSCALL							/* for vm86 */
 NI_SYSCALL							/* old sys_query_module */
 SYSCALL(sys_poll,sys_poll,sys32_poll_wrapper)
-SYSCALL(sys_nfsservctl,sys_nfsservctl,compat_sys_nfsservctl_wrapper)
+NI_SYSCALL							/* old nfsservctl */
 SYSCALL(sys_setresgid16,sys_ni_syscall,sys32_setresgid16_wrapper)	/* 170 old setresgid16 syscall */
 SYSCALL(sys_getresgid16,sys_ni_syscall,sys32_getresgid16_wrapper)	/* old getresgid16 syscall */
 SYSCALL(sys_prctl,sys_prctl,sys32_prctl_wrapper)
diff --git a/arch/sh/kernel/syscalls_32.S b/arch/sh/kernel/syscalls_32.S
index 39b051d..293e39c 100644
--- a/arch/sh/kernel/syscalls_32.S
+++ b/arch/sh/kernel/syscalls_32.S
@@ -185,7 +185,7 @@ ENTRY(sys_call_table)
 	.long sys_ni_syscall	/* vm86 */
 	.long sys_ni_syscall	/* old "query_module" */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall	/* was nfsservctl */
 	.long sys_setresgid16	/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/sh/kernel/syscalls_64.S b/arch/sh/kernel/syscalls_64.S
index 089c4d8..ceb34b9 100644
--- a/arch/sh/kernel/syscalls_64.S
+++ b/arch/sh/kernel/syscalls_64.S
@@ -189,7 +189,7 @@ sys_call_table:
 	.long sys_ni_syscall	/* vm86 */
 	.long sys_ni_syscall	/* old "query_module" */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall	/* was nfsservctl */
 	.long sys_setresgid16		/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/sparc/kernel/sys32.S b/arch/sparc/kernel/sys32.S
index 44e5faf..d97f3eb 100644
--- a/arch/sparc/kernel/sys32.S
+++ b/arch/sparc/kernel/sys32.S
@@ -81,7 +81,6 @@ SIGN2(sys32_fadvise64, compat_sys_fadvise64, %o0, %o4)
 SIGN2(sys32_fadvise64_64, compat_sys_fadvise64_64, %o0, %o5)
 SIGN2(sys32_bdflush, sys_bdflush, %o0, %o1)
 SIGN1(sys32_mlockall, sys_mlockall, %o0)
-SIGN1(sys32_nfsservctl, compat_sys_nfsservctl, %o0)
 SIGN1(sys32_clock_nanosleep, compat_sys_clock_nanosleep, %o1)
 SIGN1(sys32_timer_settime, compat_sys_timer_settime, %o1)
 SIGN1(sys32_io_submit, compat_sys_io_submit, %o1)
diff --git a/arch/sparc/kernel/systbls_32.S b/arch/sparc/kernel/systbls_32.S
index 6e492d5..09d8ec4 100644
--- a/arch/sparc/kernel/systbls_32.S
+++ b/arch/sparc/kernel/systbls_32.S
@@ -67,7 +67,7 @@ sys_call_table:
 /*235*/	.long sys_fstatfs64, sys_llseek, sys_mlock, sys_munlock, sys_mlockall
 /*240*/	.long sys_munlockall, sys_sched_setparam, sys_sched_getparam, sys_sched_setscheduler, sys_sched_getscheduler
 /*245*/	.long sys_sched_yield, sys_sched_get_priority_max, sys_sched_get_priority_min, sys_sched_rr_get_interval, sys_nanosleep
-/*250*/	.long sys_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_nfsservctl
+/*250*/	.long sys_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_ni_syscall
 /*255*/	.long sys_sync_file_range, sys_clock_settime, sys_clock_gettime, sys_clock_getres, sys_clock_nanosleep
 /*260*/	.long sys_sched_getaffinity, sys_sched_setaffinity, sys_timer_settime, sys_timer_gettime, sys_timer_getoverrun
 /*265*/	.long sys_timer_delete, sys_timer_create, sys_nis_syscall, sys_io_setup, sys_io_destroy
diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls_64.S
index f566518..c9296ab 100644
--- a/arch/sparc/kernel/systbls_64.S
+++ b/arch/sparc/kernel/systbls_64.S
@@ -145,7 +145,7 @@ sys_call_table:
 	.word sys_fstatfs64, sys_llseek, sys_mlock, sys_munlock, sys_mlockall
 /*240*/	.word sys_munlockall, sys_sched_setparam, sys_sched_getparam, sys_sched_setscheduler, sys_sched_getscheduler
 	.word sys_sched_yield, sys_sched_get_priority_max, sys_sched_get_priority_min, sys_sched_rr_get_interval, sys_nanosleep
-/*250*/	.word sys_64_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_nfsservctl
+/*250*/	.word sys_64_mremap, sys_sysctl, sys_getsid, sys_fdatasync, sys_nis_syscall
 	.word sys_sync_file_range, sys_clock_settime, sys_clock_gettime, sys_clock_getres, sys_clock_nanosleep
 /*260*/	.word sys_sched_getaffinity, sys_sched_setaffinity, sys_timer_settime, sys_timer_gettime, sys_timer_getoverrun
 	.word sys_timer_delete, sys_timer_create, sys_ni_syscall, sys_io_setup, sys_io_destroy
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index a0e866d..54edb207 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -672,7 +672,7 @@ ia32_sys_call_table:
 	.quad sys32_vm86_warning	/* vm86 */ 
 	.quad quiet_ni_syscall	/* query_module */
 	.quad sys_poll
-	.quad compat_sys_nfsservctl
+	.quad quiet_ni_syscall /* old nfsservctl */
 	.quad sys_setresgid16	/* 170 */
 	.quad sys_getresgid16
 	.quad sys_prctl
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 705bf13..4ee353b 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -414,7 +414,7 @@ __SYSCALL(__NR_query_module, sys_ni_syscall)
 __SYSCALL(__NR_quotactl, sys_quotactl)
 
 #define __NR_nfsservctl				180
-__SYSCALL(__NR_nfsservctl, sys_nfsservctl)
+__SYSCALL(__NR_nfsservctl, sys_ni_syscall)
 
 /* reserved for LiS/STREAMS */
 #define __NR_getpmsg				181
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index fbb0a04..bc19be3 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -168,7 +168,7 @@ ENTRY(sys_call_table)
 	.long ptregs_vm86
 	.long sys_ni_syscall	/* Old sys_query_module */
 	.long sys_poll
-	.long sys_nfsservctl
+	.long sys_ni_syscall	/* Old nfsservctl */
 	.long sys_setresgid16	/* 170 */
 	.long sys_getresgid16
 	.long sys_prctl
diff --git a/arch/xtensa/include/asm/unistd.h b/arch/xtensa/include/asm/unistd.h
index a6f934f..798ee6d 100644
--- a/arch/xtensa/include/asm/unistd.h
+++ b/arch/xtensa/include/asm/unistd.h
@@ -455,7 +455,7 @@ __SYSCALL(203, sys_reboot, 3)
 #define __NR_quotactl 				204
 __SYSCALL(204, sys_quotactl, 4)
 #define __NR_nfsservctl 			205
-__SYSCALL(205, sys_nfsservctl, 3)
+__SYSCALL(205, sys_ni_syscall, 0)
 #define __NR__sysctl 				206
 __SYSCALL(206, sys_sysctl, 1)
 #define __NR_bdflush 				207
diff --git a/fs/compat.c b/fs/compat.c
index 0b48d01..58b1da4 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1675,11 +1675,6 @@ asmlinkage long compat_sys_ppoll(struct pollfd __user *ufds,
 }
 #endif /* HAVE_SET_RESTORE_SIGMASK */
 
-long asmlinkage compat_sys_nfsservctl(int cmd, void *notused, void *notused2)
-{
-	return sys_ni_syscall();
-}
-
 #ifdef CONFIG_EPOLL
 
 #ifdef HAVE_SET_RESTORE_SIGMASK
diff --git a/include/asm-generic/unistd.h b/include/asm-generic/unistd.h
index 4f769593..f4c38d8c 100644
--- a/include/asm-generic/unistd.h
+++ b/include/asm-generic/unistd.h
@@ -143,7 +143,7 @@ __SYSCALL(__NR_pivot_root, sys_pivot_root)
 
 /* fs/nfsctl.c */
 #define __NR_nfsservctl 42
-__SC_COMP(__NR_nfsservctl, sys_nfsservctl, compat_sys_nfsservctl)
+__SYSCALL(__NR_nfsservctl, sys_ni_syscall)
 
 /* fs/open.c */
 #define __NR3264_statfs 43
diff --git a/include/linux/compat.h b/include/linux/compat.h
index 8779405..c6e7523 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -438,7 +438,6 @@ asmlinkage long compat_sys_ppoll(struct pollfd __user *ufds,
 				 struct compat_timespec __user *tsp,
 				 const compat_sigset_t __user *sigmask,
 				 compat_size_t sigsetsize);
-asmlinkage long compat_sys_nfsservctl(int cmd, void *notused, void *notused2);
 asmlinkage long compat_sys_signalfd4(int ufd,
 				     const compat_sigset_t __user *sigmask,
 				     compat_size_t sigsetsize, int flags);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 8c03b98..1ff0ec2 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -702,9 +702,6 @@ asmlinkage long sys_sysctl(struct __sysctl_args __user *args);
 asmlinkage long sys_sysinfo(struct sysinfo __user *info);
 asmlinkage long sys_sysfs(int option,
 				unsigned long arg1, unsigned long arg2);
-asmlinkage long sys_nfsservctl(int cmd,
-				struct nfsctl_arg __user *arg,
-				void __user *res);
 asmlinkage long sys_syslog(int type, char __user *buf, int len);
 asmlinkage long sys_uselib(const char __user *library);
 asmlinkage long sys_ni_syscall(void);
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 62cbc88..a9a5de0 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -16,7 +16,6 @@ asmlinkage long sys_ni_syscall(void)
 	return -ENOSYS;
 }
 
-cond_syscall(sys_nfsservctl);
 cond_syscall(sys_quotactl);
 cond_syscall(sys32_quotactl);
 cond_syscall(sys_acct);
-- 
1.7.4.1

