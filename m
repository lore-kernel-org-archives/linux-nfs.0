Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:49001 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750842AbeBVT2K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Feb 2018 14:28:10 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFS guard against incorrect vers inputs from nfs-utils
Date: Thu, 22 Feb 2018 14:28:06 -0500
Message-ID: <20180222192806.67911-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is possible that userland can pass to the kernel mismatching
inputs for the minorversion. like vers=4.1,minorversion=0. Instead
of making the kernel responposible for 'choosing' the minorversion,
make the userland always responsible for not sending a mismatch.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/super.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 29bacdc..90c0584 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1207,7 +1207,7 @@ static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
-	int rc, sloppy = 0, invalid_option = 0;
+	int rc, sloppy = 0, invalid_option = 0, minorversion = -1;
 	unsigned short protofamily = AF_UNSPEC;
 	unsigned short mountfamily = AF_UNSPEC;
 
@@ -1419,6 +1419,7 @@ static int nfs_parse_mount_options(char *raw,
 			if (option > NFS4_MAX_MINOR_VERSION)
 				goto out_invalid_value;
 			mnt->minorversion = option;
+			minorversion = option;
 			break;
 
 		/*
@@ -1655,6 +1656,9 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
+	if (minorversion >= 0 && minorversion != mnt->minorversion)
+		goto out_mountvers_mismatch;
+
 	return 1;
 
 out_mountproto_mismatch:
@@ -1685,6 +1689,10 @@ static int nfs_parse_mount_options(char *raw,
 	free_secdata(secdata);
 	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
 	return 0;
+out_mountvers_mismatch:
+	printk(KERN_INFO "NFS: mismatch versions supplied vers=4.%d and "
+			 "minorversion=%d\n", mnt->minorversion, minorversion);
+	return 0;
 }
 
 /*
-- 
1.8.3.1

