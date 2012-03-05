Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e36.co.us.ibm.com ([32.97.110.154]:55062 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365Ab2CEU2V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 15:28:21 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 13:28:17 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 21D9FC90071
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:27:46 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KQuVK060266
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:27:04 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQtbJ018958
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 17:26:56 -0300
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 04/10] Store objects in nfs4_exception to be used during FHEXPIRED recovery.
Date: Mon,  5 Mar 2012 15:26:45 -0500
Message-Id: <1330979211-894-5-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To successfully recover an expired file handle we'll need either
an inode or preferably a dentry to enable us to recursively walk
back to the root of the export.

v3:
- Add support for getattr recovery by storing the file handle in
nfs4_exception.

v2:
- Added credential storage in the exception object. This will allow
switching credentials on an access error.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4_fs.h  |    4 ++
 fs/nfs/nfs4proc.c |  122 ++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 102 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b133b50..52d7f94 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -183,6 +183,10 @@ struct nfs4_exception {
 	long timeout;
 	int retry;
 	struct nfs4_state *state;
+	struct dentry *dentry;
+	struct inode *inode;
+	struct nfs_fh *fhandle;
+	struct rpc_cred *cred;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ca5e3cd..3706c44 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1260,7 +1260,10 @@ static int _nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
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
@@ -1302,7 +1305,10 @@ static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs
 
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
@@ -1692,7 +1698,10 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
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
@@ -1839,7 +1848,11 @@ out_err:
 
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
 
@@ -1930,7 +1943,10 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
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
@@ -2400,7 +2416,10 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.fhandle = fhandle,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -2505,7 +2524,10 @@ void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
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
@@ -2582,7 +2604,11 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 
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
@@ -2638,7 +2664,10 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
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
@@ -2730,7 +2759,10 @@ out:
 
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
@@ -2885,7 +2917,10 @@ out:
 
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
@@ -2977,7 +3012,10 @@ out:
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
@@ -3008,7 +3046,10 @@ out:
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
@@ -3062,7 +3103,10 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
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
@@ -3110,7 +3154,10 @@ out:
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
@@ -3659,7 +3706,10 @@ out_free:
 
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
@@ -3736,7 +3786,10 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 
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
@@ -4000,7 +4053,10 @@ out:
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
@@ -4074,7 +4130,10 @@ out:
 
 static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -4480,7 +4539,10 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
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
@@ -4498,7 +4560,10 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
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
@@ -4596,7 +4661,10 @@ out:
 
 static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -4656,7 +4724,10 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
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
@@ -4863,7 +4934,10 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 
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

