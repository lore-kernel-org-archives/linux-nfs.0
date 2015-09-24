Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61237 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868AbbIXCTL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 22:19:11 -0400
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.158])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id t8O2JAwl014324
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 19:19:10 -0700 (PDT)
From: roy.qing.li@gmail.com
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsroot: make nfsroot to accept the 1024 bytes long directory name
Date: Thu, 24 Sep 2015 10:19:09 +0800
Message-Id: <1443061149-25153-1-git-send-email-roy.qing.li@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

although NFS_MAXPATHLEN is defined to 1024, nfs client hopes to accept
a 1024 byte path, but nfs_root_parms is limited to 256, and the nfs path
will truncated when a user inputs nfs path from kernel cmdline

enlarge nfs_root_parms to 1024, to make it accept the 1024 bytes long
directory name, since nfs_root_parms is defined as _initdata, it will
be released after system bootup

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 fs/nfs/nfsroot.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 9bc9f04..89a15db 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -90,7 +90,7 @@
 #define NFS_DEF_OPTIONS		"vers=2,udp,rsize=4096,wsize=4096"
 
 /* Parameters passed from the kernel command line */
-static char nfs_root_parms[256] __initdata = "";
+static char nfs_root_parms[NFS_MAXPATHLEN + 1] __initdata = "";
 
 /* Text-based mount options passed to super.c */
 static char nfs_root_options[256] __initdata = NFS_DEF_OPTIONS;
-- 
2.1.4

