Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363Ab1JSUuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:39 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] NFS: Remove the unused "lookupfh()" version of nfs4_proc_lookup()
Date: Wed, 19 Oct 2011 13:50:11 -0700
Message-Id: <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and also remove the associated nfs_v4_clientops entry.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       |   62 +++++++++++++----------------------------------
 include/linux/nfs_xdr.h |    3 --
 2 files changed, 17 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0f0b607..b0c01b2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -73,9 +73,6 @@ static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
-static int _nfs4_proc_lookup(struct rpc_clnt *client, struct inode *dir,
-			     const struct qstr *name, struct nfs_fh *fhandle,
-			     struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -2408,14 +2405,15 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	return status;
 }
 
-static int _nfs4_proc_lookupfh(struct rpc_clnt *clnt, struct nfs_server *server,
-		const struct nfs_fh *dirfh, const struct qstr *name,
-		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
+		const struct qstr *name, struct nfs_fh *fhandle,
+		struct nfs_fattr *fattr)
 {
+	struct nfs_server *server = NFS_SERVER(dir);
 	int		       status;
 	struct nfs4_lookup_arg args = {
 		.bitmask = server->attr_bitmask,
-		.dir_fh = dirfh,
+		.dir_fh = NFS_FH(dir),
 		.name = name,
 	};
 	struct nfs4_lookup_res res = {
@@ -2431,40 +2429,8 @@ static int _nfs4_proc_lookupfh(struct rpc_clnt *clnt, struct nfs_server *server,
 
 	nfs_fattr_init(fattr);
 
-	dprintk("NFS call  lookupfh %s\n", name->name);
-	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args, &res.seq_res, 0);
-	dprintk("NFS reply lookupfh: %d\n", status);
-	return status;
-}
-
-static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
-			      struct qstr *name, struct nfs_fh *fhandle,
-			      struct nfs_fattr *fattr)
-{
-	struct nfs4_exception exception = { };
-	int err;
-	do {
-		err = _nfs4_proc_lookupfh(server->client, server, dirfh, name, fhandle, fattr);
-		/* FIXME: !!!! */
-		if (err == -NFS4ERR_MOVED) {
-			err = -EREMOTE;
-			break;
-		}
-		err = nfs4_handle_exception(server, err, &exception);
-	} while (exception.retry);
-	return err;
-}
-
-static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
-		const struct qstr *name, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
-{
-	int status;
-	
 	dprintk("NFS call  lookup %s\n", name->name);
-	status = _nfs4_proc_lookupfh(clnt, NFS_SERVER(dir), NFS_FH(dir), name, fhandle, fattr);
-	if (status == -NFS4ERR_MOVED)
-		status = nfs4_get_referral(dir, name, fattr, fhandle);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("NFS reply lookup: %d\n", status);
 	return status;
 }
@@ -2485,11 +2451,18 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_lookup(clnt, dir, name, fhandle, fattr),
-				&exception);
-		if (err == -EPERM)
+		int status;
+
+		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
+		switch (status) {
+		case -NFS4ERR_MOVED:
+			err = nfs4_get_referral(dir, name, fattr, fhandle);
+			break;
+		case -NFS4ERR_WRONGSEC:
 			nfs_fixup_secinfo_attributes(fattr, fhandle);
+		}
+		err = nfs4_handle_exception(NFS_SERVER(dir),
+				status, &exception);
 	} while (exception.retry);
 	return err;
 }
@@ -6270,7 +6243,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.getroot	= nfs4_proc_get_root,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
-	.lookupfh	= nfs4_proc_lookupfh,
 	.lookup		= nfs4_proc_lookup,
 	.access		= nfs4_proc_access,
 	.readlink	= nfs4_proc_readlink,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index abd615d..1e31e1c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1197,9 +1197,6 @@ struct nfs_rpc_ops {
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
-	int	(*lookupfh)(struct nfs_server *, struct nfs_fh *,
-			    struct qstr *, struct nfs_fh *,
-			    struct nfs_fattr *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
-- 
1.7.6.4

