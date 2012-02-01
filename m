Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6291 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996Ab2BATGo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 14:06:44 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] NFS: dont allow minorversion= opt when vers != 4
Date: Wed,  1 Feb 2012 14:06:41 -0500
Message-Id: <1328123201-894-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow invalid 'vers' and 'minorversion' combinations in mount options,
such as "vers=3,minorversion=1".

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
%d -> %u for printing mnt->version.

 fs/nfs/super.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8e210b2..b88e023 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1519,6 +1519,9 @@ static int nfs_parse_mount_options(char *raw,
 	if (!sloppy && invalid_option)
 		return 0;
 
+	if (mnt->minorversion && mnt->version != 4)
+		goto out_minorversion_mismatch;
+
 	/*
 	 * verify that any proto=/mountproto= options match the address
 	 * familiies in the addr=/mountaddr= options.
@@ -1552,6 +1555,10 @@ out_invalid_address:
 out_invalid_value:
 	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", p);
 	return 0;
+out_minorversion_mismatch:
+	printk(KERN_INFO "NFS: mount option vers=%u does not support "
+			 "minorversion=%u\n", mnt->version, mnt->minorversion);
+	return 0;
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return 0;
-- 
1.7.4.4

