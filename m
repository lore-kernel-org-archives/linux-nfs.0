Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38033 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbbC0Qwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:30 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 35/39] nfs/sunrpc: Return status code from encode functions
Date: Fri, 27 Mar 2015 17:50:33 +0100
Message-Id: <9570245075abfce323d1f0988c353e8ddfd5e794.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return a status code from the sunrpc xdr encode functions. While these
functions were originally returning a status code before commit 9f06c719 from
December 2010, it was found that none of them can actually fail and so they
were turned into void functions. With more complex objects like NFSv4 ACLs to
encode, it makes sense to do memory allocations and some of the error checking
inside the encode functions, so those functions may fail.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/lockd/clnt4xdr.c               |  42 +++---
 fs/lockd/clntxdr.c                |  42 +++---
 fs/lockd/mon.c                    |  10 +-
 fs/nfs/mount_clnt.c               |   3 +-
 fs/nfs/nfs2xdr.c                  |  84 ++++++-----
 fs/nfs/nfs3xdr.c                  | 133 +++++++++--------
 fs/nfs/nfs4xdr.c                  | 292 ++++++++++++++++++++++----------------
 fs/nfsd/nfs4callback.c            |  17 ++-
 include/linux/sunrpc/xdr.h        |   2 +-
 net/sunrpc/auth.c                 |   7 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c |   7 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h |   6 +-
 net/sunrpc/clnt.c                 |   3 +-
 net/sunrpc/rpcb_clnt.c            |  10 +-
 14 files changed, 380 insertions(+), 278 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index 693f71a..61df64c 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -379,9 +379,9 @@ static void encode_nlm4_lock(struct xdr_stream *xdr,
  *		struct nlm4_lock alock;
  *	};
  */
-static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
-				  struct xdr_stream *xdr,
-				  void *obj)
+static int nlm4_xdr_enc_testargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
@@ -389,6 +389,7 @@ static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
 	encode_cookie(xdr, &args->cookie);
 	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
 	encode_nlm4_lock(xdr, lock);
+	return 0;
 }
 
 /*
@@ -401,9 +402,9 @@ static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
  *		int state;
  *	};
  */
-static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
-				  struct xdr_stream *xdr,
-				  void *obj)
+static int nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
@@ -414,6 +415,7 @@ static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
 	encode_nlm4_lock(xdr, lock);
 	encode_bool(xdr, args->reclaim);
 	encode_int32(xdr, args->state);
+	return 0;
 }
 
 /*
@@ -424,9 +426,9 @@ static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
  *		struct nlm4_lock alock;
  *	};
  */
-static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
-				  struct xdr_stream *xdr,
-				  void *obj)
+static int nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
@@ -435,6 +437,7 @@ static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
 	encode_bool(xdr, args->block);
 	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
 	encode_nlm4_lock(xdr, lock);
+	return 0;
 }
 
 /*
@@ -443,15 +446,16 @@ static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
  *		struct nlm4_lock alock;
  *	};
  */
-static void nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
-				    struct xdr_stream *xdr,
-				    void *obj)
+static int nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
 	encode_nlm4_lock(xdr, lock);
+	return 0;
 }
 
 /*
@@ -460,13 +464,14 @@ static void nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
  *		nlm4_stat stat;
  *	};
  */
-static void nlm4_xdr_enc_res(struct rpc_rqst *req,
-			     struct xdr_stream *xdr,
-			     void *obj)
+static int nlm4_xdr_enc_res(struct rpc_rqst *req,
+			    struct xdr_stream *xdr,
+			    void *obj)
 {
 	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm4_stat(xdr, result->status);
+	return 0;
 }
 
 /*
@@ -482,15 +487,16 @@ static void nlm4_xdr_enc_res(struct rpc_rqst *req,
  *		nlm4_testrply test_stat;
  *	};
  */
-static void nlm4_xdr_enc_testres(struct rpc_rqst *req,
-				 struct xdr_stream *xdr,
-				 void *obj)
+static int nlm4_xdr_enc_testres(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				void *obj)
 {
 	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm4_stat(xdr, result->status);
 	if (result->status == nlm_lck_denied)
 		encode_nlm4_holder(xdr, result);
+	return 0;
 }
 
 
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 6ca581b..e05d3035 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -372,9 +372,9 @@ static void encode_nlm_lock(struct xdr_stream *xdr,
  *		struct nlm_lock alock;
  *	};
  */
-static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
-				 struct xdr_stream *xdr,
-				 void *obj)
+static int nlm_xdr_enc_testargs(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
@@ -382,6 +382,7 @@ static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
 	encode_cookie(xdr, &args->cookie);
 	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
 	encode_nlm_lock(xdr, lock);
+	return 0;
 }
 
 /*
@@ -394,9 +395,9 @@ static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
  *		int state;
  *	};
  */
-static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
-				 struct xdr_stream *xdr,
-				 void *obj)
+static int nlm_xdr_enc_lockargs(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
@@ -407,6 +408,7 @@ static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
 	encode_nlm_lock(xdr, lock);
 	encode_bool(xdr, args->reclaim);
 	encode_int32(xdr, args->state);
+	return 0;
 }
 
 /*
@@ -417,9 +419,9 @@ static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
  *		struct nlm_lock alock;
  *	};
  */
-static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
-				 struct xdr_stream *xdr,
-				 void *obj)
+static int nlm_xdr_enc_cancargs(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
@@ -428,6 +430,7 @@ static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
 	encode_bool(xdr, args->block);
 	encode_bool(xdr, lock->fl.fl_type == F_WRLCK);
 	encode_nlm_lock(xdr, lock);
+	return 0;
 }
 
 /*
@@ -436,15 +439,16 @@ static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
  *		struct nlm_lock alock;
  *	};
  */
-static void nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nlm_args *args = obj;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
 	encode_nlm_lock(xdr, lock);
+	return 0;
 }
 
 /*
@@ -453,13 +457,14 @@ static void nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
  *		nlm_stat stat;
  *	};
  */
-static void nlm_xdr_enc_res(struct rpc_rqst *req,
-			    struct xdr_stream *xdr,
-			    void *obj)
+static int nlm_xdr_enc_res(struct rpc_rqst *req,
+			   struct xdr_stream *xdr,
+			   void *obj)
 {
 	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm_stat(xdr, result->status);
+	return 0;
 }
 
 /*
@@ -482,14 +487,15 @@ static void encode_nlm_testrply(struct xdr_stream *xdr,
 		encode_nlm_holder(xdr, result);
 }
 
-static void nlm_xdr_enc_testres(struct rpc_rqst *req,
-				struct xdr_stream *xdr,
-				void *obj)
+static int nlm_xdr_enc_testres(struct rpc_rqst *req,
+			       struct xdr_stream *xdr,
+			       void *obj)
 {
 	const struct nlm_res *result = obj;
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm_stat(xdr, result->status);
 	encode_nlm_testrply(xdr, result);
+	return 0;
 }
 
 
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 395c39f..2308983 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -526,19 +526,21 @@ static void encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 	xdr_encode_opaque_fixed(p, argp->priv->data, SM_PRIV_SIZE);
 }
 
-static void nsm_xdr_enc_mon(struct rpc_rqst *req, struct xdr_stream *xdr,
-			    void *obj)
+static int nsm_xdr_enc_mon(struct rpc_rqst *req, struct xdr_stream *xdr,
+			   void *obj)
 {
 	const struct nsm_args *argp = obj;
 	encode_mon_id(xdr, argp);
 	encode_priv(xdr, argp);
+	return 0;
 }
 
-static void nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      void *obj)
+static int nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
+			     void *obj)
 {
 	const struct nsm_args *argp = obj;
 	encode_mon_id(xdr, argp);
+	return 0;
 }
 
 static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index c02962a..cd1cc75 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -305,11 +305,12 @@ static void encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
 	xdr_encode_opaque(p, pathname, pathname_len);
 }
 
-static void mnt_xdr_enc_dirpath(struct rpc_rqst *req, struct xdr_stream *xdr,
+static int mnt_xdr_enc_dirpath(struct rpc_rqst *req, struct xdr_stream *xdr,
 				void *obj)
 {
 	const char *dirpath = obj;
 	encode_mntdirpath(xdr, dirpath);
+	return 0;
 }
 
 /*
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 91a988a..2739a87 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -566,12 +566,13 @@ out_default:
  * "NFS: Network File System Protocol Specification".
  */
 
-static void nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
-				 struct xdr_stream *xdr,
-				 void *obj)
+static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				void *obj)
 {
 	const struct nfs_fh *fh = obj;
 	encode_fhandle(xdr, fh);
+	return 0;
 }
 
 /*
@@ -582,31 +583,34 @@ static void nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
  *		sattr attributes;
  *	};
  */
-static void nfs2_xdr_enc_sattrargs(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nfs2_xdr_enc_sattrargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nfs_sattrargs *args = obj;
 	encode_fhandle(xdr, args->fh);
 	encode_sattr(xdr, args->sattr);
+	return 0;
 }
 
-static void nfs2_xdr_enc_diropargs(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nfs2_xdr_enc_diropargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nfs_diropargs *args = obj;
 	encode_diropargs(xdr, args->fh, args->name, args->len);
+	return 0;
 }
 
-static void nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	const struct nfs_readlinkargs *args = obj;
 	encode_fhandle(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS_readlinkres_sz);
+	return 0;
 }
 
 /*
@@ -634,15 +638,16 @@ static void encode_readargs(struct xdr_stream *xdr,
 	*p = cpu_to_be32(count);
 }
 
-static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
-				  struct xdr_stream *xdr,
-				  void *obj)
+static int nfs2_xdr_enc_readargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 void *obj)
 {
 	const struct nfs_pgio_args *args = obj;
 	encode_readargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS_readres_sz);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
+	return 0;
 }
 
 /*
@@ -675,13 +680,14 @@ static void encode_writeargs(struct xdr_stream *xdr,
 	xdr_write_pages(xdr, args->pages, args->pgbase, count);
 }
 
-static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nfs_pgio_args *args = obj;
 	encode_writeargs(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
+	return 0;
 }
 
 /*
@@ -692,21 +698,23 @@ static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
  *		sattr attributes;
  *	};
  */
-static void nfs2_xdr_enc_createargs(struct rpc_rqst *req,
-				    struct xdr_stream *xdr,
-				    void *obj)
+static int nfs2_xdr_enc_createargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   void *obj)
 {
 	const struct nfs_createargs *args = obj;
 	encode_diropargs(xdr, args->fh, args->name, args->len);
 	encode_sattr(xdr, args->sattr);
+	return 0;
 }
 
-static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
-				    struct xdr_stream *xdr,
-				    void *obj)
+static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   void *obj)
 {
 	const struct nfs_removeargs *args = obj;
 	encode_diropargs(xdr, args->fh, args->name.name, args->name.len);
+	return 0;
 }
 
 /*
@@ -717,9 +725,9 @@ static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
  *		diropargs to;
  *	};
  */
-static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
-				    struct xdr_stream *xdr,
-				    void *obj)
+static int nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   void *obj)
 {
 	const struct nfs_renameargs *args = obj;
 	const struct qstr *old = args->old_name;
@@ -727,6 +735,7 @@ static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
 
 	encode_diropargs(xdr, args->old_dir, old->name, old->len);
 	encode_diropargs(xdr, args->new_dir, new->name, new->len);
+	return 0;
 }
 
 /*
@@ -737,13 +746,14 @@ static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
  *		diropargs to;
  *	};
  */
-static void nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
-				  struct xdr_stream *xdr,
-				  void *obj)
+static int nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 void *obj)
 {
 	const struct nfs_linkargs *args = obj;
 	encode_fhandle(xdr, args->fromfh);
 	encode_diropargs(xdr, args->tofh, args->toname, args->tolen);
+	return 0;
 }
 
 /*
@@ -755,14 +765,15 @@ static void nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
  *		sattr attributes;
  *	};
  */
-static void nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs_symlinkargs *args = obj;
 	encode_diropargs(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_path(xdr, args->pages, args->pathlen);
 	encode_sattr(xdr, args->sattr);
+	return 0;
 }
 
 /*
@@ -786,14 +797,15 @@ static void encode_readdirargs(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static void nfs2_xdr_enc_readdirargs(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs2_xdr_enc_readdirargs(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs_readdirargs *args = obj;
 	encode_readdirargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 					args->count, NFS_readdirres_sz);
+	return 0;
 }
 
 /*
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d8f7744..8b880f7 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -844,12 +844,13 @@ static void encode_diropargs3(struct xdr_stream *xdr, const struct nfs_fh *fh,
  *		nfs_fh3  object;
  *	};
  */
-static void nfs3_xdr_enc_getattr3args(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs3_xdr_enc_getattr3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	const struct nfs_fh *fh = obj;
 	encode_nfs_fh3(xdr, fh);
+	return 0;
 }
 
 /*
@@ -883,14 +884,15 @@ static void encode_sattrguard3(struct xdr_stream *xdr,
 	}
 }
 
-static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	const struct nfs3_sattrargs *args = obj;
 	encode_nfs_fh3(xdr, args->fh);
 	encode_sattr3(xdr, args->sattr);
 	encode_sattrguard3(xdr, args);
+	return 0;
 }
 
 /*
@@ -900,12 +902,13 @@ static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
  *		diropargs3  what;
  *	};
  */
-static void nfs3_xdr_enc_lookup3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_lookup3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs3_diropargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
+	return 0;
 }
 
 /*
@@ -923,12 +926,13 @@ static void encode_access3args(struct xdr_stream *xdr,
 	encode_uint32(xdr, args->access);
 }
 
-static void nfs3_xdr_enc_access3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_access3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs3_accessargs *args = obj;
 	encode_access3args(xdr, args);
+	return 0;
 }
 
 /*
@@ -938,14 +942,15 @@ static void nfs3_xdr_enc_access3args(struct rpc_rqst *req,
  *		nfs_fh3	symlink;
  *	};
  */
-static void nfs3_xdr_enc_readlink3args(struct rpc_rqst *req,
-				       struct xdr_stream *xdr,
-				       void *obj)
+static int nfs3_xdr_enc_readlink3args(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      void *obj)
 {
 	const struct nfs3_readlinkargs *args = obj;
 	encode_nfs_fh3(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS3_readlinkres_sz);
+	return 0;
 }
 
 /*
@@ -969,15 +974,16 @@ static void encode_read3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nfs3_xdr_enc_read3args(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nfs_pgio_args *args = obj;
 	encode_read3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS3_readres_sz);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
+	return 0;
 }
 
 /*
@@ -1012,13 +1018,14 @@ static void encode_write3args(struct xdr_stream *xdr,
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 }
 
-static void nfs3_xdr_enc_write3args(struct rpc_rqst *req,
-				    struct xdr_stream *xdr,
-				    void *obj)
+static int nfs3_xdr_enc_write3args(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   void *obj)
 {
 	const struct nfs_pgio_args *args = obj;
 	encode_write3args(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
+	return 0;
 }
 
 /*
@@ -1060,13 +1067,14 @@ static void encode_createhow3(struct xdr_stream *xdr,
 	}
 }
 
-static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_create3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs3_createargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_createhow3(xdr, args);
+	return 0;
 }
 
 /*
@@ -1077,13 +1085,14 @@ static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
  *		sattr3		attributes;
  *	};
  */
-static void nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
-				    struct xdr_stream *xdr,
-				    void *obj)
+static int nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   void *obj)
 {
 	const struct nfs3_mkdirargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_sattr3(xdr, args->sattr);
+	return 0;
 }
 
 /*
@@ -1106,13 +1115,14 @@ static void encode_symlinkdata3(struct xdr_stream *xdr,
 	encode_nfspath3(xdr, args->pages, args->pathlen);
 }
 
-static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	const struct nfs3_symlinkargs *args = obj;
 	encode_diropargs3(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_symlinkdata3(xdr, args);
+	return 0;
 }
 
 /*
@@ -1167,13 +1177,14 @@ static void encode_mknoddata3(struct xdr_stream *xdr,
 	}
 }
 
-static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
-				    struct xdr_stream *xdr,
-				    void *obj)
+static int nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   void *obj)
 {
 	const struct nfs3_mknodargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_mknoddata3(xdr, args);
+	return 0;
 }
 
 /*
@@ -1183,12 +1194,13 @@ static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
  *		diropargs3  object;
  *	};
  */
-static void nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs_removeargs *args = obj;
 	encode_diropargs3(xdr, args->fh, args->name.name, args->name.len);
+	return 0;
 }
 
 /*
@@ -1199,9 +1211,9 @@ static void nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
  *		diropargs3	to;
  *	};
  */
-static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs_renameargs *args = obj;
 	const struct qstr *old = args->old_name;
@@ -1209,6 +1221,7 @@ static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
 
 	encode_diropargs3(xdr, args->old_dir, old->name, old->len);
 	encode_diropargs3(xdr, args->new_dir, new->name, new->len);
+	return 0;
 }
 
 /*
@@ -1219,13 +1232,14 @@ static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
  *		diropargs3	link;
  *	};
  */
-static void nfs3_xdr_enc_link3args(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nfs3_xdr_enc_link3args(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nfs3_linkargs *args = obj;
 	encode_nfs_fh3(xdr, args->fromfh);
 	encode_diropargs3(xdr, args->tofh, args->toname, args->tolen);
+	return 0;
 }
 
 /*
@@ -1251,14 +1265,15 @@ static void encode_readdir3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static void nfs3_xdr_enc_readdir3args(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs3_xdr_enc_readdir3args(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	const struct nfs3_readdirargs *args = obj;
 	encode_readdir3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
+	return 0;
 }
 
 /*
@@ -1292,14 +1307,15 @@ static void encode_readdirplus3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static void nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req,
-					  struct xdr_stream *xdr,
-					  void *obj)
+static int nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req,
+					 struct xdr_stream *xdr,
+					 void *obj)
 {
 	const struct nfs3_readdirargs *args = obj;
 	encode_readdirplus3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
+	return 0;
 }
 
 /*
@@ -1323,19 +1339,20 @@ static void encode_commit3args(struct xdr_stream *xdr,
 	*p = cpu_to_be32(args->count);
 }
 
-static void nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs_commitargs *args = obj;
 	encode_commit3args(xdr, args);
+	return 0;
 }
 
 #ifdef CONFIG_NFS_V3_ACL
 
-static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs3_getaclargs *args = obj;
 	encode_nfs_fh3(xdr, args->fh);
@@ -1344,11 +1361,12 @@ static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
 		prepare_reply_buffer(req, args->pages, 0,
 					NFSACL_MAXPAGES << PAGE_SHIFT,
 					ACL3_getaclres_sz);
+	return 0;
 }
 
-static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs3_setaclargs *args = obj;
 	unsigned int base;
@@ -1373,6 +1391,7 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 			    args->acl_default : NULL, 1,
 			    NFS_ACL_DEFAULT);
 	BUG_ON(error < 0);
+	return 0;
 }
 
 #endif  /* CONFIG_NFS_V3_ACL */
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8775318..ba9a6b8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2059,8 +2059,8 @@ static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
 /*
  * Encode an ACCESS request
  */
-static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	const struct nfs4_accessargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2073,13 +2073,14 @@ static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_access(xdr, args->access, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode LOOKUP request
  */
-static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	const struct nfs4_lookup_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2093,14 +2094,15 @@ static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getfh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode LOOKUP_ROOT request
  */
-static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs4_lookup_root_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2113,13 +2115,14 @@ static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
 	encode_getfh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode REMOVE request
  */
-static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	const struct nfs_removeargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2131,13 +2134,14 @@ static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_remove(xdr, &args->name, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode RENAME request
  */
-static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
+			void *obj)
 {
 	const struct nfs_renameargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2151,12 +2155,13 @@ static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->new_dir, &hdr);
 	encode_rename(xdr, args->old_name, args->new_name, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode LINK request
  */
-static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
+static int nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
 			     void *obj)
 {
 	const struct nfs4_link_arg *args = obj;
@@ -2173,13 +2178,14 @@ static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_restorefh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode CREATE request
  */
-static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	const struct nfs4_create_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2193,22 +2199,23 @@ static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getfh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode SYMLINK request
  */
-static void nfs4_xdr_enc_symlink(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 void *obj)
+static int nfs4_xdr_enc_symlink(struct rpc_rqst *req, struct xdr_stream *xdr,
+				void *obj)
 {
-	nfs4_xdr_enc_create(req, xdr, obj);
+	return nfs4_xdr_enc_create(req, xdr, obj);
 }
 
 /*
  * Encode GETATTR request
  */
-static void nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 void *obj)
+static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
+				void *obj)
 {
 	const struct nfs4_getattr_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2220,13 +2227,14 @@ static void nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a CLOSE request
  */
-static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       void *obj)
+static int nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      void *obj)
 {
 	struct nfs_closeargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2239,13 +2247,14 @@ static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_close(xdr, args, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode an OPEN request
  */
-static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      void *obj)
+static int nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
+			     void *obj)
 {
 	struct nfs_openargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2261,14 +2270,15 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 		encode_access(xdr, args->access, &hdr);
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode an OPEN_CONFIRM request
  */
-static void nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	struct nfs_open_confirmargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2279,14 +2289,15 @@ static void nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open_confirm(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode an OPEN request with no attributes.
  */
-static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	struct nfs_openargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2301,14 +2312,15 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 		encode_access(xdr, args->access, &hdr);
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode an OPEN_DOWNGRADE request
  */
-static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
-					struct xdr_stream *xdr,
-					void *obj)
+static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       void *obj)
 {
 	struct nfs_closeargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2321,13 +2333,14 @@ static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
 	encode_open_downgrade(xdr, args, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a LOCK request
  */
-static void nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      void *obj)
+static int nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
+			     void *obj)
 {
 	struct nfs_lock_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2339,13 +2352,14 @@ static void nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_lock(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a LOCKT request
  */
-static void nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       void *obj)
+static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      void *obj)
 {
 	struct nfs_lockt_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2357,13 +2371,14 @@ static void nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_lockt(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a LOCKU request
  */
-static void nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       void *obj)
+static int nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      void *obj)
 {
 	struct nfs_locku_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2375,11 +2390,12 @@ static void nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_locku(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
-static void nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
-					   struct xdr_stream *xdr,
-					void *obj)
+static int nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
+					  struct xdr_stream *xdr,
+					  void *obj)
 {
 	struct nfs_release_lockowner_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2389,13 +2405,14 @@ static void nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_release_lockowner(xdr, &args->lock_owner, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a READLINK request
  */
-static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  void *obj)
+static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 void *obj)
 {
 	const struct nfs4_readlink *args = obj;
 	struct compound_hdr hdr = {
@@ -2410,13 +2427,14 @@ static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
 	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, args->pages,
 			args->pgbase, args->pglen);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a READDIR request
  */
-static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 void *obj)
+static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
+				void *obj)
 {
 	const struct nfs4_readdir_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2434,13 +2452,14 @@ static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
 			__func__, hdr.replen << 2, args->pages,
 			args->pgbase, args->count);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a READ request
  */
-static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      void *obj)
+static int nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
+			     void *obj)
 {
 	struct nfs_pgio_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2456,13 +2475,14 @@ static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
 			 args->pages, args->pgbase, args->count);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode an SETATTR request
  */
-static void nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 void *obj)
+static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
+				void *obj)
 {
 	struct nfs_setattrargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2475,13 +2495,14 @@ static void nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_setattr(xdr, args, args->server, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a GETACL request
  */
-static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	struct nfs_getaclargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2499,13 +2520,14 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 		args->acl_pages, args->acl_pgbase, args->acl_len);
 
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode a WRITE request
  */
-static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       void *obj)
+static int nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      void *obj)
 {
 	struct nfs_pgio_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2520,13 +2542,14 @@ static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
 	if (args->bitmask)
 		encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  *  a COMMIT request
  */
-static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	struct nfs_commitargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2538,13 +2561,14 @@ static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_commit(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * FSINFO request
  */
-static void nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	struct nfs4_fsinfo_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2556,13 +2580,14 @@ static void nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_fsinfo(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a PATHCONF request
  */
-static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  void *obj)
+static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 void *obj)
 {
 	const struct nfs4_pathconf_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2575,13 +2600,14 @@ static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getattr_one(xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
 			   &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a STATFS request
  */
-static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	const struct nfs4_statfs_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2594,14 +2620,15 @@ static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getattr_two(xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
 			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * GETATTR_BITMAP request
  */
-static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	struct nfs4_server_caps_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2617,13 +2644,14 @@ static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
 			   FATTR4_WORD0_SYMLINK_SUPPORT|
 			   FATTR4_WORD0_ACLSUPPORT, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a RENEW request
  */
-static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       void *obj)
+static int nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
+			      void *obj)
 {
 	struct nfs_client *clp = obj;
 	struct compound_hdr hdr = {
@@ -2633,14 +2661,15 @@ static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_renew(xdr, clp->cl_clientid, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a SETCLIENTID request
  */
-static void nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	struct nfs4_setclientid *sc = obj;
 	struct compound_hdr hdr = {
@@ -2650,14 +2679,15 @@ static void nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_setclientid(xdr, sc, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a SETCLIENTID_CONFIRM request
  */
-static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
-					     struct xdr_stream *xdr,
-					     void *obj)
+static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
+					    struct xdr_stream *xdr,
+					    void *obj)
 {
 	struct nfs4_setclientid_res *arg = obj;
 	struct compound_hdr hdr = {
@@ -2667,14 +2697,15 @@ static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_setclientid_confirm(xdr, arg, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * DELEGRETURN request
  */
-static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	const struct nfs4_delegreturnargs *args = obj;
 	struct compound_hdr hdr = {
@@ -2687,14 +2718,15 @@ static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_delegreturn(xdr, args->stateid, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode FS_LOCATIONS request
  */
-static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	struct nfs4_fs_locations_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2721,12 +2753,13 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
 			0, PAGE_SIZE);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode SECINFO request
  */
-static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
+static int nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
 				void *obj)
 {
@@ -2740,14 +2773,15 @@ static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
 	encode_putfh(xdr, args->dir_fh, &hdr);
 	encode_secinfo(xdr, args->name, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode FSID_PRESENT request
  */
-static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	struct nfs4_fsid_present_arg *args = obj;
 	struct compound_hdr hdr = {
@@ -2761,15 +2795,16 @@ static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
 	if (args->renew)
 		encode_renew(xdr, args->clientid, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 #if defined(CONFIG_NFS_V4_1)
 /*
  * BIND_CONN_TO_SESSION request
  */
-static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
-				struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
+					     struct xdr_stream *xdr,
+					     void *obj)
 {
 	struct nfs41_bind_conn_to_session_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2779,14 +2814,15 @@ static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_bind_conn_to_session(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * EXCHANGE_ID request
  */
-static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
-				     struct xdr_stream *xdr,
-				     void *obj)
+static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    void *obj)
 {
 	struct nfs41_exchange_id_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2796,14 +2832,15 @@ static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_exchange_id(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a CREATE_SESSION request
  */
-static void nfs4_xdr_enc_create_session(struct rpc_rqst *req,
-					struct xdr_stream *xdr,
-					void *obj)
+static int nfs4_xdr_enc_create_session(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       void *obj)
 {
 	struct nfs41_create_session_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2813,14 +2850,15 @@ static void nfs4_xdr_enc_create_session(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_create_session(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a DESTROY_SESSION request
  */
-static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
-					 struct xdr_stream *xdr,
-					 void *obj)
+static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					void *obj)
 {
 	struct nfs4_session *session = obj;
 	struct compound_hdr hdr = {
@@ -2830,12 +2868,13 @@ static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_destroy_session(xdr, session, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a DESTROY_CLIENTID request
  */
-static void nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
+static int nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
 					 struct xdr_stream *xdr,
 					 void *obj)
 {
@@ -2847,13 +2886,14 @@ static void nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_destroy_clientid(xdr, clp->cl_clientid, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a SEQUENCE request
  */
-static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  void *obj)
+static int nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
+				 void *obj)
 {
 	struct nfs4_sequence_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2863,14 +2903,15 @@ static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a GET_LEASE_TIME request
  */
-static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
-					struct xdr_stream *xdr,
-					void *obj)
+static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       void *obj)
 {
 	struct nfs4_get_lease_time_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2883,14 +2924,15 @@ static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
 	encode_putrootfh(xdr, &hdr);
 	encode_fsinfo(xdr, lease_bitmap, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * a RECLAIM_COMPLETE request
  */
-static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
-					  struct xdr_stream *xdr,
-					  void *obj)
+static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
+					 struct xdr_stream *xdr,
+					 void *obj)
 {
 	struct nfs41_reclaim_complete_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2901,14 +2943,15 @@ static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_reclaim_complete(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode GETDEVICEINFO request
  */
-static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
-				       struct xdr_stream *xdr,
-				       void *obj)
+static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      void *obj)
 {
 	struct nfs4_getdeviceinfo_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2926,14 +2969,15 @@ static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
 			 args->pdev->pglen);
 
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  *  Encode LAYOUTGET request
  */
-static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	struct nfs4_layoutget_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2949,14 +2993,15 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
 	    args->layout.pages, 0, args->layout.pglen);
 
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  *  Encode LAYOUTCOMMIT request
  */
-static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	struct nfs4_layoutcommit_args *args = obj;
 	struct nfs4_layoutcommit_data *data =
@@ -2971,14 +3016,15 @@ static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
 	encode_layoutcommit(xdr, data->args.inode, args, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  * Encode LAYOUTRETURN request
  */
-static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	struct nfs4_layoutreturn_args *args = obj;
 	struct compound_hdr hdr = {
@@ -2990,6 +3036,7 @@ static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
 	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
 	encode_layoutreturn(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
@@ -3015,9 +3062,9 @@ static int nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
 /*
  *  Encode TEST_STATEID request
  */
-static void nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
-				      struct xdr_stream *xdr,
-				      void *obj)
+static int nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     void *obj)
 {
 	struct nfs41_test_stateid_args *args = obj;
 	struct compound_hdr hdr = {
@@ -3028,12 +3075,13 @@ static void nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_test_stateid(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
  *  Encode FREE_STATEID request
  */
-static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
+static int nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
 				     void *obj)
 {
@@ -3046,6 +3094,7 @@ static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_free_stateid(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -6306,8 +6355,8 @@ out:
 /*
  * Encode an SETACL request
  */
-static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
-				void *obj)
+static int nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
+			       void *obj)
 {
 	struct nfs_setaclargs *args = obj;
 	struct compound_hdr hdr = {
@@ -6319,6 +6368,7 @@ static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_setacl(xdr, args, &hdr);
 	encode_nops(&hdr);
+	return 0;
 }
 
 /*
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a7167b8..f658f6d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -476,17 +476,18 @@ out_default:
 /*
  * NB: Without this zero space reservation, callbacks over krb5p fail
  */
-static void nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 void *__unused)
+static int nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
+				void *__unused)
 {
 	xdr_reserve_space(xdr, 0);
+	return 0;
 }
 
 /*
  * 20.2. Operation 4: CB_RECALL - Recall a Delegation
  */
-static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
-				   void *obj)
+static int nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nfsd4_callback *cb = obj;
 	const struct nfs4_delegation *dp = cb_to_delegation(cb);
@@ -499,6 +500,7 @@ static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_cb_sequence4args(xdr, cb, &hdr);
 	encode_cb_recall4args(xdr, dp, &hdr);
 	encode_cb_nops(&hdr);
+	return 0;
 }
 
 
@@ -601,9 +603,9 @@ static void encode_cb_layout4args(struct xdr_stream *xdr,
 	hdr->nops++;
 }
 
-static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   void *obj)
+static int nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  void *obj)
 {
 	const struct nfsd4_callback *cb = obj;
 	const struct nfs4_layout_stateid *ls =
@@ -617,6 +619,7 @@ static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
 	encode_cb_sequence4args(xdr, cb, &hdr);
 	encode_cb_layout4args(xdr, ls, &hdr);
 	encode_cb_nops(&hdr);
+	return 0;
 }
 
 static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 7177815..d68f71e 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -211,7 +211,7 @@ struct xdr_stream {
  * These are the xdr_stream style generic XDR encode and decode functions.
  */
 struct rpc_rqst;
-typedef void	(*kxdreproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj);
+typedef int	(*kxdreproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj);
 typedef int	(*kxdrdproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 47f38be..11f78ac2 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -767,13 +767,13 @@ rpcauth_checkverf(struct rpc_task *task, __be32 *p)
 	return cred->cr_ops->crvalidate(task, p);
 }
 
-static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
+static int rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 				   __be32 *data, void *obj)
 {
 	struct xdr_stream xdr;
 
 	xdr_init_encode(&xdr, &rqstp->rq_snd_buf, data);
-	encode(rqstp, &xdr, obj);
+	return encode(rqstp, &xdr, obj);
 }
 
 int
@@ -787,8 +787,7 @@ rpcauth_wrap_req(struct rpc_task *task, kxdreproc_t encode, void *rqstp,
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
 	/* By default, we encode the arguments normally. */
-	rpcauth_wrap_req_encode(encode, rqstp, data, obj);
-	return 0;
+	return rpcauth_wrap_req_encode(encode, rqstp, data, obj);
 }
 
 static int
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 6b9dc37..26601cd 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -731,9 +731,9 @@ static int gssx_enc_cb(struct xdr_stream *xdr, struct gssx_cb *cb)
 	return err;
 }
 
-void gssx_enc_accept_sec_context(struct rpc_rqst *req,
-				 struct xdr_stream *xdr,
-				 void *obj)
+int gssx_enc_accept_sec_context(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				void *obj)
 {
 	struct gssx_arg_accept_sec_context *arg = obj;
 	int err;
@@ -786,6 +786,7 @@ void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 done:
 	if (err)
 		dprintk("RPC:       gssx_enc_accept_sec_context: %d\n", err);
+	return 0;
 }
 
 int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
index eb98597..425085c 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.h
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
@@ -177,9 +177,9 @@ struct gssx_res_accept_sec_context {
 #define gssx_dec_store_cred NULL
 #define gssx_enc_init_sec_context NULL
 #define gssx_dec_init_sec_context NULL
-void gssx_enc_accept_sec_context(struct rpc_rqst *req,
-				 struct xdr_stream *xdr,
-				 void *);
+int gssx_enc_accept_sec_context(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				void *);
 int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
 				void *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8bee221..db1a4bb 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2392,8 +2392,9 @@ out_overflow:
 	goto out_garbage;
 }
 
-static void rpcproc_encode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj)
+static int rpcproc_encode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj)
 {
+	return 0;
 }
 
 static int rpcproc_decode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr, void *obj)
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 7c71283..1d31943 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -844,8 +844,8 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
  * XDR functions for rpcbind
  */
 
-static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     void *obj)
+static int rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
+			    void *obj)
 {
 	const struct rpcbind_args *rpcb = obj;
 	__be32 *p;
@@ -860,6 +860,7 @@ static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(rpcb->r_vers);
 	*p++ = cpu_to_be32(rpcb->r_prot);
 	*p   = cpu_to_be32(rpcb->r_port);
+	return 0;
 }
 
 static int rpcb_dec_getport(struct rpc_rqst *req, struct xdr_stream *xdr,
@@ -921,8 +922,8 @@ static void encode_rpcb_string(struct xdr_stream *xdr, const char *string,
 	xdr_encode_opaque(p, string, len);
 }
 
-static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     void *obj)
+static int rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
+			    void *obj)
 {
 	const struct rpcbind_args *rpcb = obj;
 	__be32 *p;
@@ -940,6 +941,7 @@ static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_rpcb_string(xdr, rpcb->r_netid, RPCBIND_MAXNETIDLEN);
 	encode_rpcb_string(xdr, rpcb->r_addr, RPCBIND_MAXUADDRLEN);
 	encode_rpcb_string(xdr, rpcb->r_owner, RPCB_MAXOWNERLEN);
+	return 0;
 }
 
 static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
-- 
2.1.0

