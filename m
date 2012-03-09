Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031077Ab2CITtx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:49:53 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29Jnr09027406
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:49:53 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 4/7] Kill SPKM3: Remove spkm3 support from nfs.mount
Date: Fri,  9 Mar 2012 14:49:43 -0500
Message-Id: <1331322586-4631-5-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/mount/nfs.man     |    7 ++-----
 utils/mount/nfs_mount.h |    3 ---
 utils/mount/nfsmount.c  |    6 ------
 3 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2ad92d1e55c7aab52c24fee64da11f6a25985999..810bfc075cb2629beedb8738f60e3f5fdf771f1e 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -375,11 +375,8 @@ Valid security flavors are
 .BR krb5p ,
 .BR lkey ,
 .BR lkeyi ,
+and
 .BR lkeyp ,
-.BR spkm ,
-.BR spkmi ,
-and
-.BR spkmp .
 Refer to the SECURITY CONSIDERATIONS section for details.
 .TP 1.5i
 .BR sharecache " / " nosharecache
@@ -1416,7 +1413,7 @@ security flavor encrypts every RPC request
 to prevent data exposure during network transit; however,
 expect some performance impact
 when using integrity checking or encryption.
-Similar support for other forms of cryptographic security (such as lipkey and SPKM3)
+Similar support for other forms of cryptographic security (such as lipkey)
 is also available.
 .P
 The NFS version 4 protocol allows
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 2becfb1a0d655093385f47571b026124218fcf46..ec30c9b62a6da09c8671e3b8b7c995e1ef7f7e3c 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -75,9 +75,6 @@ struct nfs_mount_data {
 #define AUTH_GSS_LKEY		390006
 #define AUTH_GSS_LKEYI		390007
 #define AUTH_GSS_LKEYP		390008
-#define AUTH_GSS_SPKM		390009
-#define AUTH_GSS_SPKMI		390010
-#define AUTH_GSS_SPKMP		390011
 #endif
 
 int	nfsmount(const char *, const char *, int , char **, int, int);
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 1298fe44485789bae59cc10cf7430c2599b4f5a5..7bd1c97b291eb585221452ba865036d25e7fa8ff 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -300,12 +300,6 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 					data->pseudoflavor = AUTH_GSS_LKEYI;
 				else if (!strcmp(secflavor, "lipkey-p"))
 					data->pseudoflavor = AUTH_GSS_LKEYP;
-				else if (!strcmp(secflavor, "spkm3"))
-					data->pseudoflavor = AUTH_GSS_SPKM;
-				else if (!strcmp(secflavor, "spkm3i"))
-					data->pseudoflavor = AUTH_GSS_SPKMI;
-				else if (!strcmp(secflavor, "spkm3p"))
-					data->pseudoflavor = AUTH_GSS_SPKMP;
 				else if (sloppy)
 					continue;
 				else {
-- 
1.7.7.6

