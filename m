Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932644Ab3DBVqU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 17:46:20 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 17/19] NFSv4.2: Only set the label attribute on v4.2 mounts
Date: Tue,  2 Apr 2013 17:45:58 -0400
Message-Id: <1364939160-20874-18-git-send-email-SteveD@redhat.com>
In-Reply-To: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Make sure the FATTR4_WORD2_SECURITY_LABEL bit is
only set in bitmasks and bitmaps when label NFS
is configured and only on v4.2 mounts.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/nfs4proc.c      | 52 ++++++++++++++++++++++++++++++++++++--------------
 fs/nfs/pnfs.c          |  2 +-
 include/linux/nfs_fs.h | 10 ++++++++++
 3 files changed, 49 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e18d39..0bdc865 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -113,6 +113,24 @@ nfs4_label_release_security(struct nfs4_label *label)
 	if (label)
 		security_release_secctx(label->label, label->len);
 }
+static inline u32 *nfs4_bitmap(struct nfs4_label *label, u32 *bitmap)
+{
+	bitmap[0] =  nfs4_fattr_bitmap[0];
+	bitmap[1] =  nfs4_fattr_bitmap[1];
+	bitmap[2] =  nfs4_fattr_bitmap[2];
+
+	if (!label)
+		bitmap[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
+
+	return bitmap;
+}
+static inline u32 *nfs4_bitmask(struct nfs_server *server, struct nfs4_label *label)
+{
+	if (label)
+		return server->attr_bitmask;
+
+	return server->attr_bitmask_nl;
+}
 #else
 static inline struct nfs4_label *
 nfs4_label_init_security(struct inode *dir, struct dentry *dentry, 
@@ -122,6 +140,12 @@ nfs4_label_init_security(struct inode *dir, struct dentry *dentry,
 static inline void 
 nfs4_label_release_security(struct nfs4_label *label) 
 { return; }
+static inline u32 *
+nfs4_bitmask(struct nfs_server *server, struct nfs4_label *label)
+{ return server->attr_bitmask; }
+static inline const u32 *
+nfs4_bitmap(struct nfs4_label *label, u32 *bitmap)
+{ return &nfs4_fattr_bitmap[0]; }
 #endif
 
 /* Prevent leaks of NFSv4 errors into userland */
@@ -824,6 +848,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	struct inode *dir = parent->d_inode;
 	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs4_opendata *p;
+	u32 bitmap[3];
 
 	p = kzalloc(sizeof(*p), gfp_mask);
 	if (p == NULL)
@@ -857,8 +882,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.id.uniquifier = sp->so_seqid.owner_id;
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
-	p->o_arg.bitmask = server->attr_bitmask;
-	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
+	p->o_arg.open_bitmap = nfs4_bitmap(label, bitmap);
+	p->o_arg.bitmask = nfs4_bitmask(server, label);
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
 	p->o_arg.label = label;
 	if (attrs != NULL && attrs->ia_valid != 0) {
@@ -2126,8 +2151,9 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	unsigned long timestamp = jiffies;
 	int status;
 
-	if (ilabel == NULL || olabel == NULL)
-		arg.bitmask = server->attr_bitmask_nl;
+	arg.bitmask = nfs4_bitmask(server, ilabel);
+	if (ilabel)
+		arg.bitmask = nfs4_bitmask(server, olabel);
 
 	nfs_fattr_init(fattr);
 
@@ -2708,8 +2734,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	if (!label)
-		args.bitmask = server->attr_bitmask_nl;
+	args.bitmask = nfs4_bitmask(server, label);
 
 	nfs_fattr_init(fattr);
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
@@ -2814,8 +2839,7 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 		.rpc_resp = &res,
 	};
 
-	if (label == NULL)
-		args.bitmask = server->attr_bitmask_nl;
+	args.bitmask = nfs4_bitmask(server, label);
 
 	nfs_fattr_init(fattr);
 
@@ -2952,6 +2976,8 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		goto out;
 	}
 
+	args.bitmask = nfs4_cache_bitmask(server, res.label);
+
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		nfs_access_set_mask(entry, res.access);
@@ -3263,6 +3289,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 		status = PTR_ERR(res.label);
 		goto out;
 	}
+	arg.bitmask = nfs4_bitmask(server, res.label);
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
@@ -3320,7 +3347,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->arg.name = name;
 		data->arg.attrs = sattr;
 		data->arg.ftype = ftype;
-		data->arg.bitmask = server->attr_bitmask;
+		data->arg.bitmask = nfs4_bitmask(server, data->label);
 		data->res.server = server;
 		data->res.fh = &data->fh;
 		data->res.fattr = &data->fattr;
@@ -3758,11 +3785,8 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 		data->args.bitmask = NULL;
 		data->res.fattr = NULL;
 	} else
-#ifdef CONFIG_NFS_V4_SECURITY_LABEL
-		data->args.bitmask = server->cache_consistency_bitmask_nl;
-#else
-		data->args.bitmask = server->cache_consistency_bitmask;
-#endif
+
+	data->args.bitmask = nfs4_cache_bitmask(server, NULL);
 
 	if (!data->write_done_cb)
 		data->write_done_cb = nfs4_write_done_cb;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4bdffe0..0ead05b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1922,7 +1922,7 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	data->args.inode = inode;
 	data->cred = get_rpccred(nfsi->layout->plh_lc_cred);
 	nfs_fattr_init(&data->fattr);
-	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
+	data->args.bitmask = nfs4_cache_bitmask(NFS_SERVER(inode), NULL);
 	data->res.fattr = &data->fattr;
 	data->args.lastbytewritten = end_pos - 1;
 	data->res.server = NFS_SERVER(inode);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6de5336..1510f4f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -505,9 +505,19 @@ static inline void nfs4_label_free(struct nfs4_label *label)
 	}
 	return;
 }
+static inline u32 *nfs4_cache_bitmask(struct nfs_server *server, struct nfs4_label *label)
+{
+	if (label)
+		return server->cache_consistency_bitmask;
+
+	return server->cache_consistency_bitmask_nl;
+}
 #else
 static inline struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags) { return NULL; }
 static inline void nfs4_label_free(void *label) {}
+static inline u32 *
+nfs4_cache_bitmask(struct nfs_server *server, struct nfs4_label *label)
+{ return server->cache_consistency_bitmask; }
 #endif
 
 /*
-- 
1.8.1.4

