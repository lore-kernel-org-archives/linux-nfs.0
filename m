Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35226 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933710AbcK2QEg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 11:04:36 -0500
Subject: [PATCH v3 02/10] svcauth_gss: Close connection when dropping an
 incoming message
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 11:04:34 -0500
Message-ID: <20161129160434.4477.76542.stgit@klimt.1015granger.net>
In-Reply-To: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
References: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

S5.3.3.1 of RFC 2203 requires that an incoming GSS-wrapped message
whose sequence number lies outside the current window is dropped.
The rationale is:

  The reason for discarding requests silently is that the server
  is unable to determine if the duplicate or out of range request
  was due to a sequencing problem in the client, network, or the
  operating system, or due to some quirk in routing, or a replay
  attack by an intruder.  Discarding the request allows the client
  to recover after timing out, if indeed the duplication was
  unintentional or well intended.

However, clients may rely on the server dropping the connection to
indicate that a retransmit is needed. Without a connection reset, a
client can wait forever without retransmitting, and the workload
just stops dead. I've reproduced this behavior by running xfstests
generic/323 on an NFSv4.0 mount with proto=rdma and sec=krb5i.

To address this issue, have the server close the connection when it
silently discards an incoming message due to a GSS sequence number
problem.

There are a few other places where the server will never reply.
Change those spots in a similar fashion.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c |    2 +-
 net/sunrpc/svc.c                  |   14 +++++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 45662d7..886e9d38 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1548,7 +1548,7 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
 	ret = SVC_COMPLETE;
 	goto out;
 drop:
-	ret = SVC_DROP;
+	ret = SVC_CLOSE;
 out:
 	if (rsci)
 		cache_put(&rsci->h, sn->rsc_cache);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 7c8070e..75f290b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1155,8 +1155,7 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
 	case SVC_DENIED:
 		goto err_bad_auth;
 	case SVC_CLOSE:
-		if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
-			svc_close_xprt(rqstp->rq_xprt);
+		goto close;
 	case SVC_DROP:
 		goto dropit;
 	case SVC_COMPLETE:
@@ -1246,7 +1245,7 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
 
  sendit:
 	if (svc_authorise(rqstp))
-		goto dropit;
+		goto close;
 	return 1;		/* Caller can now send it */
 
  dropit:
@@ -1254,11 +1253,16 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
 	dprintk("svc: svc_process dropit\n");
 	return 0;
 
+ close:
+	if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
+		svc_close_xprt(rqstp->rq_xprt);
+	dprintk("svc: svc_process close\n");
+	return 0;
+
 err_short_len:
 	svc_printk(rqstp, "short len %Zd, dropping request\n",
 			argv->iov_len);
-
-	goto dropit;			/* drop request */
+	goto close;
 
 err_bad_rpc:
 	serv->sv_stats->rpcbadfmt++;

