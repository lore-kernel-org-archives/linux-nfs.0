Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46800 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758470Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/14] svcrpc: make xpo_recvfrom return only >=0
Date: Tue, 21 Aug 2012 16:57:27 -0400
Message-Id: <1345582652-18476-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The only errors returned from xpo_recvfrom have been -EAGAIN and
-EAFNOSUPPORT.  The latter looked incorrect to me, so was removed by a
previous patch.  That leaves only -EAGAIN, which is treated by the
caller (svc_recv) identically to 0.

So, just ditch -EAGAIN and return 0 instead.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |    2 +-
 net/sunrpc/svcsock.c  |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ee15663..3e31730 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -743,7 +743,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	svc_xprt_received(xprt);
 
 	/* No data, incomplete (TCP) read, or accept() */
-	if (len == 0 || len == -EAGAIN)
+	if (len <= 0)
 		goto out;
 
 	clear_bit(XPT_OLD, &xprt->xpt_flags);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 97ce23f..33008f2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -598,11 +598,11 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 			dprintk("svc: recvfrom returned error %d\n", -err);
 			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		}
-		return -EAGAIN;
+		return 0;
 	}
 	len = svc_addr_len(svc_addr(rqstp));
 	if (len == 0)
-		return -EAGAIN;
+		return 0;
 	rqstp->rq_addrlen = len;
 	if (skb->tstamp.tv64 == 0) {
 		skb->tstamp = ktime_get_real();
@@ -1176,13 +1176,13 @@ error:
 	if (len != -EAGAIN)
 		goto err_other;
 	dprintk("RPC: TCP recvfrom got EAGAIN\n");
-	return -EAGAIN;
+	return 0;
 err_other:
 	printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 	       svsk->sk_xprt.xpt_server->sv_name, -len);
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 err_noclose:
-	return -EAGAIN;	/* record not complete */
+	return 0;	/* record not complete */
 }
 
 /*
-- 
1.7.9.5

