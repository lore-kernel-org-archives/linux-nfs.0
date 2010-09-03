Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:59069 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845Ab0ICKNt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Sep 2010 06:13:49 -0400
Date: Fri, 3 Sep 2010 12:13:16 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] fs/nfs: fix build error
Message-ID: <20100903101316.GA387@www.tglx.de>
Content-Type: text/plain; charset=iso-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

|make ARCH=arm pxa3xx_defconfig

on 2.6.36-rc3 caused

| LD      .tmp_vmlinux1
|fs/built-in.o: In function `nfs_callback_authenticate':
|compr_lzo.c:(.text+0x81640): undefined reference to `svc_gss_principal'
|make[1]: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 fs/nfs/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6c2aad4..f7e13db 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -63,6 +63,7 @@ config NFS_V3_ACL
 config NFS_V4
 	bool "NFS client support for NFS version 4"
 	depends on NFS_FS
+	select SUNRPC_GSS
 	help
 	  This option enables support for version 4 of the NFS protocol
 	  (RFC 3530) in the kernel's NFS client.
-- 
1.7.2
