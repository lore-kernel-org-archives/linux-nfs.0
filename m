Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:19778 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbbIDR37 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:29:59 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 06/16] NFS add inter ssc functions to nfs42proc
Date: Fri, 4 Sep 2015 13:29:28 -0400
Message-ID: <1441387778-16465-7-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Given an NFSv4 stateid and filehandle from the COPY operaion, provide the
destination server with an NFS client function to create a struct file
suitable for the destiniation server to READ the data to be copied.

nfs4intercopy.h holds symbols shared by nfs and nfsd.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs42proc.c            | 106 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h              |   7 +++
 fs/nfs/nfs4proc.c             |   7 +--
 include/linux/nfs4intercopy.h |  28 +++++++++++
 include/linux/nfs_xdr.h       |   3 ++
 5 files changed, 148 insertions(+), 3 deletions(-)
 create mode 100644 include/linux/nfs4intercopy.h

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index fa665f9..c100439 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -8,6 +8,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_xdr.h>
 #include <linux/nfs_fs.h>
+#include <linux/file.h>
 #include "nfs4_fs.h"
 #include "nfs42.h"
 #include "iostat.h"
@@ -309,3 +310,108 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 		return PTR_ERR(task);
 	return 0;
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
+	/* vfsmount is bad for some reason */
+	if (IS_ERR(ssc->sc_root_mnt)) {
+		dprintk("%s MOUNT ERROR %ld\n", __func__,
+			PTR_ERR(ssc->sc_root_mnt));
+		res = ERR_CAST(ssc->sc_root_mnt);
+		goto out;
+	}
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
+
+	path.mnt = ssc->sc_root_mnt;
+
+	r_ino = nfs_fhget(ssc->sc_mnt_dentry->d_inode->i_sb, src_fh, &fattr,
+		NULL);
+	if (IS_ERR(r_ino)) {
+		res = ERR_CAST(r_ino);
+		goto out_path;
+	}
+
+	d_add_unique(path.dentry, r_ino);
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
+	put_nfs_open_context(ctx); /* nfs_open does this.. :) */
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
+	path_put(&path); /* dput dentry and mntput mnt */
+goto out;
+}
+EXPORT_SYMBOL_GPL(nfs42_ssc_open);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ea3bee9..408c637 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -257,6 +257,13 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
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
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f0c59eb..e05d4c0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -80,7 +80,6 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, long *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
-static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -1276,7 +1275,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
-static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
+void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
 {
 	/*
 	 * Protect the call to nfs4_state_set_mode_locked and
@@ -1294,6 +1293,7 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 	update_open_stateflags(state, fmode);
 	spin_unlock(&state->owner->so_lock);
 }
+EXPORT_SYMBOL_GPL(__update_open_stateid);
 
 static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, nfs4_stateid *delegation, fmode_t fmode)
 {
@@ -3233,7 +3233,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
-static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_exception exception = { };
@@ -3246,6 +3246,7 @@ static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	} while (exception.retry);
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs4_proc_getattr);
 
 /* 
  * The file is not closed if it is opened due to the a request to change
diff --git a/include/linux/nfs4intercopy.h b/include/linux/nfs4intercopy.h
new file mode 100644
index 0000000..e490bca
--- /dev/null
+++ b/include/linux/nfs4intercopy.h
@@ -0,0 +1,28 @@
+/*
+ * linux/fs/nfs/nfs4intercopy.h
+ *
+ * Copyright (C) 2014 Andy Adamson <andros@netapp.com>
+ *
+ * nfs inter-server server-side copy READ implementation
+ *
+ */
+
+#include <linux/socket.h>
+#include <linux/sunrpc/msg_prot.h>
+#include <linux/nfs.h>
+#include <linux/nfs4.h>
+
+struct nfs42_netaddr {
+	unsigned int	na_netid_len;
+	char		na_netid[RPCBIND_MAXNETIDLEN + 1];
+	unsigned int	na_uaddr_len;
+	char		na_uaddr[RPCBIND_MAXUADDRLEN + 1];
+};
+
+struct nfs42_inter_ssc {
+	struct vfsmount		*sc_root_mnt;
+	struct dentry		*sc_mnt_dentry;
+};
+
+extern struct file *nfs42_ssc_open(struct nfs42_inter_ssc *ssc,
+				struct nfs_fh *fh, nfs4_stateid *stateid);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e5f6227..dd44d3a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1303,6 +1303,9 @@ nfs_free_pnfs_ds_cinfo(struct pnfs_ds_commit_info *cinfo)
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
+
+#include <linux/nfs4intercopy.h>
+
 struct nfs42_falloc_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
1.8.3.1

