From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 24/40] svc: Move accept call to svc_xprt_received to common code
Date: Sun, 30 Dec 2007 21:08:03 -0600
Message-ID: <20071231030803.8430.49604.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41550 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752775AbXLaDIE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:08:04 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Now that the svc_xprt_received function handles transports, the call
to svc_xprt_received in the xpo_tcp_accept function can be moved to
common code.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 201217f..1d48784 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1106,8 +1106,6 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 	memcpy(&newsvsk->sk_local, sin, slen);
 
-	svc_xprt_received(&newsvsk->sk_xprt);
-
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
@@ -1591,6 +1589,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
 			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
+			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(&svsk->sk_xprt);
 	} else {
