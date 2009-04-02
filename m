From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 21/21] SQUASHME: get rid of CONFIG_NFSD_V4_1
Date: Fri,  3 Apr 2009 01:39:04 +0300
Message-ID: <1238711944-22676-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27684 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763874AbZDBWjJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:39:09 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And update Documentation

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 Documentation/filesystems/nfs41-server.txt |   16 +++++++++++-----
 fs/nfsd/nfs4callback.c                     |   16 ----------------
 fs/nfsd/nfs4proc.c                         |    6 ++----
 fs/nfsd/nfs4state.c                        |   20 --------------------
 fs/nfsd/nfs4xdr.c                          |   21 ++-------------------
 fs/nfsd/nfssvc.c                           |    2 --
 include/linux/nfsd/cache.h                 |    4 ----
 include/linux/nfsd/nfsd.h                  |   22 ----------------------
 include/linux/nfsd/state.h                 |    6 ++++--
 include/linux/nfsd/xdr4.h                  |    8 ++------
 include/linux/sunrpc/svc.h                 |    2 --
 11 files changed, 21 insertions(+), 102 deletions(-)

diff --git a/Documentation/filesystems/nfs41-server.txt b/Documentation/filesystems/nfs41-server.txt
index 8124a67..05d81cb 100644
--- a/Documentation/filesystems/nfs41-server.txt
+++ b/Documentation/filesystems/nfs41-server.txt
@@ -1,14 +1,20 @@
 NFSv4.1 Server Implementation
 
+Server support for minorversion 1 can be controlled using the
+/proc/fs/nfsd/versions control file.  The string output returned
+by reading this file will contain either "+4.1" or "-4.1"
+correspondingly.
+
+Currently, server support for minorversion 1 is disabled by default.
+It can be enabled at run time by writing the string "+4.1" to
+the /proc/fs/nfsd/versions control file.  Note that to write this
+control file, the nfsd service must be taken down.  Use your user-mode
+nfs-utils to set this up; see rpc.nfsd(8)
+
 The NFSv4 minorversion 1 (NFSv4.1) implementation in nfsd is based
 on the latest NFSv4.1 Internet Draft:
 http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-29
 
-If you're a developer or just eager to test the code, set
-CONFIG_NFSD_V4_1 to 'y' in your kernel configuration file.
-This will allow the server to serve both NFSv4 and NFSv4.1
-clients concurrently.
-
 From the many new features in NFSv4.1 the current implementation
 focuses on the mandatory-to-implement NFSv4.1 Sessions, providing
 "exactly once" semantics and better control and throttling of the
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 10c6a80..b3c84cd 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -276,10 +276,8 @@ encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
 	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
 
 	WRITE32(OP_CB_SEQUENCE);
-#ifdef CONFIG_NFSD_V4_1
 	WRITEMEM(args->cbs_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(args->cbs_clp->cl_cb_seq_nr);
-#endif /* CONFIG_NFSD_V4_1 */
 	WRITE32(0);		/* slotid, always 0 */
 	WRITE32(0);		/* highest slotid always 0 */
 	WRITE32(0);		/* cachethis always 0 */
@@ -300,10 +298,8 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 static u32
 nfs4_xdr_minorversion(struct nfs4_rpc_args *rpc_args)
 {
-#if defined(CONFIG_NFSD_V4_1)
 	if (rpc_args->args_seq)
 		return rpc_args->args_seq->cbs_minorversion;
-#endif /* CONFIG_NFSD_V4_1 */
 	return 0;
 }
 
@@ -390,7 +386,6 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
 
 	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
 	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
-#ifdef CONFIG_NFSD_V4_1
 	if (memcmp(id.data, res->cbs_clp->cl_sessionid.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
@@ -401,7 +396,6 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
 		dprintk("%s Invalid sequence number\n", __func__);
 		goto out;
 	}
-#endif /* CONFIG_NFSD_V4_1 */
 	READ32(dummy); 	/* slotid must be 0 */
 	if (dummy != 0) {
 		dprintk("%s Invalid slotid\n", __func__);
@@ -532,13 +526,11 @@ static struct rpc_clnt *setup_callback_client(struct nfs4_client *clp)
 	addr.sin_family = AF_INET;
 	addr.sin_port = htons(cb->cb_port);
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
-#if defined(CONFIG_NFSD_V4_1)
 	if (cb->cb_minorversion) {
 		BUG_ON(cb->cb_minorversion != 1);
 		args.bc_sock = container_of(clp->cl_cb_xprt, struct svc_sock,
 					    sk_xprt);
 	}
-#endif /* CONFIG_NFSD_V4_1 */
 
 	dprintk("%s: program %s 0x%x nrvers %u version %u minorversion %u\n",
 		__func__, args.program->name, args.prognumber,
@@ -618,7 +610,6 @@ static int _nfsd4_cb_sync(struct nfs4_client *clp,
 	return rpc_call_sync(clp->cl_callback.cb_client, msg, RPC_TASK_SOFT);
 }
 
-#if defined(CONFIG_NFSD_V4_1)
 /*
  * FIXME: cb_sequence should support referring call lists, cachethis, and
  * multiple slots
@@ -678,13 +669,6 @@ static int nfsd4_cb_sync(struct nfs4_client *clp,
 		_nfsd41_cb_sync(clp, msg, flags) :
 		_nfsd4_cb_sync(clp, msg, flags);
 }
-#else  /* CONFIG_NFSD_V4_1 */
-static int nfsd4_cb_sync(struct nfs4_client *clp,
-			 struct rpc_message *msg, int flags)
-{
-	return _nfsd4_cb_sync(clp, msg, flags);
-}
-#endif /* CONFIG_NFSD_V4_1 */
 
 /*
  * called with dp->dl_count inc'ed.
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d39af3d..83044e8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -896,13 +896,11 @@ nfsd4_enc_no_page_replay(struct nfsd4_compoundargs *args,
  */
 static bool nfs41_op_ordering_ok(struct nfsd4_compoundargs *args)
 {
-#if defined(CONFIG_NFSD_V4_1)
 	if (args->minorversion && args->opcnt > 0) {
 		struct nfsd4_op *op = &args->ops[0];
 		return (op->status == nfserr_op_illegal) ||
 		       (nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP);
 	}
-#endif /* CONFIG_NFSD_V4_1 */
 	return true;
 }
 
@@ -1197,7 +1195,8 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_RELEASE_LOCKOWNER",
 	},
-#if defined(CONFIG_NFSD_V4_1)
+
+	/* NFSv4.1 operations */
 	[OP_EXCHANGE_ID] = {
 		.op_func = (nfsd4op_func)nfsd4_exchange_id,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
@@ -1218,7 +1217,6 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
 	},
-#endif /* CONFIG_NFSD_V4_1 */
 };
 
 static const char *nfsd4_op_name(unsigned opnum)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 92d5feb..6c0975f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -68,9 +68,7 @@ static u32 current_delegid = 1;
 static u32 nfs4_init;
 static stateid_t zerostateid;             /* bits all 0 */
 static stateid_t onestateid;              /* bits all 1 */
-#ifdef CONFIG_NFSD_V4_1
 static u64 current_sessionid = 1;
-#endif /* CONFIG_NFSD_V4_1 */
 
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
@@ -385,7 +383,6 @@ static void release_openowner(struct nfs4_stateowner *sop)
 	nfs4_put_stateowner(sop);
 }
 
-#if defined(CONFIG_NFSD_V4_1)
 static DEFINE_SPINLOCK(sessionid_lock);
 #define SESSION_HASH_SIZE	512
 static struct list_head sessionid_hashtbl[SESSION_HASH_SIZE];
@@ -588,9 +585,6 @@ free_session(struct kref *kref)
 	kfree(ses->se_slots);
 	kfree(ses);
 }
-#else /* CONFIG_NFSD_V4_1 */
-static inline void release_session(struct nfsd4_session *ses) {}
-#endif /* CONFIG_NFSD_V4_1 */
 
 static inline void
 renew_client(struct nfs4_client *clp)
@@ -657,12 +651,10 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
-#if defined(CONFIG_NFSD_V4_1)
 	if (clp->cl_cb_xprt)
 		svc_xprt_put(clp->cl_cb_xprt);
 	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
 			     clp->cl_slot.sl_cache_entry.ce_resused);
-#endif /* CONFIG_NFSD_V4_1 */
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -709,14 +701,12 @@ expire_client(struct nfs4_client *clp)
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_openowner(sop);
 	}
-#ifdef CONFIG_NFSD_V4_1
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session  *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
 				 se_perclnt);
 		release_session(ses);
 	}
-#endif /* CONFIG_NFSD_V4_1 */
 	put_nfs4_client(clp);
 }
 
@@ -734,10 +724,8 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
-#if defined(CONFIG_NFSD_V4_1)
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	mutex_init(&clp->cl_cb_mutex);
-#endif /* CONFIG_NFSD_V4_1 */
 	INIT_LIST_HEAD(&clp->cl_lru);
 	return clp;
 }
@@ -879,12 +867,8 @@ find_unconfirmed_client(clientid_t *clid)
 static inline int
 match_clientid_establishment(struct nfs4_client *clp, bool use_exchange_id)
 {
-#if defined(CONFIG_NFSD_V4_1)
 	bool has_exchange_flags = (clp->cl_exchange_flags != 0);
 	return use_exchange_id == has_exchange_flags;
-#else  /* CONFIG_NFSD_V4_1 */
-	return 1;
-#endif /* CONFIG_NFSD_V4_1 */
 }
 
 static struct nfs4_client *
@@ -1009,7 +993,6 @@ out_err:
 	return;
 }
 
-#if defined(CONFIG_NFSD_V4_1)
 void
 nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
 {
@@ -1547,7 +1530,6 @@ out:
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
-#endif /* CONFIG_NFSD_V4_1 */
 
 __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
@@ -4023,10 +4005,8 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
 	}
-#if defined(CONFIG_NFSD_V4_1)
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
-#endif /* CONFIG_NFSD_V4_1 */
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5e8da86..fba604e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1040,7 +1040,6 @@ nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_rel
 	DECODE_TAIL;
 }
 
-#if defined(CONFIG_NFSD_V4_1)
 static __be32
 nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 			 struct nfsd4_exchange_id *exid)
@@ -1273,7 +1272,6 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
 
 	DECODE_TAIL;
 }
-#endif /* CONFIG_NFSD_V4_1 */
 
 static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
@@ -1329,7 +1327,6 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_release_lockowner,
 };
 
-#if defined(CONFIG_NFSD_V4_1)
 static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_ACCESS]		(nfsd4_dec)nfsd4_decode_access,
 	[OP_CLOSE]		(nfsd4_dec)nfsd4_decode_close,
@@ -1390,7 +1387,6 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_DESTROY_CLIENTID]	(nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_RECLAIM_COMPLETE]	(nfsd4_dec)nfsd4_decode_notsupp,
 };
-#endif /* CONFIG_NFSD_V4_1 */
 
 struct nfsd4_minorversion_ops {
 	nfsd4_dec *decoders;
@@ -1399,9 +1395,7 @@ struct nfsd4_minorversion_ops {
 
 static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
 	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
-#if defined(CONFIG_NFSD_V4_1)
 	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
-#endif /* CONFIG_NFSD_V4_1 */
 };
 
 static __be32
@@ -2948,7 +2942,6 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 	return nfserr;
 }
 
-#if defined(CONFIG_NFSD_V4_1)
 static __be32
 nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
 			 struct nfsd4_exchange_id *exid)
@@ -3085,7 +3078,6 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	ADJUST_ARGS();
 	return 0;
 }
-#endif /* CONFIG_NFSD_V4_1 */
 
 static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
@@ -3138,7 +3130,8 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_VERIFY]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_WRITE]		= (nfsd4_enc)nfsd4_encode_write,
 	[OP_RELEASE_LOCKOWNER]	= (nfsd4_enc)nfsd4_encode_noop,
-#if defined(CONFIG_NFSD_V4_1)
+
+	/* NFSv4.1 operations */
 	[OP_BACKCHANNEL_CTL]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_BIND_CONN_TO_SESSION] = (nfsd4_enc)nfsd4_encode_noop,
 	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
@@ -3158,10 +3151,8 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
-#endif /* CONFIG_NFSD_V4_1 */
 };
 
-#if defined(CONFIG_NFSD_V4_1)
 /*
  * Calculate the total amount of memory that the compound response has taken
  * after encoding the current operation.
@@ -3209,12 +3200,6 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 	else
 		return nfserr_rep_too_big_to_cache;
 }
-#else /* CONFIG_NFSD_V4_1 */
-static inline int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
-{
-	return 0;
-}
-#endif /* CONFIG_NFSD_V4_1 */
 
 void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
@@ -3335,7 +3320,6 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
-#ifdef CONFIG_NFSD_V4_1
 	if (nfsd4_has_session(&resp->cstate)) {
 		if (resp->cstate.status == nfserr_replay_cache &&
 				!nfsd4_no_page_in_cache(resp)) {
@@ -3348,7 +3332,6 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		if (resp->cstate.slot->sl_session)
 			nfsd4_put_session(resp->cstate.slot->sl_session);
 	}
-#endif /* CONFIG_NFSD_V4_1 */
 	return 1;
 }
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 1f26d9f..e9d5773 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -236,13 +236,11 @@ void nfsd_reset_versions(void)
  */
 static void set_max_drc(void)
 {
-#ifdef CONFIG_NFSD_V4_1
 	nfsd_serv->sv_drc_max_pages = nr_free_buffer_pages()
 						>> NFSD_DRC_SIZE_SHIFT;
 	nfsd_serv->sv_drc_pages_used = 0;
 	dprintk("%s svc_drc_max_pages %u\n", __func__,
 		nfsd_serv->sv_drc_max_pages);
-#endif /* CONFIG_NFSD_V4_1 */
 }
 
 int nfsd_create_serv(void)
diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 57a83c7..a59a2df 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -75,10 +75,6 @@ int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *, int);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
-#ifdef CONFIG_NFSD_V4_1
 void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
-#else /* CONFIG_NFSD_V4_1 */
-static inline void nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp) {}
-#endif /* CONFIG_NFSD_V4_1 */
 
 #endif /* NFSCACHE_H */
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 27b9cf5..5494dcd 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -23,11 +23,7 @@
 /*
  * nfsd version
  */
-#if defined(CONFIG_NFSD_V4_1)
 #define NFSD_SUPPORTED_MINOR_VERSION	1
-#else /* CONFIG_NFSD_V4_1 */
-#define NFSD_SUPPORTED_MINOR_VERSION	0
-#endif /* CONFIG_NFSD_V4_1 */
 
 /*
  * Flags for nfsd_permission
@@ -378,8 +374,6 @@ extern struct timeval	nfssvc_boot;
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
 
-#if defined(CONFIG_NFSD_V4_1)
-
 /* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
 #define NFSD_DRC_SIZE_SHIFT	7
 
@@ -400,22 +394,6 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD2
 			    : NFSD4_SUPPORTED_ATTRS_WORD2;
 }
-#else  /* CONFIG_NFSD_V4_1 */
-static inline u32 nfsd_suppattrs0(u32 minorversion)
-{
-	return NFSD4_SUPPORTED_ATTRS_WORD0;
-}
-
-static inline u32 nfsd_suppattrs1(u32 minorversion)
-{
-	return NFSD4_SUPPORTED_ATTRS_WORD1;
-}
-
-static inline u32 nfsd_suppattrs2(u32 minorversion)
-{
-	return NFSD4_SUPPORTED_ATTRS_WORD2;
-}
-#endif /* CONFIG_NFSD_V4_1 */
 
 /* These will return ERR_INVAL if specified in GETATTR or READDIR. */
 #define NFSD_WRITEONLY_ATTRS_WORD1							    \
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 42d7fd9..0789ece 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -195,16 +195,18 @@ struct nfs4_client {
 	struct nfs4_callback	cl_callback;    /* callback info */
 	atomic_t		cl_count;	/* ref count */
 	u32			cl_firststate;	/* recovery dir creation */
-#ifdef CONFIG_NFSD_V4_1
+
+	/* for nfs41 */
 	struct list_head	cl_sessions;
 	struct nfsd4_slot	cl_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
+
+	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
 	u32			cl_cb_seq_nr;
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct mutex		cl_cb_mutex;
-#endif /* CONFIG_NFSD_V4_1 */
 };
 
 /* struct nfs4_client_reset
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 24d62c1..fc5b1ab 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -353,7 +353,6 @@ struct nfsd4_write {
 	nfs4_verifier	wr_verifier;        /* response */
 };
 
-#if defined(CONFIG_NFSD_V4_1)
 struct nfsd4_exchange_id {
 	nfs4_verifier	verifier;
 	struct xdr_netobj clname;
@@ -401,7 +400,6 @@ struct nfsd4_sequence {
 struct nfsd4_destroy_session {
 	struct nfs4_sessionid	sessionid;
 };
-#endif /* CONFIG_NFSD_V4_1 */
 
 struct nfsd4_op {
 	int					opnum;
@@ -437,12 +435,12 @@ struct nfsd4_op {
 		struct nfsd4_verify		verify;
 		struct nfsd4_write		write;
 		struct nfsd4_release_lockowner	release_lockowner;
-#if defined(CONFIG_NFSD_V4_1)
+
+		/* NFSv4.1 */
 		struct nfsd4_exchange_id	exchange_id;
 		struct nfsd4_create_session	create_session;
 		struct nfsd4_destroy_session	destroy_session;
 		struct nfsd4_sequence		sequence;
-#endif /* CONFIG_NFSD_V4_1 */
 	} u;
 	struct nfs4_replay *			replay;
 };
@@ -526,7 +524,6 @@ extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
-#if defined(CONFIG_NFSD_V4_1)
 extern void nfsd4_set_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		struct nfsd4_sequence *seq);
@@ -542,7 +539,6 @@ extern __be32 nfsd4_sequence(struct svc_rqst *,
 extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_destroy_session *);
-#endif /* CONFIG_NFSD_V4_1 */
 extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
 		struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index c4f0e1e..d209c63 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -95,10 +95,8 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
-#if defined(CONFIG_NFSD_V4_1)
 	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
 	unsigned int		sv_drc_pages_used;/* DRC pages used */
-#endif /* CONFIG_NFSD_V4_1 */
 };
 
 /*
-- 
1.6.2.1

