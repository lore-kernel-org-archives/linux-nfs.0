From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 22/35] svc: Remove sk_lastrecv
Date: Mon, 01 Oct 2007 14:28:19 -0500
Message-ID: <20071001192819.3250.31184.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQwK-0005dP-3w
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:24 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQwK-0007So-KY
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:29 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
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
index b8d0d55..b1c843e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1627,7 +1627,6 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		svc_sock_release(rqstp);
 		return -EAGAIN;
 	}
-	svsk->sk_lastrecv = get_seconds();
 	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
@@ -1729,8 +1728,7 @@ svc_age_temp_sockets(unsigned long closu
 		list_del_init(le);
 		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 
-		dprintk("queuing svsk %p for closing, %lu seconds old\n",
-			svsk, get_seconds() - svsk->sk_lastrecv);
+		dprintk("queuing svsk %p for closing\n", svsk);
 
 		/* a thread will dequeue and close it soon */
 		svc_xprt_enqueue(&svsk->sk_xprt);
@@ -1778,7 +1776,6 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
