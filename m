Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:58038 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab1KKXFz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 18:05:55 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 16:05:54 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABN5oAC116976
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:50 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABN5num012795
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:49 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC 3/7] Add VFS objects from nfs4_proc calls into  nfs4_exception.
Date: Fri, 11 Nov 2011 18:04:28 -0500
Message-Id: <1321052673-22171-4-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To successfully recover an expired file handle we'll need either
an inode or preferably a dentry to enable us to recursively walk
back to the root of the export.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4_fs.h  |    2 +
 fs/nfs/nfs4proc.c |  115 ++++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 94 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3e93e9a..8fe81d8 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -215,6 +215,8 @@ struct nfs4_exception {
 	long timeout;
 	int retry;
 	struct nfs4_state *state;
+	struct dentry *dentry;
+	struct inode *inode;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 86c273e..20b96cb 100644
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
@@ -1795,7 +1804,10 @@ out_err:
 
 static struct nfs4_state *nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.dentry = dentry,
+		.inode = NULL,
+	};
 	struct nfs4_state *res;
 	int status;
 
@@ -1886,7 +1898,10 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
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
@@ -2455,7 +2470,10 @@ void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
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
@@ -2533,7 +2551,10 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 
 static int nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = inode,
+		.dentry = NULL,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -2589,7 +2610,10 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
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
@@ -2681,7 +2705,10 @@ out:
 
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
@@ -2835,7 +2862,10 @@ out:
 
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
@@ -2927,7 +2957,10 @@ out:
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
@@ -2958,7 +2991,10 @@ out:
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
@@ -3012,7 +3048,10 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
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
@@ -3060,7 +3099,10 @@ out:
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
@@ -3590,7 +3632,10 @@ out_free:
 
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
@@ -3665,7 +3710,10 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 
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
@@ -3928,7 +3976,10 @@ out:
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
@@ -4002,7 +4053,10 @@ out:
 
 static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -4406,7 +4460,10 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
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
@@ -4424,7 +4481,10 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
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
@@ -4502,7 +4562,10 @@ out:
 
 static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+		.dentry = NULL,
+	};
 	int err;
 
 	do {
@@ -4562,7 +4625,10 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
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
@@ -4769,7 +4835,10 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 
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

