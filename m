Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Thu, 13 Oct 2016 15:26:47 +1100
Subject: [PATCH 3/6] NFSv4: change nfs4_do_setattr to take an open_context
 instead of a nfs4_state.
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147633280745.766.9047567139865023402.stgit@noble>
In-Reply-To: <147633263771.766.17853370901003798934.stgit@noble>
References: <147633263771.766.17853370901003798934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

The open_context can always lead directly to the state, and is always easily
available, so this is a straightforward change.
Doing this makes more information available to _nfs4_do_setattr() for use
in the next patch.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/nfs4proc.c |   28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3d85ab7b56bf..950b25413bb4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -94,7 +94,7 @@ static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fa
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
-			    struct nfs4_state *state, struct nfs4_label *ilabel,
+			    struct nfs_open_context *ctx, struct nfs4_label *ilabel,
 			    struct nfs4_label *olabel);
 #ifdef CONFIG_NFS_V4_1
 static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
@@ -2807,7 +2807,7 @@ static int _nfs4_do_open(struct inode *dir,
 			nfs_fattr_init(opendata->o_res.f_attr);
 			status = nfs4_do_setattr(state->inode, cred,
 					opendata->o_res.f_attr, sattr,
-					state, label, olabel);
+					ctx, label, olabel);
 			if (status == 0) {
 				nfs_setattr_update_inode(state->inode, sattr,
 						opendata->o_res.f_attr);
@@ -2902,7 +2902,7 @@ static int _nfs4_do_setattr(struct inode *inode,
 			    struct nfs_setattrargs *arg,
 			    struct nfs_setattrres *res,
 			    struct rpc_cred *cred,
-			    struct nfs4_state *state)
+			    struct nfs_open_context *ctx)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
         struct rpc_message msg = {
@@ -2925,13 +2925,13 @@ static int _nfs4_do_setattr(struct inode *inode,
 
 	if (nfs4_copy_delegation_stateid(inode, fmode, &arg->stateid, &delegation_cred)) {
 		/* Use that stateid */
-	} else if (truncate && state != NULL) {
+	} else if (truncate && ctx != NULL) {
 		struct nfs_lockowner lockowner = {
 			.l_owner = current->files,
 		};
-		if (!nfs4_valid_open_stateid(state))
+		if (!nfs4_valid_open_stateid(ctx->state))
 			return -EBADF;
-		if (nfs4_select_rw_stateid(state, FMODE_WRITE, &lockowner,
+		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, &lockowner,
 				&arg->stateid, &delegation_cred) == -EIO)
 			return -EBADF;
 	} else
@@ -2942,7 +2942,7 @@ static int _nfs4_do_setattr(struct inode *inode,
 	status = nfs4_call_sync(server->client, server, &msg, &arg->seq_args, &res->seq_res, 1);
 
 	put_rpccred(delegation_cred);
-	if (status == 0 && state != NULL)
+	if (status == 0 && ctx != NULL)
 		renew_lease(server, timestamp);
 	trace_nfs4_setattr(inode, &arg->stateid, status);
 	return status;
@@ -2950,10 +2950,11 @@ static int _nfs4_do_setattr(struct inode *inode,
 
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			   struct nfs_fattr *fattr, struct iattr *sattr,
-			   struct nfs4_state *state, struct nfs4_label *ilabel,
+			   struct nfs_open_context *ctx, struct nfs4_label *ilabel,
 			   struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs4_state *state = ctx ? ctx->state : NULL;
         struct nfs_setattrargs  arg = {
                 .fh             = NFS_FH(inode),
                 .iap            = sattr,
@@ -2978,7 +2979,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		arg.bitmask = nfs4_bitmask(server, olabel);
 
 	do {
-		err = _nfs4_do_setattr(inode, &arg, &res, cred, state);
+		err = _nfs4_do_setattr(inode, &arg, &res, cred, ctx);
 		switch (err) {
 		case -NFS4ERR_OPENMODE:
 			if (!(sattr->ia_valid & ATTR_SIZE)) {
@@ -3673,7 +3674,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 {
 	struct inode *inode = d_inode(dentry);
 	struct rpc_cred *cred = NULL;
-	struct nfs4_state *state = NULL;
+	struct nfs_open_context *ctx = NULL;
 	struct nfs4_label *label = NULL;
 	int status;
 
@@ -3694,20 +3695,17 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 	/* Search for an existing open(O_WRITE) file */
 	if (sattr->ia_valid & ATTR_FILE) {
-		struct nfs_open_context *ctx;
 
 		ctx = nfs_file_open_context(sattr->ia_file);
-		if (ctx) {
+		if (ctx)
 			cred = ctx->cred;
-			state = ctx->state;
-		}
 	}
 
 	label = nfs4_label_alloc(NFS_SERVER(inode), GFP_KERNEL);
 	if (IS_ERR(label))
 		return PTR_ERR(label);
 
-	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, label);
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL, label);
 	if (status == 0) {
 		nfs_setattr_update_inode(inode, sattr, fattr);
 		nfs_setsecurity(inode, fattr, label);
