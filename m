Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:3623 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752326AbdI1R2q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:46 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 08/11] NFS inter ssc open
Date: Thu, 28 Sep 2017 13:28:36 -0400
Message-ID: <20170928172839.50741-9-kolga@netapp.com>
In-Reply-To: <20170928172839.50741-1-kolga@netapp.com>
References: <20170928172839.50741-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.2 inter server to server copy requires the destination server to
READ the data from the source server using the provided stateid and
file handle.

Given an NFSv4 stateid and filehandle from the COPY operaion, provide the
destination server with an NFS client function to create a struct file
suitable for the destiniation server to READ the data to be copied.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h  |   7 ++++
 fs/nfs/nfs4file.c | 106 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c |   5 ++-
 3 files changed, 115 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c143e34..8fa4088 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -278,6 +278,13 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		const struct nfs_open_context *ctx,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode);
+extern int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+				struct nfs_fattr *fattr,
+				struct nfs4_label *label);
+extern int update_open_stateid(struct nfs4_state *state,
+				const nfs4_stateid *open_stateid,
+				const nfs4_stateid *deleg_stateid,
+				fmode_t fmode);
 
 #if defined(CONFIG_NFS_V4_1)
 extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res *);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index b0194ad..9c2070e 100644
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
@@ -263,6 +264,111 @@ static int nfs42_clone_file_range(struct file *src_file, loff_t src_off,
 out:
 	return ret;
 }
+
+static int read_name_gen = 1;
+#define SSC_READ_NAME_BODY "ssc_read_%d"
+
+struct file *
+nfs42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
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
+	server = NFS_SERVER(ss_mnt->mnt_root->d_inode);
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
+	path.dentry = d_alloc_name(ss_mnt->mnt_root, read_name);
+	kfree(read_name);
+	if (path.dentry == NULL)
+		goto out;
+	path.mnt = ss_mnt;
+	r_ino = nfs_fhget(ss_mnt->mnt_root->d_inode->i_sb, src_fh, &fattr,
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
+	ctx = alloc_nfs_open_context(filep->f_path.dentry, filep->f_mode,
+					filep);
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
+	update_open_stateid(ctx->state, stateid, NULL, filep->f_mode);
+
+	nfs_file_set_open_context(filep, ctx);
+	put_nfs_open_context(ctx);
+
+	file_ra_state_init(&filep->f_ra, filep->f_mapping->host->i_mapping);
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
+void nfs42_ssc_close(struct file *filep)
+{
+	struct nfs_open_context *ctx = nfs_file_open_context(filep);
+
+	ctx->state->flags = 0;
+}
+EXPORT_SYMBOL_GPL(nfs42_ssc_close);
 #endif /* CONFIG_NFS_V4_2 */
 
 const struct file_operations nfs4_file_operations = {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 08b85dc..3a666a2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -89,7 +89,6 @@
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
-static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -1463,7 +1462,7 @@ static void __update_open_stateid(struct nfs4_state *state,
 	spin_unlock(&state->owner->so_lock);
 }
 
-static int update_open_stateid(struct nfs4_state *state,
+int update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *open_stateid,
 		const nfs4_stateid *delegation,
 		fmode_t fmode)
@@ -3646,7 +3645,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
-static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_exception exception = { };
-- 
1.8.3.1

