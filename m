From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too large
Date: Wed, 24 Jan 2007 14:20:20 -0500
Message-ID: <20070124192020.31133.78494.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9nhH-0001GT-5F
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:22:15 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9nhG-0004XJ-94
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:22:17 -0800
In-Reply-To: <20070124191704.31133.12713.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The RPC buffer size estimation logic in net/sunrpc/clnt.c always
significantly overestimates the requirements for the buffer size.
A little instrumentation demonstrated that in fact rpc_malloc was never
allocating the buffer from the mempool, but almost always called kmalloc.

To compute the size of the RPC buffer more precisely, split p_bufsiz into
two fields; one for the argument size, and one for the result size.

So now we will compute the sum of the exact call and reply header sizes,
and split the RPC buffer precisely between the two.  That should keep
almost all RPC buffers within the 2KiB buffer mempool limit.

And, we can finally be rid of RPC_SLACK_SPACE!

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c              |   10 +++----
 fs/lockd/xdr.c              |    7 +----
 fs/lockd/xdr4.c             |    7 +----
 fs/nfs/mount_clnt.c         |    7 +++--
 fs/nfs/nfs2xdr.c            |    7 +----
 fs/nfs/nfs3xdr.c            |   13 ++++----
 fs/nfs/nfs4xdr.c            |    7 +----
 fs/nfsd/nfs4callback.c      |    7 +----
 include/linux/sunrpc/clnt.h |    3 +-
 include/linux/sunrpc/xprt.h |    3 +-
 net/sunrpc/clnt.c           |   66 +++++++++++++++++++++++++------------------
 net/sunrpc/rpcb_clnt.c      |   21 +++++++++-----
 net/sunrpc/xprt.c           |    4 +--
 13 files changed, 84 insertions(+), 78 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index eb243ed..2102e2d 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -225,16 +225,13 @@ #define SM_mon_sz	(SM_mon_id_sz+4)
 #define SM_monres_sz	2
 #define SM_unmonres_sz	1
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 static struct rpc_procinfo	nsm_procedures[] = {
 [SM_MON] = {
 		.p_proc		= SM_MON,
 		.p_encode	= (kxdrproc_t) xdr_encode_mon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat_res,
-		.p_bufsiz	= MAX(SM_mon_sz, SM_monres_sz) << 2,
+		.p_arglen	= SM_mon_sz,
+		.p_replen	= SM_monres_sz,
 		.p_statidx	= SM_MON,
 		.p_name		= "MONITOR",
 	},
@@ -242,7 +239,8 @@ static struct rpc_procinfo	nsm_procedure
 		.p_proc		= SM_UNMON,
 		.p_encode	= (kxdrproc_t) xdr_encode_unmon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat,
-		.p_bufsiz	= MAX(SM_mon_id_sz, SM_unmonres_sz) << 2,
+		.p_arglen	= SM_mon_id_sz,
+		.p_replen	= SM_unmonres_sz,
 		.p_statidx	= SM_UNMON,
 		.p_name		= "UNMONITOR",
 	},
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 34dae5d..75dd023 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -531,10 +531,6 @@ #define NLM_testres_sz		NLM_cookie_sz+1+
 #define NLM_res_sz		NLM_cookie_sz+1
 #define NLM_norep_sz		0
 
-#ifndef MAX
-# define MAX(a, b)		(((a) > (b))? (a) : (b))
-#endif
-
 /*
  * For NLM, a void procedure really returns nothing
  */
@@ -545,7 +541,8 @@ #define PROC(proc, argtype, restype)	\
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = (kxdrproc_t) nlmclt_encode_##argtype,		\
 	.p_decode    = (kxdrproc_t) nlmclt_decode_##restype,		\
-	.p_bufsiz    = MAX(NLM_##argtype##_sz, NLM_##restype##_sz) << 2,	\
+	.p_arglen    = NLM_##argtype##_sz,				\
+	.p_replen    = NLM_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
 	.p_name      = #proc,						\
 	}
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index a782405..d354f3f 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -537,10 +537,6 @@ #define NLM4_testres_sz		NLM4_cookie_sz+
 #define NLM4_res_sz		NLM4_cookie_sz+1
 #define NLM4_norep_sz		0
 
-#ifndef MAX
-# define MAX(a,b)		(((a) > (b))? (a) : (b))
-#endif
-
 /*
  * For NLM, a void procedure really returns nothing
  */
@@ -551,7 +547,8 @@ #define PROC(proc, argtype, restype)				
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = (kxdrproc_t) nlm4clt_encode_##argtype,		\
 	.p_decode    = (kxdrproc_t) nlm4clt_decode_##restype,		\
-	.p_bufsiz    = MAX(NLM4_##argtype##_sz, NLM4_##restype##_sz) << 2,	\
+	.p_arglen    = NLM4_##argtype##_sz,				\
+	.p_replen    = NLM4_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
 	.p_name      = #proc,						\
 	}
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index f75fe72..ca5a266 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -133,13 +133,15 @@ xdr_decode_fhstatus3(struct rpc_rqst *re
 
 #define MNT_dirpath_sz		(1 + 256)
 #define MNT_fhstatus_sz		(1 + 8)
+#define MNT_fhstatus3_sz	(1 + 16)
 
 static struct rpc_procinfo	mnt_procedures[] = {
 [MNTPROC_MNT] = {
 	  .p_proc		= MNTPROC_MNT,
 	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,	
 	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus,
-	  .p_bufsiz		= MNT_dirpath_sz << 2,
+	  .p_arglen		= MNT_dirpath_sz,
+	  .p_replen		= MNT_fhstatus_sz,
 	  .p_statidx		= MNTPROC_MNT,
 	  .p_name		= "MOUNT",
 	},
@@ -150,7 +152,8 @@ static struct rpc_procinfo mnt3_procedur
 	  .p_proc		= MOUNTPROC3_MNT,
 	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,
 	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus3,
-	  .p_bufsiz		= MNT_dirpath_sz << 2,
+	  .p_arglen		= MNT_dirpath_sz,
+	  .p_replen		= MNT_fhstatus3_sz,
 	  .p_statidx		= MOUNTPROC3_MNT,
 	  .p_name		= "MOUNT",
 	},
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 3be4e72..abd9f8b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -687,16 +687,13 @@ nfs_stat_to_errno(int stat)
 	return nfs_errtbl[i].errno;
 }
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  (kxdrproc_t) nfs_xdr_##argtype,			\
 	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
-	.p_bufsiz   =  MAX(NFS_##argtype##_sz,NFS_##restype##_sz) << 2,	\
+	.p_arglen   =  NFS_##argtype##_sz,				\
+	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\
 	.p_statidx  =  NFSPROC_##proc,					\
 	.p_name     =  #proc,						\
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 0ace092..b51df8e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1102,16 +1102,13 @@ nfs3_xdr_setaclres(struct rpc_rqst *req,
 }
 #endif  /* CONFIG_NFS_V3_ACL */
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
 	.p_encode    = (kxdrproc_t) nfs3_xdr_##argtype,			\
 	.p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
-	.p_bufsiz    = MAX(NFS3_##argtype##_sz,NFS3_##restype##_sz) << 2,	\
+	.p_arglen    = NFS3_##argtype##_sz,				\
+	.p_replen    = NFS3_##restype##_sz,				\
 	.p_timer     = timer,						\
 	.p_statidx   = NFS3PROC_##proc,					\
 	.p_name      = #proc,						\
@@ -1153,7 +1150,8 @@ static struct rpc_procinfo	nfs3_acl_proc
 		.p_proc = ACLPROC3_GETACL,
 		.p_encode = (kxdrproc_t) nfs3_xdr_getaclargs,
 		.p_decode = (kxdrproc_t) nfs3_xdr_getaclres,
-		.p_bufsiz = MAX(ACL3_getaclargs_sz, ACL3_getaclres_sz) << 2,
+		.p_arglen = ACL3_getaclargs_sz,
+		.p_replen = ACL3_getaclres_sz,
 		.p_timer = 1,
 		.p_name = "GETACL",
 	},
@@ -1161,7 +1159,8 @@ static struct rpc_procinfo	nfs3_acl_proc
 		.p_proc = ACLPROC3_SETACL,
 		.p_encode = (kxdrproc_t) nfs3_xdr_setaclargs,
 		.p_decode = (kxdrproc_t) nfs3_xdr_setaclres,
-		.p_bufsiz = MAX(ACL3_setaclargs_sz, ACL3_setaclres_sz) << 2,
+		.p_arglen = ACL3_setaclargs_sz,
+		.p_replen = ACL3_setaclres_sz,
 		.p_timer = 0,
 		.p_name = "SETACL",
 	},
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0cf3fa3..198f1b5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4544,16 +4544,13 @@ nfs4_stat_to_errno(int stat)
 	return stat;
 }
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
 	.p_encode = (kxdrproc_t) nfs4_xdr_##argtype,		\
 	.p_decode = (kxdrproc_t) nfs4_xdr_##restype,		\
-	.p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,	\
+	.p_arglen = NFS4_##argtype##_sz,			\
+	.p_replen = NFS4_##restype##_sz,			\
 	.p_statidx = NFSPROC4_CLNT_##proc,			\
 	.p_name   = #proc,					\
     }
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index f57655a..69a721a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -315,16 +315,13 @@ out:
 /*
  * RPC procedure tables
  */
-#ifndef MAX
-# define MAX(a, b)      (((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, call, argtype, restype)                              \
 [NFSPROC4_CLNT_##proc] = {                                      	\
         .p_proc   = NFSPROC4_CB_##call,					\
         .p_encode = (kxdrproc_t) nfs4_xdr_##argtype,                    \
         .p_decode = (kxdrproc_t) nfs4_xdr_##restype,                    \
-        .p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,  \
+        .p_arglen = NFS4_##argtype##_sz,                                \
+        .p_replen = NFS4_##restype##_sz,                                \
         .p_statidx = NFSPROC4_CB_##call,				\
 	.p_name   = #proc,                                              \
 }
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a34737a..6661142 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -84,7 +84,8 @@ struct rpc_procinfo {
 	u32			p_proc;		/* RPC procedure number */
 	kxdrproc_t		p_encode;	/* XDR encode function */
 	kxdrproc_t		p_decode;	/* XDR decode function */
-	unsigned int		p_bufsiz;	/* req. buffer size */
+	unsigned int		p_arglen;	/* argument hdr length (u32) */
+	unsigned int		p_replen;	/* reply hdr length (u32) */
 	unsigned int		p_count;	/* call count */
 	unsigned int		p_timer;	/* Which RTT timer to use */
 	u32			p_statidx;	/* Which procedure to account */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 6c035cb..192b74d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -84,7 +84,8 @@ struct rpc_rqst {
 	struct list_head	rq_list;
 
 	__u32 *			rq_buffer;	/* XDR encode buffer */
-	size_t			rq_bufsize;
+	size_t			rq_callsize,
+				rq_rcvsize;
 
 	struct xdr_buf		rq_private_buf;		/* The receive buffer
 							 * used in the softirq.
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 606b397..e885ae5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -36,8 +36,6 @@ #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/metrics.h>
 
 
-#define RPC_SLACK_SPACE		(1024)	/* total overkill */
-
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_CALL
 #endif
@@ -753,25 +751,39 @@ call_reserveresult(struct rpc_task *task
 static void
 call_allocate(struct rpc_task *task)
 {
+	unsigned int slack = task->tk_auth->au_cslack;
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = task->tk_xprt;
-	unsigned int	bufsiz;
+	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
 
 	dprint_status(task);
 
+	task->tk_status = 0;
 	task->tk_action = call_bind;
+
 	if (req->rq_buffer)
 		return;
 
-	/* FIXME: compute buffer requirements more exactly using
-	 * auth->au_wslack */
-	bufsiz = task->tk_msg.rpc_proc->p_bufsiz + RPC_SLACK_SPACE;
+	if (proc->p_proc != 0) {
+		BUG_ON(proc->p_arglen == 0);
+		if (proc->p_decode != NULL)
+			BUG_ON(proc->p_replen == 0);
+	}
 
-	req->rq_buffer = xprt->ops->buf_alloc(task, bufsiz << 1);
-	if (req->rq_buffer != NULL) {
-		req->rq_bufsize = bufsiz;
+	/*
+	 * Calculate the size (in quads) of the RPC call
+	 * and reply headers, and convert both values
+	 * to byte sizes.
+	 */
+ 	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
+ 	req->rq_callsize <<= 2;
+ 	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
+ 	req->rq_rcvsize <<= 2;
+ 
+ 	req->rq_buffer = xprt->ops->buf_alloc(task,
+					req->rq_callsize + req->rq_rcvsize);
+	if (req->rq_buffer != NULL)
 		return;
-	}
 
 	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
 
@@ -797,6 +809,17 @@ rpc_task_force_reencode(struct rpc_task 
 	task->tk_rqstp->rq_snd_buf.len = 0;
 }
 
+static inline void
+rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
+{
+	buf->head[0].iov_base = start;
+	buf->head[0].iov_len = len;
+	buf->tail[0].iov_len = 0;
+	buf->page_len = 0;
+	buf->len = 0;
+	buf->buflen = len;
+}
+
 /*
  * 3.	Encode arguments of an RPC call
  */
@@ -804,28 +827,17 @@ static void
 call_encode(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
-	struct xdr_buf *sndbuf = &req->rq_snd_buf;
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	unsigned int	bufsiz;
 	kxdrproc_t	encode;
 	__be32		*p;
 
 	dprint_status(task);
 
-	/* Default buffer setup */
-	bufsiz = req->rq_bufsize >> 1;
-	sndbuf->head[0].iov_base = (void *)req->rq_buffer;
-	sndbuf->head[0].iov_len  = bufsiz;
-	sndbuf->tail[0].iov_len  = 0;
-	sndbuf->page_len	 = 0;
-	sndbuf->len		 = 0;
-	sndbuf->buflen		 = bufsiz;
-	rcvbuf->head[0].iov_base = (void *)((char *)req->rq_buffer + bufsiz);
-	rcvbuf->head[0].iov_len  = bufsiz;
-	rcvbuf->tail[0].iov_len  = 0;
-	rcvbuf->page_len	 = 0;
-	rcvbuf->len		 = 0;
-	rcvbuf->buflen		 = bufsiz;
+	rpc_xdr_buf_init(&req->rq_snd_buf,
+			 req->rq_buffer,
+			 req->rq_callsize);
+	rpc_xdr_buf_init(&req->rq_rcv_buf, 
+			 (char *)req->rq_buffer + req->rq_callsize,
+			 req->rq_rcvsize);
 
 	/* Encode header and provided arguments */
 	encode = task->tk_msg.rpc_proc->p_encode;
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 28e0a76..f920345 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -434,21 +434,24 @@ static struct rpc_procinfo rpcb_procedur
 		.p_proc		= RPCB_SET,
 		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
 		.p_decode	= (kxdrproc_t) xdr_decode_set,
-		.p_bufsiz	= 4,
+		.p_arglen	= 4,
+		.p_replen	= 1,
 		.p_count	= 1,
 	},
 	[RPCB_UNSET] = {
 		.p_proc		= RPCB_UNSET,
 		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
 		.p_decode	= (kxdrproc_t) xdr_decode_set,
-		.p_bufsiz	= 4,
+		.p_arglen	= 4,
+		.p_replen	= 1,
 		.p_count	= 1,
 	},
 	[RPCB_GETADDR] = {
 		.p_proc		= RPCB_GETPORT,
 		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
 		.p_decode	= (kxdrproc_t) xdr_decode_getport,
-		.p_bufsiz	= 4,
+		.p_arglen	= 4,
+		.p_replen	= 1,
 		.p_count	= 1,
 	},
 };
@@ -458,21 +461,24 @@ static struct rpc_procinfo rpcb_procedur
 		.p_proc		= RPCB_SET,
 		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
 		.p_decode	= (kxdrproc_t) xdr_decode_set,
-		.p_bufsiz	= 4,
+		.p_arglen	= 4,
+		.p_replen	= 1,
 		.p_count	= 1,
 	},
 	[RPCB_UNSET] = {
 		.p_proc		= RPCB_UNSET,
 		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
 		.p_decode	= (kxdrproc_t) xdr_decode_set,
-		.p_bufsiz	= 4,
+		.p_arglen	= 4,
+		.p_replen	= 1,
 		.p_count	= 1,
 	},
 	[RPCB_GETADDR] = {
 		.p_proc		= RPCB_GETADDR,
 		.p_encode	= (kxdrproc_t) xdr_encode_getaddr,
 		.p_decode	= (kxdrproc_t) xdr_decode_getaddr,
-		.p_bufsiz	= 36,
+		.p_arglen	= 36,
+		.p_replen	= 33,
 		.p_count	= 1,
 	},
 };
@@ -482,7 +488,8 @@ static struct rpc_procinfo rpcb_procedur
 		.p_proc		= RPCB_GETVERSADDR,
 		.p_encode	= (kxdrproc_t) xdr_encode_getaddr,
 		.p_decode	= (kxdrproc_t) xdr_decode_getaddr,
-		.p_bufsiz	= 36,
+		.p_arglen	= 36,
+		.p_replen	= 33,
 		.p_count	= 1,
 	},
 };
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 5261774..639d18d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -833,7 +833,6 @@ static void xprt_request_init(struct rpc
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
-	req->rq_bufsize = 0;
 	req->rq_xid     = xprt_alloc_xid(xprt);
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
@@ -865,7 +864,8 @@ void xprt_release(struct rpc_task *task)
 		mod_timer(&xprt->timer,
 				xprt->last_used + xprt->idle_timeout);
 	spin_unlock_bh(&xprt->transport_lock);
-	xprt->ops->buf_free(task, req->rq_buffer, req->rq_bufsize);
+	xprt->ops->buf_free(task, req->rq_buffer,
+			    req->rq_callsize + req->rq_rcvsize);
 	task->tk_rqstp = NULL;
 	if (req->rq_release_snd_buf)
 		req->rq_release_snd_buf(req);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
