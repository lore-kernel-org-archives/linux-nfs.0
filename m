Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12561 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755079AbcHSRZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:25:47 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version-2 04/12] NFS inter ssc open
Date: Fri, 19 Aug 2016 13:25:04 -0400
Message-ID: <1471627512-4102-5-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSv4.2 inter server to server copy requires the destination server to
READ the data from the source server using the provided stateid and
file handle.

Given an NFSv4 stateid and filehandle from the COPY operaion, provide the
destination server with an NFS client function to create a struct file
suitable for the destiniation server to READ the data to be copied.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h     |  7 ++++
 fs/nfs/nfs4file.c    | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c    |  5 ++-
 include/linux/nfs4.h |  4 +++
 4 files changed, 110 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9bf64ea..e594d9c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -261,6 +261,13 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		const struct nfs_open_context *ctx,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode);
+extern int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+				struct nfs_fattr *fattr,
+				struct nfs4_label *label);
+extern void __update_open_stateid(struct nfs4_state *state,
+				nfs4_stateid *open_stateid,
+				const nfs4_stateid *deleg_stateid,
+				fmode_t fmode);
 
 #if defined(CONFIG_NFS_V4_1)
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index d085ad7..4a4eb40 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -7,6 +7,7 @@
 #include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/nfs_fs.h>
+#include <linux/file.h>
 #include <uapi/linux/btrfs.h>	/* BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE */
 #include "delegation.h"
 #include "internal.h"
@@ -236,6 +237,102 @@ out_unlock:
 out:
 	return ret;
 }
+
+static int read_name_gen = 1;
+#define SSC_READ_NAME_BODY "ssc_read_%d"
+
+struct file *
+nfs42_ssc_open(struct nfs42_inter_ssc *ssc, struct nfs_fh *src_fh,
+		nfs4_stateid *stateid)
+{
+	struct nfs_fattr fattr;
+	struct path path = {
+		.dentry = NULL,
+	};
+	struct file *filep, *res;
+	struct nfs_server *server;
+	struct inode *r_ino = NULL;
+	struct nfs_open_context *ctx;
+	struct nfs4_state_owner *sp;
+	char *read_name;
+	int len, status = 0;
+
+	server = NFS_SERVER(ssc->sc_mnt_dentry->d_inode);
+
+	nfs_fattr_init(&fattr);
+
+	status = nfs4_proc_getattr(server, src_fh, &fattr, NULL);
+	if (status < 0) {
+		res = ERR_PTR(status);
+		goto out;
+	}
+
+	res = ERR_PTR(-ENOMEM);
+	len = strlen(SSC_READ_NAME_BODY) + 16;
+	read_name = kzalloc(len, GFP_NOFS);
+	if (read_name == NULL)
+		goto out;
+	snprintf(read_name, len, SSC_READ_NAME_BODY, read_name_gen++);
+	dprintk("%s read_name %s\n", __func__, read_name);
+
+	/* Just put the file under the mount point */
+	path.dentry = d_alloc_name(ssc->sc_mnt_dentry, read_name);
+	kfree(read_name);
+	if (path.dentry == NULL)
+		goto out;
+	path.mnt = ssc->sc_root_mnt;
+	r_ino = nfs_fhget(ssc->sc_mnt_dentry->d_inode->i_sb, src_fh, &fattr,
+			NULL);
+	if (IS_ERR(r_ino)) {
+		res = ERR_CAST(r_ino);
+		goto out_path;
+	}
+
+	d_add(path.dentry, r_ino);
+
+	filep = alloc_file(&path, FMODE_READ, r_ino->i_fop);
+	if (IS_ERR(filep)) {
+		res = ERR_CAST(filep);
+		goto out_path;
+	}
+
+	ctx = alloc_nfs_open_context(filep->f_path.dentry, filep->f_mode);
+	if (IS_ERR(ctx)) {
+		res = ERR_CAST(ctx);
+		goto out_filep;
+	}
+
+	res = ERR_PTR(-EINVAL);
+	sp = nfs4_get_state_owner(server, ctx->cred, GFP_KERNEL);
+	if (sp == NULL)
+		goto out_ctx;
+
+	ctx->state = nfs4_get_open_state(r_ino, sp);
+	if (ctx->state == NULL)
+		goto out_stateowner;
+
+	__update_open_stateid(ctx->state, stateid, NULL, filep->f_mode);
+
+	nfs_file_set_open_context(filep, ctx);
+	put_nfs_open_context(ctx);
+
+	res = filep;
+out:
+	dprintk("<-- %s error %ld filep %p r_ino %p\n",
+		__func__, IS_ERR(res) ? PTR_ERR(res) : 0, res, r_ino);
+
+	return res;
+out_stateowner:
+	nfs4_put_state_owner(sp);
+out_ctx:
+	put_nfs_open_context(ctx);
+out_filep:
+	fput(filep);
+out_path:
+	path_put(&path);
+	goto out;
+}
+EXPORT_SYMBOL_GPL(nfs42_ssc_open);
 #endif /* CONFIG_NFS_V4_2 */
 
 const struct file_operations nfs4_file_operations = {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1949bbd..d0ae1ca 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -90,7 +90,6 @@ static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
-static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -1405,7 +1404,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
-static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
+void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
 {
 	/*
 	 * Protect the call to nfs4_state_set_mode_locked and
@@ -3416,7 +3415,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
-static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_exception exception = { };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c6564ad..f83b041 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -654,4 +654,8 @@ struct nfs4_op_map {
 	} u;
 };
 
+struct nfs42_inter_ssc {
+	struct vfsmount	*sc_root_mnt;
+	struct dentry	*sc_mnt_dentry;
+};
 #endif
-- 
1.8.3.1

