Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:53337 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935157AbcKJQrF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 11:47:05 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Ilya Dryomov <idryomov@gmail.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jiri Kosina <jikos@kernel.org>, Jonathan Cameron <jic23@kernel.org>,
        Ley Foon Tan <lftan@altera.com>,
        "Luis R . Rodriguez" <mcgrof@kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Michal Marek <mmarek@suse.com>, Russell King <linux@armlinux.org.uk>,
        Sean Young <sean@mess.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>, x86@kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-snps-arc@lists.infradead.org, nios2-dev@lists.rocketboards.org,
        linux-s390@vger.kernel.org, linux-crypto@vger.kernel.org,
        linux-media@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/11] Kbuild: enable -Wmaybe-uninitialized warning for "make W=1"
Date: Thu, 10 Nov 2016 17:44:44 +0100
Message-Id: <20161110164454.293477-2-arnd@arndb.de>
In-Reply-To: <20161110164454.293477-1-arnd@arndb.de>
References: <20161110164454.293477-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Traditionally, we have always had warnings about uninitialized variables
enabled, as this is part of -Wall, and generally a good idea [1], but it
also always produced false positives, mainly because this is a variation
of the halting problem and provably impossible to get right in all cases
[2].

Various people have identified cases that are particularly bad for false
positives, and in commit e74fc973b6e5 ("Turn off -Wmaybe-uninitialized
when building with -Os"), I turned off the warning for any build that
was done with CC_OPTIMIZE_FOR_SIZE.  This drastically reduced the number
of false positive warnings in the default build but unfortunately had
the side effect of turning the warning off completely in 'allmodconfig'
builds, which in turn led to a lot of warnings (both actual bugs, and
remaining false positives) to go in unnoticed.

With commit 877417e6ffb9 ("Kbuild: change CC_OPTIMIZE_FOR_SIZE
definition") enabled the warning again for allmodconfig builds in v4.7
and in v4.8-rc1, I had finally managed to address all warnings I get in
an ARM allmodconfig build and most other maybe-uninitialized warnings
for ARM randconfig builds.

However, commit 6e8d666e9253 ("Disable "maybe-uninitialized" warning
globally") was merged at the same time and disabled it completely for
all configurations, because of false-positive warnings on x86 that I had
not addressed until then. This caused a lot of actual bugs to get merged
into mainline, and I sent several dozen patches for these during the v4.9
development cycle. Most of these are actual bugs, some are for correct
code that is safe because it is only called under external constraints
that make it impossible to run into the case that gcc sees, and in a
few cases gcc is just stupid and finds something that can obviously
never happen.

I have now done a few thousand randconfig builds on x86 and collected all
patches that I needed to address every single warning I got (I can provide
the combined patch for the other warnings if anyone is interested),
so I hope we can get the warning back and let people catch the actual
bugs earlier.

This reverts the change to disable the warning completely and for
now brings it back at the "make W=1" level, so we can get it merged
into mainline without introducing false positives. A follow-up
patch enables it on all levels unless some configuration option
turns it off because of false-positives.

Link: https://rusty.ozlabs.org/?p=232 [1]
Link: https://gcc.gnu.org/wiki/Better_Uninitialized_Warnings [2]
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 Makefile                   | 10 ++++++----
 arch/arc/Makefile          |  4 +++-
 scripts/Makefile.extrawarn |  3 +++
 scripts/Makefile.ubsan     |  4 ++++
 4 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/Makefile b/Makefile
index f97f786..06e2b73 100644
--- a/Makefile
+++ b/Makefile
@@ -370,7 +370,7 @@ LDFLAGS_MODULE  =
 CFLAGS_KERNEL	=
 AFLAGS_KERNEL	=
 LDFLAGS_vmlinux =
-CFLAGS_GCOV	= -fprofile-arcs -ftest-coverage -fno-tree-loop-im
+CFLAGS_GCOV	= -fprofile-arcs -ftest-coverage -fno-tree-loop-im -Wno-maybe-uninitialized
 CFLAGS_KCOV	:= $(call cc-option,-fsanitize-coverage=trace-pc,)
 
 
@@ -620,7 +620,6 @@ ARCH_CFLAGS :=
 include arch/$(SRCARCH)/Makefile
 
 KBUILD_CFLAGS	+= $(call cc-option,-fno-delete-null-pointer-checks,)
-KBUILD_CFLAGS	+= $(call cc-disable-warning,maybe-uninitialized,)
 KBUILD_CFLAGS	+= $(call cc-disable-warning,frame-address,)
 
 ifdef CONFIG_LD_DEAD_CODE_DATA_ELIMINATION
@@ -629,15 +628,18 @@ KBUILD_CFLAGS	+= $(call cc-option,-fdata-sections,)
 endif
 
 ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
-KBUILD_CFLAGS	+= -Os
+KBUILD_CFLAGS	+= -Os $(call cc-disable-warning,maybe-uninitialized,)
 else
 ifdef CONFIG_PROFILE_ALL_BRANCHES
-KBUILD_CFLAGS	+= -O2
+KBUILD_CFLAGS	+= -O2 $(call cc-disable-warning,maybe-uninitialized,)
 else
 KBUILD_CFLAGS   += -O2
 endif
 endif
 
+KBUILD_CFLAGS += $(call cc-ifversion, -lt, 0409, \
+			$(call cc-disable-warning,maybe-uninitialized,))
+
 # Tell gcc to never replace conditional load with a non-conditional one
 KBUILD_CFLAGS	+= $(call cc-option,--param=allow-store-data-races=0)
 
diff --git a/arch/arc/Makefile b/arch/arc/Makefile
index 864adad..25f81a1 100644
--- a/arch/arc/Makefile
+++ b/arch/arc/Makefile
@@ -68,7 +68,9 @@ cflags-$(CONFIG_ARC_DW2_UNWIND)		+= -fasynchronous-unwind-tables $(cfi)
 ifndef CONFIG_CC_OPTIMIZE_FOR_SIZE
 # Generic build system uses -O2, we want -O3
 # Note: No need to add to cflags-y as that happens anyways
-ARCH_CFLAGS += -O3
+#
+# Disable the false maybe-uninitialized warings gcc spits out at -O3
+ARCH_CFLAGS += -O3 $(call cc-disable-warning,maybe-uninitialized,)
 endif
 
 # small data is default for elf32 tool-chain. If not usable, disable it
diff --git a/scripts/Makefile.extrawarn b/scripts/Makefile.extrawarn
index 53449a6..7fc2c5a 100644
--- a/scripts/Makefile.extrawarn
+++ b/scripts/Makefile.extrawarn
@@ -36,6 +36,7 @@ warning-2 += -Wshadow
 warning-2 += $(call cc-option, -Wlogical-op)
 warning-2 += $(call cc-option, -Wmissing-field-initializers)
 warning-2 += $(call cc-option, -Wsign-compare)
+warning-2 += $(call cc-option, -Wmaybe-uninitialized)
 
 warning-3 := -Wbad-function-cast
 warning-3 += -Wcast-qual
@@ -59,6 +60,8 @@ endif
 KBUILD_CFLAGS += $(warning)
 else
 
+KBUILD_CFLAGS += $(call cc-disable-warning, maybe-uninitialized)
+
 ifeq ($(cc-name),clang)
 KBUILD_CFLAGS += $(call cc-disable-warning, initializer-overrides)
 KBUILD_CFLAGS += $(call cc-disable-warning, unused-value)
diff --git a/scripts/Makefile.ubsan b/scripts/Makefile.ubsan
index dd779c4..3b1b138 100644
--- a/scripts/Makefile.ubsan
+++ b/scripts/Makefile.ubsan
@@ -17,4 +17,8 @@ endif
 ifdef CONFIG_UBSAN_NULL
       CFLAGS_UBSAN += $(call cc-option, -fsanitize=null)
 endif
+
+      # -fsanitize=* options makes GCC less smart than usual and
+      # increase number of 'maybe-uninitialized false-positives
+      CFLAGS_UBSAN += $(call cc-option, -Wno-maybe-uninitialized)
 endif
-- 
2.9.0

