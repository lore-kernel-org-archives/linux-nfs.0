From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/24] NFS: Reduce stack footprint of nfs4_proc_create()
Date: Fri, 16 Apr 2010 16:31:18 -0400
Message-ID: <1271449882-8580-21-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-18-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-19-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-20-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16405 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932475Ab0DPUbg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:36 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlF026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:35 -0700 (PDT)
In-Reply-To: <1271449882-8580-20-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the O_EXCL open handling into _nfs4_do_open() where it belongs. Doing
so also allows us to reuse the struct fattr from the opendata.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f09a7b9..d46305a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -70,6 +70,9 @@ static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinf
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
+static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
+			    struct nfs_fattr *fattr, struct iattr *sattr,
+			    struct nfs4_state *state);
 
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
@@ -1659,15 +1662,24 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 	if (status != 0)
 		goto err_opendata_put;
 
-	if (opendata->o_arg.open_flags & O_EXCL)
-		nfs4_exclusive_attrset(opendata, sattr);
-
 	state = nfs4_opendata_to_nfs4_state(opendata);
 	status = PTR_ERR(state);
 	if (IS_ERR(state))
 		goto err_opendata_put;
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
+
+	if (opendata->o_arg.open_flags & O_EXCL) {
+		nfs4_exclusive_attrset(opendata, sattr);
+
+		nfs_fattr_init(opendata->o_res.f_attr);
+		status = nfs4_do_setattr(state->inode, cred,
+				opendata->o_res.f_attr, sattr,
+				state);
+		if (status == 0)
+			nfs_setattr_update_inode(state->inode, sattr);
+		nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr);
+	}
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
@@ -2565,13 +2577,6 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	}
 	d_add(dentry, igrab(state->inode));
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-	if (flags & O_EXCL) {
-		struct nfs_fattr fattr;
-		status = nfs4_do_setattr(state->inode, cred, &fattr, sattr, state);
-		if (status == 0)
-			nfs_setattr_update_inode(state->inode, sattr);
-		nfs_post_op_update_inode(state->inode, &fattr);
-	}
 	if (status == 0 && (nd->flags & LOOKUP_OPEN) != 0)
 		status = nfs4_intent_set_file(nd, &path, state, fmode);
 	else
-- 
1.6.6.1

