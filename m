Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55946 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756461Ab3GVQmQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 12:42:16 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/4] NFSv4.1 Use clientid management rpc_clnt for fs_locations
Date: Mon, 22 Jul 2013 12:42:06 -0400
Message-ID: <1374511328-49579-2-git-send-email-andros@netapp.com>
In-Reply-To: <1374511328-49579-1-git-send-email-andros@netapp.com>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

As per RFC 3530 and RFC 5661 Security Considerations.

Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
uses the nfs_client cl_rpcclient for all clientid management operations.

Remove un-needed rpc_clnt parameter from nfs4_proc_fs_locations and friends.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h       |  2 +-
 fs/nfs/nfs4namespace.c |  2 +-
 fs/nfs/nfs4proc.c      | 13 +++++++------
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ee81e35..97feff2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -231,7 +231,7 @@ extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
-extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struct qstr *,
+extern int nfs4_proc_fs_locations(struct inode *, const struct qstr *,
 				  struct nfs4_fs_locations *, struct page *);
 extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index cdb0b41..dca2f3a 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -350,7 +350,7 @@ static struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *
 	dprintk("%s: getting locations for %s/%s\n",
 		__func__, parent->d_name.name, dentry->d_name.name);
 
-	err = nfs4_proc_fs_locations(client, parent->d_inode, &dentry->d_name, fs_locations, page);
+	err = nfs4_proc_fs_locations(parent->d_inode, &dentry->d_name, fs_locations, page);
 	dput(parent);
 	if (err != 0 ||
 	    fs_locations->nlocations <= 0 ||
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7a846b6..7761802 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2831,7 +2831,7 @@ err_free_label:
  * Note that we'll actually follow the referral later when
  * we detect fsid mismatch in inode revalidation
  */
-static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
+static int nfs4_get_referral(struct inode *dir,
 			     const struct qstr *name, struct nfs_fattr *fattr,
 			     struct nfs_fh *fhandle)
 {
@@ -2846,7 +2846,7 @@ static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
 	if (locations == NULL)
 		goto out;
 
-	status = nfs4_proc_fs_locations(client, dir, name, locations, page);
+	status = nfs4_proc_fs_locations(dir, name, locations, page);
 	if (status != 0)
 		goto out;
 	/* Make sure server returned a different fsid for the referral */
@@ -3025,7 +3025,7 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 			err = -ENOENT;
 			goto out;
 		case -NFS4ERR_MOVED:
-			err = nfs4_get_referral(client, dir, name, fattr, fhandle);
+			err = nfs4_get_referral(dir, name, fattr, fhandle);
 			goto out;
 		case -NFS4ERR_WRONGSEC:
 			err = -EPERM;
@@ -5733,7 +5733,7 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 	fattr->nlink = 2;
 }
 
-static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
+static int _nfs4_proc_fs_locations(struct inode *dir,
 				   const struct qstr *name,
 				   struct nfs4_fs_locations *fs_locations,
 				   struct page *page)
@@ -5756,6 +5756,7 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	struct rpc_clnt *client = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
 	int status;
 
 	dprintk("%s: start\n", __func__);
@@ -5775,7 +5776,7 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 	return status;
 }
 
-int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
+int nfs4_proc_fs_locations(struct inode *dir,
 			   const struct qstr *name,
 			   struct nfs4_fs_locations *fs_locations,
 			   struct page *page)
@@ -5784,7 +5785,7 @@ int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_fs_locations(client, dir, name, fs_locations, page),
+				_nfs4_proc_fs_locations(dir, name, fs_locations, page),
 				&exception);
 	} while (exception.retry);
 	return err;
-- 
1.8.3.1

