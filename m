Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11BC7C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 13:56:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C8A4621852
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 13:56:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732388AbeLTN4l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 08:56:41 -0500
Received: from relay.sw.ru ([185.231.240.75]:44440 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728803AbeLTN4l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 08:56:41 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gZyoV-0004xU-DR; Thu, 20 Dec 2018 16:56:35 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v2 1/4] nfs: use-after-free in svc_process_common()
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545313300.git.vvs@virtuozzo.com>
Message-ID: <7e45280e-7adc-05b4-9660-071f61e1977d@virtuozzo.com>
Date:   Thu, 20 Dec 2018 16:56:35 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545313300.git.vvs@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

if node have NFSv41+ mounts inside several net namespaces
it can lead to use-after-free in svc_process_common()

svc_process_common()
        /* Setup reply header */
        rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp); <<< HERE

svc_process_common() can use already freed rqstp->rq_xprt,
it was assigned in bc_svc_process() where it was taken from serv->sv_bc_xprt.
serv is global structure but sv_bc_xprt is assigned per-netnamespace.

To find correct svc_xprt of client-related backchannel
bc_svc_process() now calls new .bc_get_xprt callback
that executes svc_find_xprt() with proper xprt name.

According to Trond, the whole "let's set up rqstp->rq_xprt
for the back channel" is nothing but a giant hack in order
to work around the fact that svc_process_common() uses it
to find the xpt_ops, and perform a couple of (meaningless
for the back channel) tests of xpt_flags.

Trond proposed to pass in the xpt_ops as a new parameter to
svc_process_common(), and make those xpt_flags tests check
for whether or not rqstp->rq_xprt is actually non-NULL.

It also required to store a pointer to struct net in the
struct svc_rqst so that functions called from inside
svc_process_common() (nfs4_callback_compound(),
svcauth_gss_accept() and some other) can find it.
Some other functions was adopted to handle empty rqstp->rq_xprt

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 include/linux/sunrpc/svc.h        |  5 ++++-
 include/linux/sunrpc/xprt.h       |  1 +
 include/trace/events/sunrpc.h     |  6 ++++--
 net/sunrpc/auth_gss/svcauth_gss.c |  8 +++----
 net/sunrpc/svc.c                  | 36 ++++++++++++++++++++-----------
 net/sunrpc/svc_xprt.c             |  5 +++--
 net/sunrpc/xprtrdma/backchannel.c |  5 +++++
 net/sunrpc/xprtrdma/transport.c   |  1 +
 net/sunrpc/xprtrdma/xprt_rdma.h   |  1 +
 net/sunrpc/xprtsock.c             |  7 ++++++
 10 files changed, 54 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 73e130a840ce..f87d2ba88869 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -295,9 +295,12 @@ struct svc_rqst {
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	struct task_struct	*rq_task;	/* service thread */
 	spinlock_t		rq_lock;	/* per-request lock */
+	struct net *		rq_bc_net;	/* pointer to backchannel's
+						 * net namespace
+						 */
 };
 
-#define SVC_NET(svc_rqst)	(svc_rqst->rq_xprt->xpt_net)
+#define SVC_NET(rqst) (rqst->rq_xprt ? rqst->rq_xprt->xpt_net : rqst->rq_bc_net)
 
 /*
  * Rigorous type checking on sockaddr type conversions
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a4ab4f8d9140..031d2843a002 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -158,6 +158,7 @@ struct rpc_xprt_ops {
 	int		(*bc_setup)(struct rpc_xprt *xprt,
 				    unsigned int min_reqs);
 	int		(*bc_up)(struct svc_serv *serv, struct net *net);
+	struct svc_xprt*(*bc_get_xprt)(struct svc_serv *serv, struct net *net);
 	size_t		(*bc_maxpayload)(struct rpc_xprt *xprt);
 	void		(*bc_free_rqst)(struct rpc_rqst *rqst);
 	void		(*bc_destroy)(struct rpc_xprt *xprt,
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 28e384186c35..8617f4fd6b70 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -569,7 +569,8 @@ TRACE_EVENT(svc_process,
 		__field(u32, vers)
 		__field(u32, proc)
 		__string(service, name)
-		__string(addr, rqst->rq_xprt->xpt_remotebuf)
+		__string(addr, rqst->rq_xprt ?
+			 rqst->rq_xprt->xpt_remotebuf : "(null)")
 	),
 
 	TP_fast_assign(
@@ -577,7 +578,8 @@ TRACE_EVENT(svc_process,
 		__entry->vers = rqst->rq_vers;
 		__entry->proc = rqst->rq_proc;
 		__assign_str(service, name);
-		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
+		__assign_str(addr, rqst->rq_xprt ?
+			     rqst->rq_xprt->xpt_remotebuf : "(null)");
 	),
 
 	TP_printk("addr=%s xid=0x%08x service=%s vers=%u proc=%u",
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1ece4bc3eb8d..152790ed309c 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1142,7 +1142,7 @@ static int svcauth_gss_legacy_init(struct svc_rqst *rqstp,
 	struct kvec *resv = &rqstp->rq_res.head[0];
 	struct rsi *rsip, rsikey;
 	int ret;
-	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
 
 	memset(&rsikey, 0, sizeof(rsikey));
 	ret = gss_read_verf(gc, argv, authp,
@@ -1253,7 +1253,7 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 	uint64_t handle;
 	int status;
 	int ret;
-	struct net *net = rqstp->rq_xprt->xpt_net;
+	struct net *net = SVC_NET(rqstp);
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	memset(&ud, 0, sizeof(ud));
@@ -1444,7 +1444,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	__be32		*rpcstart;
 	__be32		*reject_stat = resv->iov_base + resv->iov_len;
 	int		ret;
-	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
 
 	dprintk("RPC:       svcauth_gss: argv->iov_len = %zd\n",
 			argv->iov_len);
@@ -1734,7 +1734,7 @@ svcauth_gss_release(struct svc_rqst *rqstp)
 	struct rpc_gss_wire_cred *gc = &gsd->clcred;
 	struct xdr_buf *resbuf = &rqstp->rq_res;
 	int stat = -EINVAL;
-	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
 
 	if (gc->gc_proc != RPC_GSS_PROC_DATA)
 		goto out;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d13e05f1a990..a398a2e2e6ed 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1148,7 +1148,8 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
  * Common routine for processing the RPC request.
  */
 static int
-svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
+svc_process_common(struct svc_rqst *rqstp, struct kvec *argv,
+		   struct kvec *resv, const struct svc_xprt_ops *xops)
 {
 	struct svc_program	*progp;
 	const struct svc_version *versp = NULL;	/* compiler food */
@@ -1172,7 +1173,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	clear_bit(RQ_DROPME, &rqstp->rq_flags);
 
 	/* Setup reply header */
-	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
+	xops->xpo_prep_reply_hdr(rqstp);
 
 	svc_putu32(resv, rqstp->rq_xid);
 
@@ -1244,7 +1245,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	 * for lower versions. RPC_PROG_MISMATCH seems to be the closest
 	 * fit.
 	 */
-	if (versp->vs_need_cong_ctrl &&
+	if (versp->vs_need_cong_ctrl && rqstp->rq_xprt &&
 	    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
 		goto err_bad_vers;
 
@@ -1336,7 +1337,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	return 0;
 
  close:
-	if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
+	if (rqstp->rq_xprt && test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
 		svc_close_xprt(rqstp->rq_xprt);
 	dprintk("svc: svc_process close\n");
 	return 0;
@@ -1432,7 +1433,8 @@ svc_process(struct svc_rqst *rqstp)
 	}
 
 	/* Returns 1 for send, 0 for drop */
-	if (likely(svc_process_common(rqstp, argv, resv)))
+	if (likely(svc_process_common(rqstp, argv, resv,
+					rqstp->rq_xprt->xpt_ops)))
 		return svc_send(rqstp);
 
 out_drop:
@@ -1450,19 +1452,25 @@ int
 bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	       struct svc_rqst *rqstp)
 {
+	struct net	*net = req->rq_xprt->xprt_net;
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct rpc_task *task;
+	struct svc_xprt *s_xprt;
 	int proc_error;
 	int error;
 
 	dprintk("svc: %s(%p)\n", __func__, req);
 
+	s_xprt = req->rq_xprt->ops->bc_get_xprt(serv, net);
+	if (!s_xprt)
+		goto proc_error;
+
 	/* Build the svc_rqst used by the common processing routine */
-	rqstp->rq_xprt = serv->sv_bc_xprt;
 	rqstp->rq_xid = req->rq_xid;
 	rqstp->rq_prot = req->rq_xprt->prot;
 	rqstp->rq_server = serv;
+	rqstp->rq_bc_net = net;
 
 	rqstp->rq_addrlen = sizeof(req->rq_xprt->addr);
 	memcpy(&rqstp->rq_addr, &req->rq_xprt->addr, rqstp->rq_addrlen);
@@ -1493,14 +1501,12 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	svc_getnl(argv);	/* CALLDIR */
 
 	/* Parse and execute the bc call */
-	proc_error = svc_process_common(rqstp, argv, resv);
+	proc_error = svc_process_common(rqstp, argv, resv, s_xprt->xpt_ops);
+	svc_xprt_put(s_xprt);
 
 	atomic_inc(&req->rq_xprt->bc_free_slots);
-	if (!proc_error) {
-		/* Processing error: drop the request */
-		xprt_free_bc_request(req);
-		return 0;
-	}
+	if (!proc_error)
+		goto proc_error;
 
 	/* Finally, send the reply synchronously */
 	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
@@ -1517,6 +1523,12 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 out:
 	dprintk("svc: %s(), error=%d\n", __func__, error);
 	return error;
+
+proc_error:
+	/* Processing error: drop the request */
+	xprt_free_bc_request(req);
+	error = -EINVAL;
+	goto out;
 }
 EXPORT_SYMBOL_GPL(bc_svc_process);
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 51d36230b6e3..51da7c244bee 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -468,10 +468,11 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
  */
 void svc_reserve(struct svc_rqst *rqstp, int space)
 {
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+
 	space += rqstp->rq_res.head[0].iov_len;
 
-	if (space < rqstp->rq_reserved) {
-		struct svc_xprt *xprt = rqstp->rq_xprt;
+	if (xprt && (space < rqstp->rq_reserved)) {
 		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
 		rqstp->rq_reserved = space;
 
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e5b367a3e517..3e06aeacda43 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -133,6 +133,11 @@ int xprt_rdma_bc_up(struct svc_serv *serv, struct net *net)
 	return 0;
 }
 
+struct svc_xprt *xprt_rdma_bc_get_xprt(struct svc_serv *serv, struct net *net)
+{
+	return svc_find_xprt(serv, "rdma-bc", net, AF_UNSPEC, 0);
+}
+
 /**
  * xprt_rdma_bc_maxpayload - Return maximum backchannel message size
  * @xprt: transport
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ae2a83828953..41d67de93531 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -828,6 +828,7 @@ static const struct rpc_xprt_ops xprt_rdma_procs = {
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	.bc_setup		= xprt_rdma_bc_setup,
 	.bc_up			= xprt_rdma_bc_up,
+	.bc_get_xprt		= xprt_rdma_bc_get_xprt,
 	.bc_maxpayload		= xprt_rdma_bc_maxpayload,
 	.bc_free_rqst		= xprt_rdma_bc_free_rqst,
 	.bc_destroy		= xprt_rdma_bc_destroy,
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a13ccb643ce0..2726d71052a8 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -662,6 +662,7 @@ void xprt_rdma_cleanup(void);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
 int xprt_rdma_bc_up(struct svc_serv *, struct net *);
+struct svc_xprt *xprt_rdma_bc_get_xprt(struct svc_serv *serv, struct net *net);
 size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *);
 int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
 void rpcrdma_bc_receive_call(struct rpcrdma_xprt *, struct rpcrdma_rep *);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8a5e823e0b33..16f9c7720465 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1411,6 +1411,12 @@ static int xs_tcp_bc_up(struct svc_serv *serv, struct net *net)
 	return 0;
 }
 
+static struct svc_xprt *xs_tcp_bc_get_xprt(struct svc_serv *serv,
+					   struct net *net)
+{
+	return svc_find_xprt(serv, "tcp-bc", net, AF_UNSPEC, 0);
+}
+
 static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
 {
 	return PAGE_SIZE;
@@ -2668,6 +2674,7 @@ static const struct rpc_xprt_ops xs_tcp_ops = {
 #ifdef CONFIG_SUNRPC_BACKCHANNEL
 	.bc_setup		= xprt_setup_bc,
 	.bc_up			= xs_tcp_bc_up,
+	.bc_get_xprt		= xs_tcp_bc_get_xprt,
 	.bc_maxpayload		= xs_tcp_bc_maxpayload,
 	.bc_free_rqst		= xprt_free_bc_rqst,
 	.bc_destroy		= xprt_destroy_bc,
-- 
2.17.1

