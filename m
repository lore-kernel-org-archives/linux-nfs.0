Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44F45C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:35:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 209B921917
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:35:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733014AbeLURfn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 12:35:43 -0500
Received: from relay.sw.ru ([185.231.240.75]:40906 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730364AbeLURfn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 12:35:43 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gaOi4-0004vU-CY; Fri, 21 Dec 2018 20:35:40 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 4/8] sunrpc: use-after-free in svc_process_common()
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545412216.git.vvs@virtuozzo.com>
Message-ID: <e46e97ef-2823-ff1c-7a87-e0e6a3cf46c2@virtuozzo.com>
Date:   Fri, 21 Dec 2018 20:35:39 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545412216.git.vvs@virtuozzo.com>
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

According to Trond, the whole "let's set up rqstp->rq_xprt
for the back channel" is nothing but a giant hack in order
to work around the fact that svc_process_common() uses it
to find the xpt_ops, and perform a couple of (meaningless
for the back channel) tests of xpt_flags.

All we really need in svc_process_common() is to be able to run
rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr()

Bruce J Fields points that this xpo_prep_reply_hdr() call
is an awfully roundabout way just to do "svc_putnl(resv, 0);"
in the tcp case.

This patch removes rqstp->rq_xprt set up in bc_svc_process(),
now it calls svc_process_common() with rqstp->rq_xprt = NULL.

Patch adjust SVC_NET() definition and adopt function called
from svc_process_common() to proprly handle this situation.

To adjust reply header patch calls bc_reply_hdr() function pointer
saved on per-netns sunrpc_net structure.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 include/linux/sunrpc/svc.h    |  2 +-
 include/trace/events/sunrpc.h |  6 ++++--
 net/sunrpc/svc.c              | 17 ++++++++++++-----
 net/sunrpc/svc_xprt.c         |  5 +++--
 4 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 23e33f8f0507..670596f4fdf7 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -300,7 +300,7 @@ struct svc_rqst {
 						 */
 };
 
-#define SVC_NET(svc_rqst)	(svc_rqst->rq_xprt->xpt_net)
+#define SVC_NET(rqst) (rqst->rq_xprt ? rqst->rq_xprt->xpt_net : rqst->rq_bc_net)
 /*
  * Rigorous type checking on sockaddr type conversions
  */
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
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 94a2a85c078b..4cf0f0776179 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -30,6 +30,8 @@
 
 #include <trace/events/sunrpc.h>
 
+#include "netns.h"
+
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
 static void svc_unregister(const struct svc_serv *serv, struct net *net);
@@ -1153,6 +1155,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	struct svc_program	*progp;
 	const struct svc_version *versp = NULL;	/* compiler food */
 	const struct svc_procedure *procp = NULL;
+	struct sunrpc_net 	*sn;
 	struct svc_serv		*serv = rqstp->rq_server;
 	__be32			*statp;
 	u32			prog, vers, proc;
@@ -1172,8 +1175,13 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	clear_bit(RQ_DROPME, &rqstp->rq_flags);
 
 	/* Setup reply header */
-	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
-
+	if (rqstp->rq_xprt)
+		rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
+	else {
+		sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
+		if (sn->bc_prep_reply_hdr)
+			sn->bc_prep_reply_hdr(rqstp);
+	}
 	svc_putu32(resv, rqstp->rq_xid);
 
 	vers = svc_getnl(argv);
@@ -1244,7 +1252,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	 * for lower versions. RPC_PROG_MISMATCH seems to be the closest
 	 * fit.
 	 */
-	if (versp->vs_need_cong_ctrl &&
+	if (versp->vs_need_cong_ctrl && rqstp->rq_xprt &&
 	    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
 		goto err_bad_vers;
 
@@ -1336,7 +1344,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	return 0;
 
  close:
-	if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
+	if (rqstp->rq_xprt && test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
 		svc_close_xprt(rqstp->rq_xprt);
 	dprintk("svc: svc_process close\n");
 	return 0;
@@ -1459,7 +1467,6 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	dprintk("svc: %s(%p)\n", __func__, req);
 
 	/* Build the svc_rqst used by the common processing routine */
-	rqstp->rq_xprt = serv->sv_bc_xprt;
 	rqstp->rq_xid = req->rq_xid;
 	rqstp->rq_prot = req->rq_xprt->prot;
 	rqstp->rq_server = serv;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 2ffeecfa0978..728ccd4d4490 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -473,10 +473,11 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
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
 
-- 
2.17.1

