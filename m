From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/8] nfs: use different capability flag for v4 and posix acl
Date: Wed,  2 Sep 2009 17:54:24 +0530
Message-ID: <1251894268-1555-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:55628 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbZIBMZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:25:05 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82CP4Gc027816
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:04 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82CP46b1859608
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:04 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82CP3ub001473
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:25:04 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NVFSv4 can now support V4 acl and posix ACL. Use different
flag indicate the capability

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/client.c           |    6 +++---
 fs/nfs/nfs3acl.c          |    8 ++++----
 fs/nfs/nfs4proc.c         |    4 ++--
 fs/nfs/super.c            |    2 +-
 include/linux/nfs_fs_sb.h |    4 ++--
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8d25ccb..ea3a6b7 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -685,17 +685,17 @@ static void nfs_init_server_aclclient(struct nfs_server *server)
 		goto out_noacl;
 
 	/* No errors! Assume that Sun nfsacls are supported */
-	server->caps |= NFS_CAP_ACLS;
+	server->caps |= NFS_CAP_PACLS;
 	return;
 
 out_noacl:
-	server->caps &= ~NFS_CAP_ACLS;
+	server->caps &= ~NFS_CAP_PACLS;
 }
 #else
 static inline void nfs_init_server_aclclient(struct nfs_server *server)
 {
 	server->flags &= ~NFS_MOUNT_NOACL;
-	server->caps &= ~NFS_CAP_ACLS;
+	server->caps &= ~NFS_CAP_PACLS;
 }
 #endif
 
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index bac6051..963b5d6 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -201,7 +201,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 	struct posix_acl *acl;
 	int status, count;
 
-	if (!nfs_server_capable(inode, NFS_CAP_ACLS))
+	if (!nfs_server_capable(inode, NFS_CAP_PACLS))
 		return ERR_PTR(-EOPNOTSUPP);
 
 	status = nfs_revalidate_inode(server, inode);
@@ -242,7 +242,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
 			dprintk("NFS_V3_ACL extension not supported; disabling\n");
-			server->caps &= ~NFS_CAP_ACLS;
+			server->caps &= ~NFS_CAP_PACLS;
 		case -ENOTSUPP:
 			status = -EOPNOTSUPP;
 		default:
@@ -304,7 +304,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	int status;
 
 	status = -EOPNOTSUPP;
-	if (!nfs_server_capable(inode, NFS_CAP_ACLS))
+	if (!nfs_server_capable(inode, NFS_CAP_PACLS))
 		goto out;
 
 	/* We are doing this here, because XDR marshalling can only
@@ -350,7 +350,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		case -EPROTONOSUPPORT:
 			dprintk("NFS_V3_ACL SETACL RPC not supported"
 					"(will not retry)\n");
-			server->caps &= ~NFS_CAP_ACLS;
+			server->caps &= ~NFS_CAP_PACLS;
 		case -ENOTSUPP:
 			status = -EOPNOTSUPP;
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index eb93426..2c71885 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1999,7 +1999,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL)
-			server->caps |= NFS_CAP_ACLS;
+			server->caps |= NFS_CAP_V4ACLS;
 		if (res.has_links != 0)
 			server->caps |= NFS_CAP_HARDLINKS;
 		if (res.has_symlinks != 0)
@@ -3077,7 +3077,7 @@ int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
 
 static inline int nfs4_server_supports_acls(struct nfs_server *server)
 {
-	return (server->caps & NFS_CAP_ACLS)
+	return (server->caps & NFS_CAP_V4ACLS)
 		&& (server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
 		&& (server->acl_bitmask & ACL4_SUPPORT_DENY_ACL);
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2f2a5bd..abe9251 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2317,7 +2317,7 @@ static void nfs4_fill_super(struct super_block *sb)
 
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
-	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3);
+	args->flags &= ~(NFS_MOUNT_NONLM|NFS_CAP_V4ACLS|NFS_MOUNT_VER3);
 }
 
 /*
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 19fe15d..2837ce3 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -165,9 +165,9 @@ struct nfs_server {
 #define NFS_CAP_READDIRPLUS	(1U << 0)
 #define NFS_CAP_HARDLINKS	(1U << 1)
 #define NFS_CAP_SYMLINKS	(1U << 2)
-#define NFS_CAP_ACLS		(1U << 3)
+#define NFS_CAP_PACLS		(1U << 3)
 #define NFS_CAP_ATOMIC_OPEN	(1U << 4)
-
+#define NFS_CAP_V4ACLS		(1U << 8)
 
 /* maximum number of slots to use */
 #define NFS4_MAX_SLOT_TABLE RPC_MAX_SLOT_TABLE
-- 
1.6.4.2.253.g0b1fac

