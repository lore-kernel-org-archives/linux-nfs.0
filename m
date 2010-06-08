Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:2287 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751699Ab0FHIrG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 04:47:06 -0400
Message-ID: <4C0E0387.8070502@panasas.com>
Date: Tue, 08 Jun 2010 11:47:03 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SQUASHME: DEVONLY: pnfs: Add -pnfs suffix to EXTRAVERSION
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The official way of adding a tree identifier tag to the Kernel
version-string is a presence of a localversion-* file next to
the Makefile. It's content is appended to the Linus supplied
version-string from Makefile.

After this patch the output is the same as before xxx-2.6.35-rc2-pnfs
But is a more comfortable way to manage it.

(The appended "+" in post 2.6.35-rc Kernels is not resolved with
 this. But I have sent a patch to Linus to fix this issue)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 Makefile          |    2 +-
 localversion-pnfs |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)
 create mode 100644 localversion-pnfs

diff --git a/Makefile b/Makefile
index 6ac434c..654c31a 100644
--- a/Makefile
+++ b/Makefile
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 6
 SUBLEVEL = 35
-EXTRAVERSION = -rc2-pnfs
+EXTRAVERSION = -rc2
 NAME = Sheep on Meth
 
 # *DOCUMENTATION*
diff --git a/localversion-pnfs b/localversion-pnfs
new file mode 100644
index 0000000..7523328
--- /dev/null
+++ b/localversion-pnfs
@@ -0,0 +1 @@
+-pnfs
-- 
1.6.6.1

