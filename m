Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833Ab2CBTHQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 14:07:16 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Extend the -overs= mount option to allow 4.x minorversions
Date: Fri,  2 Mar 2012 14:07:09 -0500
Message-Id: <1330715231-20650-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the user to mount an NFSv4.0 or NFSv4.1 partition using a
standard syntax of '-overs=4.0', or '-overs=4.1' rather than the
more cumbersome '-overs=4,minorversion=1'.

See also the earlier patch by Dros Adamson, which added the
Linux-specific syntax '-ov4.0', '-ov4.1'.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   84 +++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8154acc..ab58bb9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -98,10 +98,10 @@ enum {
 	Opt_namelen,
 	Opt_mountport,
 	Opt_mountvers,
-	Opt_nfsvers,
 	Opt_minorversion,
 
 	/* Mount options that take string arguments */
+	Opt_nfsvers,
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 	Opt_lookupcache,
@@ -166,9 +166,10 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_namelen, "namlen=%s" },
 	{ Opt_mountport, "mountport=%s" },
 	{ Opt_mountvers, "mountvers=%s" },
+	{ Opt_minorversion, "minorversion=%s" },
+
 	{ Opt_nfsvers, "nfsvers=%s" },
 	{ Opt_nfsvers, "vers=%s" },
-	{ Opt_minorversion, "minorversion=%s" },
 
 	{ Opt_sec, "sec=%s" },
 	{ Opt_proto, "proto=%s" },
@@ -262,6 +263,22 @@ static match_table_t nfs_local_lock_tokens = {
 	{ Opt_local_lock_err, NULL }
 };
 
+enum {
+	Opt_vers_2, Opt_vers_3, Opt_vers_4, Opt_vers_4_0,
+	Opt_vers_4_1,
+
+	Opt_vers_err
+};
+
+static match_table_t nfs_vers_tokens = {
+	{ Opt_vers_2, "2" },
+	{ Opt_vers_3, "3" },
+	{ Opt_vers_4, "4" },
+	{ Opt_vers_4_0, "4.0" },
+	{ Opt_vers_4_1, "4.1" },
+
+	{ Opt_vers_err, NULL }
+};
 
 static void nfs_umount_begin(struct super_block *);
 static int  nfs_statfs(struct dentry *, struct kstatfs *);
@@ -1064,6 +1081,40 @@ static int nfs_parse_security_flavors(char *value,
 	return 1;
 }
 
+static int nfs_parse_version_string(char *string,
+		struct nfs_parsed_mount_data *mnt,
+		substring_t *args)
+{
+	mnt->flags &= ~NFS_MOUNT_VER3;
+	switch (match_token(string, nfs_vers_tokens, args)) {
+	case Opt_vers_2:
+		mnt->version = 2;
+		break;
+	case Opt_vers_3:
+		mnt->flags |= NFS_MOUNT_VER3;
+		mnt->version = 3;
+		break;
+	case Opt_vers_4:
+		/* Backward compatibility option. In future,
+		 * the mount program should always supply
+		 * a NFSv4 minor version number.
+		 */
+		mnt->version = 4;
+		break;
+	case Opt_vers_4_0:
+		mnt->version = 4;
+		mnt->minorversion = 0;
+		break;
+	case Opt_vers_4_1:
+		mnt->version = 4;
+		mnt->minorversion = 1;
+		break;
+	default:
+		return 0;
+	}
+	return 1;
+}
+
 static int nfs_get_option_str(substring_t args[], char **option)
 {
 	kfree(*option);
@@ -1317,26 +1368,6 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_invalid_value;
 			mnt->mount_server.version = option;
 			break;
-		case Opt_nfsvers:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			switch (option) {
-			case NFS2_VERSION:
-				mnt->flags &= ~NFS_MOUNT_VER3;
-				mnt->version = 2;
-				break;
-			case NFS3_VERSION:
-				mnt->flags |= NFS_MOUNT_VER3;
-				mnt->version = 3;
-				break;
-			case NFS4_VERSION:
-				mnt->flags &= ~NFS_MOUNT_VER3;
-				mnt->version = 4;
-				break;
-			default:
-				goto out_invalid_value;
-			}
-			break;
 		case Opt_minorversion:
 			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
@@ -1348,6 +1379,15 @@ static int nfs_parse_mount_options(char *raw,
 		/*
 		 * options that take text values
 		 */
+		case Opt_nfsvers:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			rc = nfs_parse_version_string(string, mnt, args);
+			kfree(string);
+			if (!rc)
+				goto out_invalid_value;
+			break;
 		case Opt_sec:
 			string = match_strdup(args);
 			if (string == NULL)
-- 
1.7.7.6

