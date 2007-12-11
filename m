From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 22/38] svc: Move accept call to svc_xprt_received to common code
Date: Tue, 11 Dec 2007 17:32:43 -0600
Message-ID: <20071211233243.15718.29996.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35425 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754790AbXLKXcn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:32:43 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
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
index d8d88c1..c637acf 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1103,8 +1103,6 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 	memcpy(&newsvsk->sk_local, sin, slen);
 
-	svc_xprt_received(&newsvsk->sk_xprt);
-
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
@@ -1593,6 +1591,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
 			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
+			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(&svsk->sk_xprt);
 	} else {
