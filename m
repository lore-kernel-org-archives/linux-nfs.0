From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] svc: Move kfree of deferral record to common code
Date: Mon, 05 Jan 2009 11:12:52 -0600
Message-ID: <49623F94.6000202@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:33495 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751449AbZAERMx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2009 12:12:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The rqstp structure has a pointer to a svc_deferred_req record
that is allocated when requests are deferred. This record is common
to all transports and can be freed in common code.

Move the kfree of the rq_deferred to the common svc_xprt_release
function.

This also fixes a memory leak in the RDMA transport which does not
kfree the dr structure in it's version of the xpo_release_rqst callback.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
  net/sunrpc/svc_xprt.c |    3 +++
  net/sunrpc/svcsock.c  |    5 -----
  2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 375a695..de16a97 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -448,6 +448,9 @@ static void svc_xprt_release(struct svc_rqst *rqstp)

         rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);

+       kfree(rqstp->rq_deferred);
+       rqstp->rq_deferred = NULL;
+
         svc_free_res_pages(rqstp);
         rqstp->rq_res.page_len = 0;
         rqstp->rq_res.page_base = 0;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ef3238d..e59a88e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -102,7 +102,6 @@ static void svc_reclassify_socket(struct socket *sock)
  static void svc_release_skb(struct svc_rqst *rqstp)
  {
         struct sk_buff *skb = rqstp->rq_xprt_ctxt;
-       struct svc_deferred_req *dr = rqstp->rq_deferred;

         if (skb) {
                 struct svc_sock *svsk =
@@ -112,10 +111,6 @@ static void svc_release_skb(struct svc_rqst *rqstp)
                 dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
                 skb_free_datagram(svsk->sk_sk, skb);
         }
-       if (dr) {
-               rqstp->rq_deferred = NULL;
-               kfree(dr);
-       }
  }

  union svc_pktinfo_u {
