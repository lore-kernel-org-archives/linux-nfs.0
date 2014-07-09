Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f51.google.com ([209.85.220.51]:48823 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182AbaGINyY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 09:54:24 -0400
Received: by mail-pa0-f51.google.com with SMTP id hz1so9182866pad.24
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jul 2014 06:54:24 -0700 (PDT)
Message-ID: <53BD4988.6020302@gmail.com>
Date: Wed, 09 Jul 2014 21:54:16 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Check acl returned from get_acl/posix_acl_from_mode
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 4ac7249ea5 (nfsd: use get_acl and ->set_acl)
don't check the acl returned from get_acl()/posix_acl_from_mode().

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs2acl.c |  8 ++++----
 fs/nfsd/nfs3acl.c |  8 ++++----
 fs/nfsd/nfs4acl.c | 19 +++++++++++++------
 3 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 12b023a..ac54ea6 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -54,14 +54,14 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst * rqstp,
 
 	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
 		acl = get_acl(inode, ACL_TYPE_ACCESS);
-		if (IS_ERR(acl)) {
-			nfserr = nfserrno(PTR_ERR(acl));
-			goto fail;
-		}
 		if (acl == NULL) {
 			/* Solaris returns the inode's minimum ACL. */
 			acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		}
+		if (IS_ERR(acl)) {
+			nfserr = nfserrno(PTR_ERR(acl));
+			goto fail;
+		}
 		resp->acl_access = acl;
 	}
 	if (resp->mask & (NFS_DFACL|NFS_DFACLCNT)) {
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 2a514e2..34cbbab 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -47,14 +47,14 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst * rqstp,
 
 	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
 		acl = get_acl(inode, ACL_TYPE_ACCESS);
-		if (IS_ERR(acl)) {
-			nfserr = nfserrno(PTR_ERR(acl));
-			goto fail;
-		}
 		if (acl == NULL) {
 			/* Solaris returns the inode's minimum ACL. */
 			acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		}
+		if (IS_ERR(acl)) {
+			nfserr = nfserrno(PTR_ERR(acl));
+			goto fail;
+		}
 		resp->acl_access = acl;
 	}
 	if (resp->mask & (NFS_DFACL|NFS_DFACLCNT)) {
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index acf6974..59fd766 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -146,17 +146,23 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 	int size = 0;
 
 	pacl = get_acl(inode, ACL_TYPE_ACCESS);
-	if (!pacl) {
+	if (!pacl)
 		pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
-		if (IS_ERR(pacl))
-			return PTR_ERR(pacl);
-	}
+
+	if (IS_ERR(pacl))
+		return PTR_ERR(pacl);
+
 	/* allocate for worst case: one (deny, allow) pair each: */
 	size += 2 * pacl->a_count;
 
 	if (S_ISDIR(inode->i_mode)) {
 		flags = NFS4_ACL_DIR;
 		dpacl = get_acl(inode, ACL_TYPE_DEFAULT);
+		if (IS_ERR(dpacl)) {
+			error = PTR_ERR(dpacl);
+			goto rel_pacl;
+		}
+
 		if (dpacl)
 			size += 2 * dpacl->a_count;
 	}
@@ -173,9 +179,10 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 	if (dpacl)
 		_posix_to_nfsv4_one(dpacl, *acl, flags | NFS4_ACL_TYPE_DEFAULT);
 
- out:
-	posix_acl_release(pacl);
+out:
 	posix_acl_release(dpacl);
+rel_pacl:
+	posix_acl_release(pacl);
 	return error;
 }
 
-- 
1.9.3

