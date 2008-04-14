From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/24] SUNRPC: Address potential buffer length overflow in
	svc_tcp_sendto
Date: Mon, 14 Apr 2008 12:27:16 -0400
Message-ID: <20080414162716.12741.50383.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:49307 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762378AbYDNQ1m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:27:42 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paranoia: Ensure a negative error value returned from svc_sendto()
doesn't match a large buffer length.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a8ae279..d077071 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -956,18 +956,18 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 		return -ENOTCONN;
 
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
-	if (sent != xbufp->len) {
-		printk(KERN_NOTICE
-		       "rpc-srv/tcp: %s: %s %d when sending %d bytes "
-		       "- shutting down socket\n",
-		       rqstp->rq_xprt->xpt_server->sv_name,
-		       (sent<0)?"got error":"sent only",
-		       sent, xbufp->len);
-		set_bit(XPT_CLOSE, &rqstp->rq_xprt->xpt_flags);
-		svc_xprt_enqueue(rqstp->rq_xprt);
-		sent = -EAGAIN;
-	}
-	return sent;
+	if (sent > 0 && sent == xbufp->len)
+		return sent;
+
+	printk(KERN_NOTICE "%s: %s %d when sending %u bytes "
+		"- shutting down TCP socket\n",
+			rqstp->rq_xprt->xpt_server->sv_name,
+			(sent < 0) ? "got error" : "sent only",
+			sent, xbufp->len);
+
+	set_bit(XPT_CLOSE, &rqstp->rq_xprt->xpt_flags);
+	svc_xprt_enqueue(rqstp->rq_xprt);
+	return -EAGAIN;
 }
 
 /*

