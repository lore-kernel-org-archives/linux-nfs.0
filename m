From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/6] SUNRPC: Add a helper rpcauth_lookup_generic_cred()
Date: Thu, 13 Mar 2008 13:48:11 -0400
Message-ID: <20080313174810.13840.87427.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61939 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086AbYCMSCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 14:02:06 -0400
In-Reply-To: <20080313174806.13840.90325.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 protocol allows clients to negotiate security protocols on the
fly in the case where an administrator on the server changes the export
settings and/or in the case where we may have a filesystem migration event.

Instead of having the NFS client code cache credentials that are tied to a
particular AUTH method it is therefore preferable to have a generic credential
that can be converted into whatever AUTH is in use by the RPC client when
the read/write/sillyrename/... is put on the wire.

We do this by means of the new "generic" credential, which basically just
caches the minimal information that is needed to look up an RPCSEC_GSS,
AUTH_SYS, or AUTH_NULL credential.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c      |    2 +-
 fs/nfs/inode.c    |    2 +-
 fs/nfs/nfs4proc.c |    8 ++++----
 fs/nfs/unlink.c   |    2 +-
 net/sunrpc/auth.c |    1 -
 5 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6cea747..d583654 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1966,7 +1966,7 @@ force_lookup:
 	if (!NFS_PROTO(inode)->access)
 		goto out_notsup;
 
-	cred = rpcauth_lookupcred(NFS_CLIENT(inode)->cl_auth, 0);
+	cred = rpc_lookup_cred();
 	if (!IS_ERR(cred)) {
 		res = nfs_do_access(inode, cred, mask);
 		put_rpccred(cred);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c49f6d8..15f7873 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -613,7 +613,7 @@ int nfs_open(struct inode *inode, struct file *filp)
 	struct nfs_open_context *ctx;
 	struct rpc_cred *cred;
 
-	cred = rpcauth_lookupcred(NFS_CLIENT(inode)->cl_auth, 0);
+	cred = rpc_lookup_cred();
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
 	ctx = alloc_nfs_open_context(filp->f_path.mnt, filp->f_path.dentry, cred);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bbb0d58..f38d057 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1408,7 +1408,7 @@ nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 		BUG_ON(nd->intent.open.flags & O_CREAT);
 	}
 
-	cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
+	cred = rpc_lookup_cred();
 	if (IS_ERR(cred))
 		return (struct dentry *)cred;
 	parent = dentry->d_parent;
@@ -1443,7 +1443,7 @@ nfs4_open_revalidate(struct inode *dir, struct dentry *dentry, int openflags, st
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
 
-	cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
+	cred = rpc_lookup_cred();
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
 	state = nfs4_do_open(dir, &path, openflags, NULL, cred);
@@ -1660,7 +1660,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 	nfs_fattr_init(fattr);
 	
-	cred = rpcauth_lookupcred(NFS_CLIENT(inode)->cl_auth, 0);
+	cred = rpc_lookup_cred();
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
 
@@ -1896,7 +1896,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct rpc_cred *cred;
 	int status = 0;
 
-	cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
+	cred = rpc_lookup_cred();
 	if (IS_ERR(cred)) {
 		status = PTR_ERR(cred);
 		goto out;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 7574153..3adf8b2 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -234,7 +234,7 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 	if (data == NULL)
 		goto out;
 
-	data->cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
+	data->cred = rpc_lookup_cred();
 	if (IS_ERR(data->cred)) {
 		status = PTR_ERR(data->cred);
 		goto out_free;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index d65dd79..0632cd0 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -356,7 +356,6 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 	put_group_info(acred.group_info);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(rpcauth_lookupcred);
 
 void
 rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,

