From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 05/20] svc: xpt_max_payload
Date: Mon, 20 Aug 2007 11:23:32 -0500
Message-ID: <20070820162332.15224.4469.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2P-0006Nc-Uq
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:34 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2T-0005KY-U2
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:38 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 2C37C7C0CC
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:32 -0500 (CDT)
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Store the max payload supported by the transport in the switch
instead of reaching into the socket since not all transports 
(RDMA) have a socket.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    6 ++++++
 net/sunrpc/svc.c               |    5 ++---
 net/sunrpc/svcsock.c           |    2 ++
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 3faa95c..4e24e6d 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -35,6 +35,12 @@ struct svc_xprt {
 	 * Return 1 if sufficient space to write reply to network.
 	 */
 	int			(*xpt_has_wspace)(struct svc_sock *);
+	/*
+	 * Stores the largest payload (i.e. READ, WRITE or READDIR
+	 * data length not including NFS headers) supported by the
+	 * svc_sock.
+	 */
+	u32			xpt_max_payload;
 };
 
 /*
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 72a900f..41f9ee0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1036,10 +1036,9 @@ err_bad:
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
 {
-	int max = RPCSVC_MAXPAYLOAD_TCP;
+	struct svc_sock *svsk = rqstp->rq_sock;
+	int max = svsk->sk_xprt->xpt_max_payload;
 
-	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
-		max = RPCSVC_MAXPAYLOAD_UDP;
 	if (rqstp->rq_server->sv_max_payload < max)
 		max = rqstp->rq_server->sv_max_payload;
 	return max;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b16dad4..0dc94a8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -897,6 +897,7 @@ static const struct svc_xprt svc_udp_xpr
 	.xpt_detach = svc_sock_detach,
 	.xpt_free = svc_sock_free,
 	.xpt_has_wspace = svc_udp_has_wspace,
+	.xpt_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 };
 
 static void
@@ -1368,6 +1369,7 @@ static const struct svc_xprt svc_tcp_xpr
 	.xpt_free = svc_sock_free,
 	.xpt_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.xpt_has_wspace = svc_tcp_has_wspace,
+	.xpt_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
 static void

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
