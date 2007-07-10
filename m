From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 05/20] svc: svc_max_payload
Date: Tue, 10 Jul 2007 00:34:30 -0500
Message-ID: <20070710053430.28979.69319.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mr-00074P-CB
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:33 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mu-0004rn-59
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:37 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id C3F9F7C79C
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:30 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Store the svc_max_payload delegate in svc_sock_ops
instead of reaching into the socket (beause later the NFS/RDMA
transport will not even have a socket).

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    6 ++++++
 net/sunrpc/svc.c               |    5 ++---
 net/sunrpc/svcsock.c           |    6 ++++--
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index e4f2936..ce93b10 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -35,6 +35,12 @@ struct svc_sock_ops {
 	 * Return 1 if sufficient space to write reply to network.
 	 */
 	int			(*sko_has_wspace)(struct svc_sock *);
+	/*
+	 * Stores the largest payload (i.e. READ, WRITE or READDIR
+	 * data length not including NFS headers) supported by the
+	 * svc_sock.
+	 */
+	u32			sko_max_payload;
 };
 
 /*
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f852587..eea0439 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1036,10 +1036,9 @@ err_bad:
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
 {
-	int max = RPCSVC_MAXPAYLOAD_TCP;
+	struct svc_sock *svsk = rqstp->rq_sock;
+	int max = svsk->sk_ops->sko_max_payload;
 
-	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
-		max = RPCSVC_MAXPAYLOAD_UDP;
 	if (rqstp->rq_server->sv_max_payload < max)
 		max = rqstp->rq_server->sv_max_payload;
 	return max;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a959824..1a6a933 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -896,7 +896,8 @@ static const struct svc_sock_ops svc_udp
 	.sko_sendto = svc_udp_sendto,
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
-	.sko_has_wspace = svc_udp_has_wspace
+	.sko_has_wspace = svc_udp_has_wspace,
+	.sko_max_payload = RPCSVC_MAXPAYLOAD_UDP
 };
 
 static void
@@ -1367,7 +1368,8 @@ static const struct svc_sock_ops svc_tcp
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
 	.sko_prep_reply_hdr = svc_tcp_prep_reply_hdr,
-	.sko_has_wspace = svc_tcp_has_wspace
+	.sko_has_wspace = svc_tcp_has_wspace,
+	.sko_max_payload = RPCSVC_MAXPAYLOAD_TCP
 };
 
 static void

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
