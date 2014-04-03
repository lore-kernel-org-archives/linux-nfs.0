Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ud10.udmedia.de ([194.117.254.50]:38071 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbaDCRnl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Apr 2014 13:43:41 -0400
Date: Thu, 3 Apr 2014 19:43:39 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
To: linux-nfs@vger.kernel.org
Cc: Andy Lutomirski <luto@amacapital.net>,
        "H. Peter Anvin" <hpa@linux.intel.com>
Subject: [PATCH] x86, vdso: Fix vdso-layout linker script
Message-ID: <20140403174339.GA284@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 26f5ef2e3c3 added a /DISCARD/ section to the vdso-layout.lds.S
linker script. This broke the build when using the gold linker:

 ld: error: arch/x86/vdso/vdso.lds:79:12: syntax error, unexpected ':'
 ld: fatal error: unable to parse script file arch/x86/vdso/vdso.lds

As Cary Coutant pointed out on the sourceware bugzilla: 
https://sourceware.org/bugzilla/show_bug.cgi?id=16804  
the problem is that the .text section directly above the /DISCARD/
section should be terminated with an comma.

Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>

diff --git a/arch/x86/vdso/vdso-layout.lds.S b/arch/x86/vdso/vdso-layout.lds.S
index 2e263f367b13..313bca59ddea 100644
--- a/arch/x86/vdso/vdso-layout.lds.S
+++ b/arch/x86/vdso/vdso-layout.lds.S
@@ -61,7 +61,7 @@ SECTIONS
 	 */
 	. = ALIGN(0x100);
 
-	.text		: { *(.text*) }			:text	=0x90909090
+	.text		: { *(.text*) }			:text	=0x90909090,
 
 	/DISCARD/ : {
 		*(.discard)
-- 
Markus
