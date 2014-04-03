Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f48.google.com ([209.85.160.48]:48891 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbaDCRxv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Apr 2014 13:53:51 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so2197343pbc.21
        for <linux-nfs@vger.kernel.org>; Thu, 03 Apr 2014 10:53:51 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
To: "H. Peter Anvin" <hpa@linux.intel.com>,
        Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH] x86, vdso: Make the vdso linker script compatible with Gold
Date: Thu,  3 Apr 2014 10:53:43 -0700
Message-Id: <243fa205098d112ec759c9b1b26785c09f399833.1396547532.git.luto@amacapital.net>
In-Reply-To: <20140403174339.GA284@x4>
References: <20140403174339.GA284@x4>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Gold can't parse the script due to:
https://sourceware.org/bugzilla/show_bug.cgi?id=16804

With a workaround in place for that issue, Gold 2.23 crashes due to:
https://sourceware.org/bugzilla/show_bug.cgi?id=15355

This works around the former bug and avoids the second by removing
the unnecessary vvar and hpet sections and segments.  The vdso and
hpet symbols are still there, and nothing needed the sections or
segments.

Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 arch/x86/vdso/vdso-layout.lds.S | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/arch/x86/vdso/vdso-layout.lds.S b/arch/x86/vdso/vdso-layout.lds.S
index 2e263f3..9df017a 100644
--- a/arch/x86/vdso/vdso-layout.lds.S
+++ b/arch/x86/vdso/vdso-layout.lds.S
@@ -9,12 +9,9 @@ SECTIONS
 #ifdef BUILD_VDSO32
 #include <asm/vdso32.h>
 
-	.hpet_sect : {
-		hpet_page = . - VDSO_OFFSET(VDSO_HPET_PAGE);
-	} :text :hpet_sect
+	hpet_page = . - VDSO_OFFSET(VDSO_HPET_PAGE);
 
-	.vvar_sect : {
-		vvar = . - VDSO_OFFSET(VDSO_VVAR_PAGE);
+	vvar = . - VDSO_OFFSET(VDSO_VVAR_PAGE);
 
 	/* Place all vvars at the offsets in asm/vvar.h. */
 #define EMIT_VVAR(name, offset) vvar_ ## name = vvar + offset;
@@ -22,7 +19,6 @@ SECTIONS
 #include <asm/vvar.h>
 #undef __VVAR_KERNEL_LDS
 #undef EMIT_VVAR
-	} :text :vvar_sect
 #endif
 	. = SIZEOF_HEADERS;
 
@@ -61,7 +57,12 @@ SECTIONS
 	 */
 	. = ALIGN(0x100);
 
-	.text		: { *(.text*) }			:text	=0x90909090
+	.text		: { *(.text*) }			:text	=0x90909090,
+
+	/*
+	 * The comma above works around a bug in gold:
+	 * https://sourceware.org/bugzilla/show_bug.cgi?id=16804
+	 */
 
 	/DISCARD/ : {
 		*(.discard)
@@ -84,8 +85,4 @@ PHDRS
 	dynamic		PT_DYNAMIC	FLAGS(4);		/* PF_R */
 	note		PT_NOTE		FLAGS(4);		/* PF_R */
 	eh_frame_hdr	PT_GNU_EH_FRAME;
-#ifdef BUILD_VDSO32
-	vvar_sect	PT_NULL		FLAGS(4);		/* PF_R */
-	hpet_sect	PT_NULL		FLAGS(4);		/* PF_R */
-#endif
 }
-- 
1.9.0

