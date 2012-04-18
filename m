Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176Ab2DRRqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:46:34 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/6] NFS: Pass alternate rpc_clnt to fs_locations()
Date: Wed, 18 Apr 2012 13:46:21 -0400
Message-Id: <1334771185-9841-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
References: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

nfs4_proc_lookup() will soon create a new rpc_clnt with the results of a
SECINFO call.  This patch prepares for a referral hidden behind a
mountpoint with a different secflavor.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4_fs.h       |    2 +-
 fs/nfs/nfs4namespace.c |    3 ++-
 fs/nfs/nfs4proc.c      |   17 +++++++++--------
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 97ecc86..41a89d0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -212,7 +212,7 @@ extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
-extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
+extern int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 28a4771..be5268d 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -250,7 +250,8 @@ struct vfsmount *nfs_do_refmount(struct dentry *dentry)
 	dprintk("%s: getting locations for %s/%s\n",
 		__func__, parent->d_name.name, dentry->d_name.name);
 
-	err = nfs4_proc_fs_locations(parent->d_inode, &dentry->d_name, fs_locations, page);
+	err = nfs4_proc_fs_locations(NFS_CLIENT(parent->d_inode), parent->d_inode,
+				     &dentry->d_name, fs_locations, page);
 	dput(parent);
 	if (err != 0 ||
 	    fs_locations->nlocations <= 0 ||
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f82bde0..826c3d5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2368,8 +2368,9 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  * Note that we'll actually follow the referral later when
  * we detect fsid mismatch in inode revalidation
  */
-static int nfs4_get_referral(struct inode *dir, const struct qstr *name,
-			     struct nfs_fattr *fattr, struct nfs_fh *fhandle)
+static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
+			     const struct qstr *name, struct nfs_fattr *fattr,
+			     struct nfs_fh *fhandle)
 {
 	int status = -ENOMEM;
 	struct page *page = NULL;
@@ -2382,7 +2383,7 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name,
 	if (locations == NULL)
 		goto out;
 
-	status = nfs4_proc_fs_locations(dir, name, locations, page);
+	status = nfs4_proc_fs_locations(client, dir, name, locations, page);
 	if (status != 0)
 		goto out;
 	/* Make sure server returned a different fsid for the referral */
@@ -2542,7 +2543,7 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 		case -NFS4ERR_BADNAME:
 			return -ENOENT;
 		case -NFS4ERR_MOVED:
-			return nfs4_get_referral(dir, name, fattr, fhandle);
+			return nfs4_get_referral(clnt, dir, name, fattr, fhandle);
 		case -NFS4ERR_WRONGSEC:
 			nfs_fixup_secinfo_attributes(fattr, fhandle);
 		}
@@ -4891,8 +4892,8 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 	fattr->nlink = 2;
 }
 
-int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
-		struct nfs4_fs_locations *fs_locations, struct page *page)
+int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir, const struct qstr *name,
+			   struct nfs4_fs_locations *fs_locations, struct page *page)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	u32 bitmask[2] = {
@@ -4918,7 +4919,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 
 	/* Ask for the fileid of the absent filesystem if mounted_on_fileid
 	 * is not supported */
-	if (NFS_SERVER(dir)->attr_bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)
+	if (server->attr_bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)
 		bitmask[1] |= FATTR4_WORD1_MOUNTED_ON_FILEID;
 	else
 		bitmask[0] |= FATTR4_WORD0_FILEID;
@@ -4926,7 +4927,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
 }
-- 
1.7.10

