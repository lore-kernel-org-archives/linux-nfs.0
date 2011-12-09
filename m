Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e2.ny.us.ibm.com ([32.97.182.142]:46719 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784Ab1LIPXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Dec 2011 10:23:49 -0500
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 9 Dec 2011 10:23:47 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB9FNgb2273680
	for <linux-nfs@vger.kernel.org>; Fri, 9 Dec 2011 10:23:42 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB9FNgJN017235
	for <linux-nfs@vger.kernel.org>; Fri, 9 Dec 2011 10:23:42 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v2 3/7] Add VFS objects from nfs4_proc calls into nfs4_exception.
Date: Fri,  9 Dec 2011 10:23:28 -0500
Message-Id: <1323444212-9855-4-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1323444212-9855-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1323444212-9855-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To successfully recover an expired file handle we'll need either
an inode or preferably a dentry to enable us to recursively walk
back to the root of the export.

See nfs4_do_open and nfs4_proc_access for example of how I'm storing
the credentials. I'm not 100% on whether this same method will also apply
for rpciod and state recovery contexts. However, for these examples,
when VFH recovery is initiated by FHEXPIRED being returned for either
operation the credentials are also passed with each lookup.

v2:
- Added credential storage in the exception object. This will allow
  switching credentials on an access error.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4_fs.h  |    3 +
 fs/nfs/nfs4proc.c |  117 ++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 97 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 693ae22..772fbf1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -191,6 +191,9 @@ struct nfs4_exception {
 	long timeout;
 	int retry;
 	struct nfs4_state *state;
+	struct dentry *dentry;
+	struct inode *inode;
+	struct rpc_cred *cred;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6bc393d..5bcc08c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1239,7 +1239,10 @@ static int _nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 static int nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = _nfs4_do_open_reclaim(ctx, state);
@@ -1281,7 +1284,10 @@ static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs
 
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	int err;
 	do {
@@ -1666,7 +1672,10 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
 static int nfs4_do_open_expired(struct nfs_open_context *ctx, struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -1795,7 +1804,11 @@ out_err:
 
 static struct nfs4_state *nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.dentry = dentry,
+		.inode = NULL,
+		.cred = cred,
+	};
 	struct nfs4_state *res;
 	int status;
 
@@ -1886,7 +1899,10 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			   struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -2455,7 +2471,10 @@ void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
 static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
 			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = dir,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		int status;
@@ -2532,7 +2551,11 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 
 static int nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+		.cred = entry->cred,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -2588,7 +2611,10 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
 		unsigned int pgbase, unsigned int pglen)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -2680,7 +2706,10 @@ out:
 
 static int nfs4_proc_remove(struct inode *dir, struct qstr *name)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = dir,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
@@ -2834,7 +2863,10 @@ out:
 
 static int nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -2926,7 +2958,10 @@ out:
 static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 		struct page *page, unsigned int len, struct iattr *sattr)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.dentry = dentry,
+		.inode = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
@@ -2957,7 +2992,10 @@ out:
 static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.dentry = dentry,
+		.inode = NULL,
+	};
 	int err;
 
 	sattr->ia_mode &= ~current_umask();
@@ -3011,7 +3049,10 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		u64 cookie, struct page **pages, unsigned int count, int plus)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.dentry = dentry,
+		.inode = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dentry->d_inode),
@@ -3059,7 +3100,10 @@ out:
 static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr, dev_t rdev)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.dentry = dentry,
+		.inode = NULL,
+	};
 	int err;
 
 	sattr->ia_mode &= ~current_umask();
@@ -3589,7 +3633,10 @@ out_free:
 
 static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+	};
 	ssize_t ret;
 	do {
 		ret = __nfs4_get_acl_uncached(inode, buf, buflen);
@@ -3664,7 +3711,10 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 
 static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -3927,7 +3977,10 @@ out:
 int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = _nfs4_proc_delegreturn(inode, cred, stateid, issync);
@@ -4001,7 +4054,10 @@ out:
 
 static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -4405,7 +4461,10 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -4423,7 +4482,10 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
 static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	err = nfs4_set_lock_state(state, request);
@@ -4501,7 +4563,10 @@ out:
 
 static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -4561,7 +4626,10 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	err = nfs4_set_lock_state(state, fl);
@@ -4768,7 +4836,10 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 
 int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = dir,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-- 
1.7.4.4

