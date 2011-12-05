Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab1LEINL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:13:11 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:13:10 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] efi: fix user-land debug printouts
Date: Mon,  5 Dec 2011 10:13:05 +0200
Message-Id: <1323072785-18038-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 efi.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/efi.c b/efi.c
index 20efb2b..b653092 100644
--- a/efi.c
+++ b/efi.c
@@ -98,9 +98,12 @@
 
 #include "efi.h"
 
+#ifndef EFI_DEBUG
+#define EFI_DEBUG
+#endif
 #undef EFI_DEBUG
 #ifdef EFI_DEBUG
-#define Dprintk(x...) printk(KERN_DEBUG x)
+#define Dprintk(x...) fprintf(stderr, x)
 #else
 #define Dprintk(x...)
 #endif
-- 
1.7.6

