From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 23/38] svc: Remove sk_lastrecv
Date: Tue, 11 Dec 2007 17:32:45 -0600
Message-ID: <20071211233245.15718.67879.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35428 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754897AbXLKXcp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:32:45 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


With the implementation of the new mark and sweep algorithm for shutting
down old connections, the sk_lastrecv field is no longer needed.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    1 -
 net/sunrpc/svcsock.c           |    5 +----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 41c2dfa..406d003 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -33,7 +33,6 @@ struct svc_sock {
 	/* private TCP part */
 	int			sk_reclen;	/* length of record */
 	int			sk_tcplen;	/* current read length */
-	time_t			sk_lastrecv;	/* time of last received request */
 
 	/* cache of various info for TCP sockets */
 	void			*sk_info_authunix;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c637acf..a7af4cf 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1608,7 +1608,6 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 		svc_sock_release(rqstp);
 		return -EAGAIN;
 	}
-	svsk->sk_lastrecv = get_seconds();
 	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
@@ -1708,8 +1707,7 @@ svc_age_temp_sockets(unsigned long closure)
 		list_del_init(le);
 		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 
-		dprintk("queuing svsk %p for closing, %lu seconds old\n",
-			svsk, get_seconds() - svsk->sk_lastrecv);
+		dprintk("queuing svsk %p for closing\n", svsk);
 
 		/* a thread will dequeue and close it soon */
 		svc_xprt_enqueue(&svsk->sk_xprt);
@@ -1757,7 +1755,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 
