From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] NFS: Use C99 struct initializers in nfs4proc.c
Date: Fri, 25 May 2007 17:41:05 -0400
Message-ID: <20070525214105.28668.75496.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrhX2-0003yL-L5
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:08 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrhX5-0002SA-9I
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:11 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Follow kernel coding conventions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h  |    5 ++++
 fs/nfs/nfs4proc.c |   70 ++++++++++++++++++++++++++++-------------------------
 2 files changed, 42 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cf3a17e..1a526c4 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -145,6 +145,11 @@ struct nfs4_exception {
 	int retry;
 };
 
+#define DECLARE_NFS4_EXCEPTION(name)				\
+	struct nfs4_exception name = {				\
+		.timeout	= 0,				\
+	}
+
 struct nfs4_state_recovery_ops {
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 648e0ac..b220c09 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -493,7 +493,7 @@ static int _nfs4_do_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state
 static int nfs4_do_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *state, struct dentry *dentry)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = _nfs4_do_open_reclaim(sp, state, dentry);
@@ -538,8 +538,8 @@ static int _nfs4_open_delegation_recall(struct dentry *dentry, struct nfs4_state
 
 int nfs4_open_delegation_recall(struct dentry *dentry, struct nfs4_state *state)
 {
-	struct nfs4_exception exception = { };
 	struct nfs_server *server = NFS_SERVER(dentry->d_inode);
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = _nfs4_open_delegation_recall(dentry, state);
@@ -843,7 +843,7 @@ static int _nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 static inline int nfs4_do_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state, struct dentry *dentry)
 {
 	struct nfs_server *server = NFS_SERVER(dentry->d_inode);
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	do {
@@ -938,8 +938,8 @@ out_put_state_owner:
 
 static struct nfs4_state *nfs4_open_delegated(struct inode *inode, int flags, struct rpc_cred *cred)
 {
-	struct nfs4_exception exception = { };
 	struct nfs4_state *res = ERR_PTR(-EIO);
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	do {
@@ -1008,7 +1008,7 @@ out_err:
 
 static struct nfs4_state *nfs4_do_open(struct inode *dir, struct dentry *dentry, int flags, struct iattr *sattr, struct rpc_cred *cred)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	struct nfs4_state *res;
 	int status;
 
@@ -1090,7 +1090,7 @@ static int nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
                 struct iattr *sattr, struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -1330,7 +1330,9 @@ out_drop:
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
-	struct nfs4_server_caps_res res = {};
+	struct nfs4_server_caps_res res = {
+		.acl_bitmask = 0,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SERVER_CAPS],
 		.rpc_argp = fhandle,
@@ -1354,7 +1356,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 
 int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -1387,7 +1389,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		struct nfs_fsinfo *info)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -1476,7 +1478,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -1568,7 +1570,7 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
 			      struct qstr *name, struct nfs_fh *fhandle,
 			      struct nfs_fattr *fattr)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -1612,7 +1614,7 @@ static int _nfs4_proc_lookup(struct inode *dir, struct qstr *name,
 
 static int nfs4_proc_lookup(struct inode *dir, struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
@@ -1627,7 +1629,9 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	struct nfs4_accessargs args = {
 		.fh = NFS_FH(inode),
 	};
-	struct nfs4_accessres res = { 0 };
+	struct nfs4_accessres res = {
+		.access = 0,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
 		.rpc_argp = &args,
@@ -1668,7 +1672,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 
 static int nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -1723,7 +1727,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
 		unsigned int pgbase, unsigned int pglen)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -1813,7 +1817,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 
 static int nfs4_proc_remove(struct inode *dir, struct qstr *name)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
@@ -1907,7 +1911,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 static int nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(old_dir),
@@ -1954,7 +1958,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 
 static int nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -2011,7 +2015,7 @@ static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 		struct page *page, unsigned int len, struct iattr *sattr)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
@@ -2064,7 +2068,7 @@ static int _nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
@@ -2110,7 +2114,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
                   u64 cookie, struct page *page, unsigned int count, int plus)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dentry->d_inode),
@@ -2180,7 +2184,7 @@ static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr, dev_t rdev)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
@@ -2209,7 +2213,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -2237,7 +2241,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	do {
@@ -2280,7 +2284,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 		struct nfs_pathconf *pathconf)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	do {
@@ -2599,7 +2603,7 @@ out_free:
 
 static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	ssize_t ret;
 	do {
 		ret = __nfs4_get_acl_uncached(inode, buf, buflen);
@@ -2653,7 +2657,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 
 static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -2950,7 +2954,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 	do {
 		err = _nfs4_proc_delegreturn(inode, cred, stateid);
@@ -3025,7 +3029,7 @@ out:
 
 static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	do {
@@ -3354,7 +3358,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	do {
@@ -3372,7 +3376,7 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
 static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	err = nfs4_set_lock_state(state, request);
@@ -3433,7 +3437,7 @@ out:
 
 static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	do {
@@ -3483,7 +3487,7 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	DECLARE_NFS4_EXCEPTION(exception);
 	int err;
 
 	err = nfs4_set_lock_state(state, fl);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
