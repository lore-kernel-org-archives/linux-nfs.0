Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750846AbdFSNW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jun 2017 09:22:29 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: convert flags to bool
Date: Mon, 19 Jun 2017 09:22:27 -0400
Message-Id: <db7a135f03665f2193182e0bbc686a6b2eaf5210.1497878420.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS uses some int, and unsigned int :1, and bool as flags in structs and
args.  Assert the preference for uniformly replacing these with the bool
type.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c            | 16 ++++++++--------
 fs/nfs/internal.h       |  6 +++---
 fs/nfs/nfs2xdr.c        |  2 +-
 fs/nfs/nfs3proc.c       |  2 +-
 fs/nfs/nfs3xdr.c        |  2 +-
 fs/nfs/nfs4proc.c       | 42 +++++++++++++++++++++---------------------
 fs/nfs/nfs4xdr.c        |  2 +-
 fs/nfs/proc.c           |  2 +-
 include/linux/nfs_xdr.h | 10 +++++-----
 9 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7108d272bc87..1be9fd659a8b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -151,7 +151,7 @@ struct nfs_cache_array {
 	struct nfs_cache_array_entry array[0];
 };
 
-typedef int (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, int);
+typedef int (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, bool);
 typedef struct {
 	struct file	*file;
 	struct page	*page;
@@ -165,8 +165,8 @@ typedef struct {
 	unsigned long	timestamp;
 	unsigned long	gencount;
 	unsigned int	cache_entry_index;
-	unsigned int	plus:1;
-	unsigned int	eof:1;
+	bool plus;
+	bool eof;
 } nfs_readdir_descriptor_t;
 
 /*
@@ -355,7 +355,7 @@ int nfs_readdir_xdr_filler(struct page **pages, nfs_readdir_descriptor_t *desc,
 		if (error == -ENOTSUPP && desc->plus) {
 			NFS_SERVER(inode)->caps &= ~NFS_CAP_READDIRPLUS;
 			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
-			desc->plus = 0;
+			desc->plus = false;
 			goto again;
 		}
 		goto error;
@@ -557,7 +557,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 
 		count++;
 
-		if (desc->plus != 0)
+		if (desc->plus)
 			nfs_prime_dcache(file_dentry(desc->file), entry);
 
 		status = nfs_readdir_add_to_array(entry, page);
@@ -860,7 +860,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	desc->ctx = ctx;
 	desc->dir_cookie = &dir_ctx->dir_cookie;
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
-	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
+	desc->plus = nfs_use_readdirplus(inode, ctx) ? true : false;
 
 	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
 		res = nfs_revalidate_mapping(inode, file->f_mapping);
@@ -885,8 +885,8 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			nfs_zap_caches(inode);
 			desc->page_index = 0;
-			desc->plus = 0;
-			desc->eof = 0;
+			desc->plus = false;
+			desc->eof = false;
 			continue;
 		}
 		if (res < 0)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3e24392f2caa..23d6c80346fc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -272,17 +272,17 @@ static inline bool nfs_match_open_context(const struct nfs_open_context *ctx1,
 /* nfs2xdr.c */
 extern struct rpc_procinfo nfs_procedures[];
 extern int nfs2_decode_dirent(struct xdr_stream *,
-				struct nfs_entry *, int);
+				struct nfs_entry *, bool);
 
 /* nfs3xdr.c */
 extern struct rpc_procinfo nfs3_procedures[];
 extern int nfs3_decode_dirent(struct xdr_stream *,
-				struct nfs_entry *, int);
+				struct nfs_entry *, bool);
 
 /* nfs4xdr.c */
 #if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs4_decode_dirent(struct xdr_stream *,
-				struct nfs_entry *, int);
+				struct nfs_entry *, bool);
 #endif
 #ifdef CONFIG_NFS_V4_1
 extern const u32 nfs41_maxread_overhead;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index b4e03ed8599d..a03e45288e0b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -913,7 +913,7 @@ static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, struct xdr_stream *xdr,
  *	};
  */
 int nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
-		       int plus)
+		       bool plus)
 {
 	__be32 *p;
 	int error;
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 0c07b567118d..df4a7d3ab915 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -621,7 +621,7 @@ nfs3_proc_rmdir(struct inode *dir, const struct qstr *name)
  */
 static int
 nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-		  u64 cookie, struct page **pages, unsigned int count, int plus)
+		  u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct inode		*dir = d_inode(dentry);
 	__be32			*verf = NFS_I(dir)->cookieverf;
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 267126d32ec0..a2df35fe9bfa 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1946,7 +1946,7 @@ static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
  *	};
  */
 int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
-		       int plus)
+		       bool plus)
 {
 	struct nfs_entry old = *entry;
 	__be32 *p;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c08c46a3b8cd..5f50d0a483bb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1034,11 +1034,11 @@ struct nfs4_opendata {
 	struct nfs4_state *state;
 	struct iattr attrs;
 	unsigned long timestamp;
-	unsigned int rpc_done : 1;
-	unsigned int file_created : 1;
-	unsigned int is_recover : 1;
+	bool rpc_done;
+	bool file_created;
+	bool is_recover;
+	bool cancelled;
 	int rpc_status;
-	int cancelled;
 };
 
 static bool nfs4_clear_cap_atomic_open_v1(struct nfs_server *server,
@@ -1962,7 +1962,7 @@ static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 		nfs4_stateid_copy(&data->o_res.stateid, &data->c_res.stateid);
 		nfs_confirm_seqid(&data->owner->so_seqid, 0);
 		renew_lease(data->o_res.server, data->timestamp);
-		data->rpc_done = 1;
+		data->rpc_done = true;
 	}
 }
 
@@ -1972,7 +1972,7 @@ static void nfs4_open_confirm_release(void *calldata)
 	struct nfs4_state *state = NULL;
 
 	/* If this request hasn't been cancelled, do nothing */
-	if (data->cancelled == 0)
+	if (!data->cancelled)
 		goto out_free;
 	/* In case of error, no cleanup! */
 	if (!data->rpc_done)
@@ -2015,7 +2015,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 
 	nfs4_init_sequence(&data->c_arg.seq_args, &data->c_res.seq_res, 1);
 	kref_get(&data->kref);
-	data->rpc_done = 0;
+	data->rpc_done = false;
 	data->rpc_status = 0;
 	data->timestamp = jiffies;
 	if (data->is_recover)
@@ -2025,7 +2025,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 		return PTR_ERR(task);
 	status = rpc_wait_for_completion_task(task);
 	if (status != 0) {
-		data->cancelled = 1;
+		data->cancelled = true;
 		smp_wmb();
 	} else
 		status = data->rpc_status;
@@ -2124,7 +2124,7 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 		if (!(data->o_res.rflags & NFS4_OPEN_RESULT_CONFIRM))
 			nfs_confirm_seqid(&data->owner->so_seqid, 0);
 	}
-	data->rpc_done = 1;
+	data->rpc_done = true;
 }
 
 static void nfs4_open_release(void *calldata)
@@ -2133,7 +2133,7 @@ static void nfs4_open_release(void *calldata)
 	struct nfs4_state *state = NULL;
 
 	/* If this request hasn't been cancelled, do nothing */
-	if (data->cancelled == 0)
+	if (!data->cancelled)
 		goto out_free;
 	/* In case of error, no cleanup! */
 	if (data->rpc_status != 0 || !data->rpc_done)
@@ -2179,20 +2179,20 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 
 	nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1);
 	kref_get(&data->kref);
-	data->rpc_done = 0;
+	data->rpc_done = false;
 	data->rpc_status = 0;
-	data->cancelled = 0;
-	data->is_recover = 0;
+	data->cancelled = false;
+	data->is_recover = false;
 	if (isrecover) {
 		nfs4_set_sequence_privileged(&o_arg->seq_args);
-		data->is_recover = 1;
+		data->is_recover = true;
 	}
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = rpc_wait_for_completion_task(task);
 	if (status != 0) {
-		data->cancelled = 1;
+		data->cancelled = true;
 		smp_wmb();
 	} else
 		status = data->rpc_status;
@@ -2287,9 +2287,9 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 
 	if (o_arg->open_flags & O_CREAT) {
 		if (o_arg->open_flags & O_EXCL)
-			data->file_created = 1;
+			data->file_created = true;
 		else if (o_res->cinfo.before != o_res->cinfo.after)
-			data->file_created = 1;
+			data->file_created = true;
 		if (data->file_created || dir->i_version != o_res->cinfo.after)
 			update_changeattr(dir, &o_res->cinfo,
 					o_res->f_attr->time_start);
@@ -4272,7 +4272,7 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 }
 
 static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-		u64 cookie, struct page **pages, unsigned int count, int plus)
+		u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct inode		*dir = d_inode(dentry);
 	struct nfs4_readdir_arg args = {
@@ -4310,7 +4310,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 }
 
 static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-		u64 cookie, struct page **pages, unsigned int count, int plus)
+		u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct nfs4_exception exception = { };
 	int err;
@@ -6134,7 +6134,7 @@ static void nfs4_lock_release(void *calldata)
 
 	dprintk("%s: begin!\n", __func__);
 	nfs_free_seqid(data->arg.open_seqid);
-	if (data->cancelled != 0) {
+	if (data->cancelled) {
 		struct rpc_task *task;
 		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
 				data->arg.lock_seqid);
@@ -6217,7 +6217,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 			nfs4_handle_setlk_error(data->server, data->lsp,
 					data->arg.new_lock_owner, ret);
 	} else
-		data->cancelled = 1;
+		data->cancelled = true;
 	rpc_put_task(task);
 	dprintk("%s: done, ret = %d!\n", __func__, ret);
 	trace_nfs4_set_lock(fl, state, &data->res.stateid, cmd, ret);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3aebfdc82b30..d31ad276185c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7350,7 +7350,7 @@ static int nfs4_xdr_dec_free_stateid(struct rpc_rqst *rqstp,
  * on a directory already in our cache.
  */
 int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
-		       int plus)
+		       bool plus)
 {
 	unsigned int savep;
 	uint32_t bitmap[3] = {0};
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 9872cf676a50..7962e49097c3 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -485,7 +485,7 @@ nfs_proc_rmdir(struct inode *dir, const struct qstr *name)
  */
 static int
 nfs_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-		 u64 cookie, struct page **pages, unsigned int count, int plus)
+		 u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct inode		*dir = d_inode(dentry);
 	struct nfs_readdirargs	arg = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1aca3d7c1810..9463eeff9e3c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -878,7 +878,7 @@ struct nfs3_readdirargs {
 	struct nfs_fh *		fh;
 	__u64			cookie;
 	__be32			verf[2];
-	int			plus;
+	bool			plus;
 	unsigned int            count;
 	struct page **		pages;
 };
@@ -909,7 +909,7 @@ struct nfs3_linkres {
 struct nfs3_readdirres {
 	struct nfs_fattr *	dir_attr;
 	__be32 *		verf;
-	int			plus;
+	bool			plus;
 };
 
 struct nfs3_getaclres {
@@ -1053,7 +1053,7 @@ struct nfs4_readdir_arg {
 	struct page **			pages;	/* zero-copy data */
 	unsigned int			pgbase;	/* zero-copy data */
 	const u32 *			bitmask;
-	int				plus;
+	bool				plus;
 };
 
 struct nfs4_readdir_res {
@@ -1586,7 +1586,7 @@ struct nfs_rpc_ops {
 	int	(*mkdir)   (struct inode *, struct dentry *, struct iattr *);
 	int	(*rmdir)   (struct inode *, const struct qstr *);
 	int	(*readdir) (struct dentry *, struct rpc_cred *,
-			    u64, struct page **, unsigned int, int);
+			    u64, struct page **, unsigned int, bool);
 	int	(*mknod)   (struct inode *, struct dentry *, struct iattr *,
 			    dev_t);
 	int	(*statfs)  (struct nfs_server *, struct nfs_fh *,
@@ -1596,7 +1596,7 @@ struct nfs_rpc_ops {
 	int	(*pathconf) (struct nfs_server *, struct nfs_fh *,
 			     struct nfs_pathconf *);
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
-	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int);
+	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, bool);
 	int	(*pgio_rpc_prepare)(struct rpc_task *,
 				    struct nfs_pgio_header *);
 	void	(*read_setup)(struct nfs_pgio_header *, struct rpc_message *);
-- 
2.9.3

