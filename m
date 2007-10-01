From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 25/35] svc: Move the sockaddr information to svc_xprt
Date: Mon, 01 Oct 2007 14:28:25 -0500
Message-ID: <20071001192825.3250.57889.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQwL-0005dV-1N
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:25 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQwM-0007Rx-3S
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:30 -0700
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


Move the IP address fields to the svc_xprt structure. Note that this 
assumes that _all_ RPC transports must have IP based 4-tuples. This 
seems reasonable given the tight coupling with the portmapper etc...
Thoughts?

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    3 ++
 include/linux/sunrpc/svcsock.h  |    4 ---
 net/sunrpc/svcsock.c            |   50 +++++++++++++++++++++------------------
 3 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index ba92909..47ad941 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -62,6 +62,9 @@ #define XPT_CACHE_AUTH	12		/* cache auth
 	void			*xpt_auth_cache;/* auth cache */
 	struct list_head	xpt_deferred;	/* deferred requests that need
 						 * to be revisted */
+	struct sockaddr_storage	xpt_local;	/* local address */
+	struct sockaddr_storage	xpt_remote;	/* remote peer's address */
+	int			xpt_remotelen;	/* length of address */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 96a229e..206f092 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -28,10 +28,6 @@ struct svc_sock {
 	/* private TCP part */
 	int			sk_reclen;	/* length of record */
 	int			sk_tcplen;	/* current read length */
-
-	struct sockaddr_storage	sk_local;	/* local address */
-	struct sockaddr_storage	sk_remote;	/* remote peer's address */
-	int			sk_remotelen;	/* length of address */
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0732dc2..ab34bb2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -632,33 +632,13 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	struct msghdr msg = {
 		.msg_flags	= MSG_DONTWAIT,
 	};
-	struct sockaddr *sin;
 	int len;
 
 	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
 				msg.msg_flags);
 
-	/* sock_recvmsg doesn't fill in the name/namelen, so we must..
-	 */
-	memcpy(&rqstp->rq_addr, &svsk->sk_remote, svsk->sk_remotelen);
-	rqstp->rq_addrlen = svsk->sk_remotelen;
-
-	/* Destination address in request is needed for binding the
-	 * source address in RPC callbacks later.
-	 */
-	sin = (struct sockaddr *)&svsk->sk_local;
-	switch (sin->sa_family) {
-	case AF_INET:
-		rqstp->rq_daddr.addr = ((struct sockaddr_in *)sin)->sin_addr;
-		break;
-	case AF_INET6:
-		rqstp->rq_daddr.addr6 = ((struct sockaddr_in6 *)sin)->sin6_addr;
-		break;
-	}
-
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
 		svsk, iov[0].iov_base, iov[0].iov_len, len);
-
 	return len;
 }
 
@@ -1113,14 +1093,14 @@ svc_tcp_accept(struct svc_xprt *xprt)
 	if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
 				 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
 		goto failed;
-	memcpy(&newsvsk->sk_remote, sin, slen);
-	newsvsk->sk_remotelen = slen;
+	memcpy(&newsvsk->sk_xprt.xpt_remote, sin, slen);
+	newsvsk->sk_xprt.xpt_remotelen = slen;
 	err = kernel_getsockname(newsock, sin, &slen);
 	if (unlikely(err < 0)) {
 		dprintk("svc_tcp_accept: kernel_getsockname error %d\n", -err);
 		slen = offsetof(struct sockaddr, sa_data);
 	}
-	memcpy(&newsvsk->sk_local, sin, slen);
+	memcpy(&newsvsk->sk_xprt.xpt_local, sin, slen);
 
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
@@ -1496,6 +1476,29 @@ svc_check_conn_limits(struct svc_serv *s
 	}
 }
 
+static inline void svc_copy_addr(struct svc_rqst *rqstp, struct svc_xprt *xprt)
+{
+	struct sockaddr *sin;
+
+	/* sock_recvmsg doesn't fill in the name/namelen, so we must..
+	 */
+	memcpy(&rqstp->rq_addr, &xprt->xpt_remote, xprt->xpt_remotelen);
+	rqstp->rq_addrlen = xprt->xpt_remotelen;
+
+	/* Destination address in request is needed for binding the
+	 * source address in RPC callbacks later.
+	 */
+	sin = (struct sockaddr *)&xprt->xpt_local;
+	switch (sin->sa_family) {
+	case AF_INET:
+		rqstp->rq_daddr.addr = ((struct sockaddr_in *)sin)->sin_addr;
+		break;
+	case AF_INET6:
+		rqstp->rq_daddr.addr6 = ((struct sockaddr_in6 *)sin)->sin6_addr;
+		break;
+	}
+}
+
 /*
  * Receive the next request on any socket.  This code is carefully
  * organised not to touch any cachelines in the shared svc_serv
@@ -1614,6 +1617,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 			len = svc_deferred_recv(rqstp);
 		} else
 			len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
+		svc_copy_addr(rqstp, &svsk->sk_xprt);
 		dprintk("svc: got len=%d\n", len);
 	}
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
