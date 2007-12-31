From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 28/40] svc: Move the sockaddr information to svc_xprt
Date: Sun, 30 Dec 2007 21:08:12 -0600
Message-ID: <20071231030812.8430.66919.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41566 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752931AbXLaDIM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:08:12 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch moves the transport sockaddr to the svc_xprt
structure.  Convenience functions are added to set and
get the local and remote addresses of a transport from
the transport provider as well as determine the length
of a sockaddr.

A transport is responsible for setting the xpt_local
and xpt_remote addresses in the svc_xprt structure as
part of transport creation and xpo_accept processing. This
cannot be done in a generic way and in fact varies
between TCP, UDP and RDMA. A set of xpo_ functions
(e.g. getlocalname, getremotename) could have been
added but this would have resulted in additional
caching and copying of the addresses around.  Note that
the xpt_local address should also be set on listening
endpoints; for TCP/RDMA this is done as part of
endpoint creation.

For connected transports like TCP and RDMA, the addresses
never change and can be set once and copied into the
rqstp structure for each request. For UDP, however, the
local and remote addresses may change for each request. In
this case, the address information is obtained from the
UDP recvmsg info and copied into the rqstp structure from
there. 

A svc_xprt_local_port function was also added that returns
the local port given a transport. This is used by
svc_create_xprt when returning the port associated with
a newly created transport, and later when creating a
generic find transport service to check if a service is
already listening on a given port.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |   51 ++++++++++++++++++++++++++++++++++++
 include/linux/sunrpc/svcsock.h  |    4 ---
 net/sunrpc/svc_xprt.c           |   31 ++++++++++++++++++++--
 net/sunrpc/svcsock.c            |   56 +++++++++++++++++++++------------------
 4 files changed, 110 insertions(+), 32 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 6a8445b..09de12b 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -61,6 +61,10 @@ struct svc_xprt {
 	void			*xpt_auth_cache;/* auth cache */
 	struct list_head	xpt_deferred;	/* deferred requests that need
 						 * to be revisted */
+	struct sockaddr_storage	xpt_local;	/* local address */
+	size_t			xpt_locallen;	/* length of address */
+	struct sockaddr_storage	xpt_remote;	/* remote peer's address */
+	size_t			xpt_remotelen;	/* length of address */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
@@ -70,9 +74,56 @@ void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
 int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
 void	svc_xprt_received(struct svc_xprt *);
 void	svc_xprt_put(struct svc_xprt *xprt);
+void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
 	kref_get(&xprt->xpt_ref);
 }
+static inline void svc_xprt_set_local(struct svc_xprt *xprt,
+				      struct sockaddr *sa, int salen)
+{
+	memcpy(&xprt->xpt_local, sa, salen);
+	xprt->xpt_locallen = salen;
+}
+static inline void svc_xprt_set_remote(struct svc_xprt *xprt,
+				       struct sockaddr *sa, int salen)
+{
+	memcpy(&xprt->xpt_remote, sa, salen);
+	xprt->xpt_remotelen = salen;
+}
+static inline unsigned short svc_addr_port(struct sockaddr *sa)
+{
+	unsigned short ret = 0;
+	switch (sa->sa_family) {
+	case AF_INET:
+		ret = ntohs(((struct sockaddr_in *)sa)->sin_port);
+		break;
+	case AF_INET6:
+		ret = ntohs(((struct sockaddr_in6 *)sa)->sin6_port);
+		break;
+	}
+	return ret;
+}
+
+static inline size_t svc_addr_len(struct sockaddr *sa)
+{
+	switch (sa->sa_family) {
+	case AF_INET:
+		return sizeof(struct sockaddr_in);
+	case AF_INET6:
+		return sizeof(struct sockaddr_in6);
+	}
+	return -EAFNOSUPPORT;
+}
+
+static inline unsigned short svc_xprt_local_port(struct svc_xprt *xprt)
+{
+	return svc_addr_port((struct sockaddr *)&xprt->xpt_local);
+}
+
+static inline unsigned short svc_xprt_remote_port(struct svc_xprt *xprt)
+{
+	return svc_addr_port((struct sockaddr *)&xprt->xpt_remote);
+}
 
 #endif /* SUNRPC_SVC_XPRT_H */
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
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 023aeb0..eb650af 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -125,7 +125,6 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 			spin_unlock(&svc_xprt_class_lock);
 			if (try_module_get(xcl->xcl_owner)) {
 				struct svc_xprt *newxprt;
-				ret = 0;
 				newxprt = xcl->xcl_ops->xpo_create
 					(serv,
 					 (struct sockaddr *)&sin, sizeof(sin),
@@ -133,7 +132,8 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 				if (IS_ERR(newxprt)) {
 					module_put(xcl->xcl_owner);
 					ret = PTR_ERR(newxprt);
-				}
+				} else
+					ret = svc_xprt_local_port(newxprt);
 			}
 			goto out;
 		}
@@ -144,3 +144,30 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 	return ret;
 }
 EXPORT_SYMBOL_GPL(svc_create_xprt);
+
+/*
+ * Copy the local and remote xprt addresses to the rqstp structure
+ */
+void svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt)
+{
+	struct sockaddr *sin;
+
+	memcpy(&rqstp->rq_addr, &xprt->xpt_remote, xprt->xpt_remotelen);
+	rqstp->rq_addrlen = xprt->xpt_remotelen;
+
+	/*
+	 * Destination address in request is needed for binding the
+	 * source address in RPC replies/callbacks later.
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
+EXPORT_SYMBOL_GPL(svc_xprt_copy_addrs);
+
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4d51098..298c95e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -623,33 +623,13 @@ svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
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
 
@@ -719,8 +699,15 @@ svc_write_space(struct sock *sk)
 	}
 }
 
-static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
-					    struct cmsghdr *cmh)
+/*
+ * Copy the UDP datagram's destination address to the rqstp structure.
+ * The 'destination' address in this case is the address to which the
+ * peer sent the datagram, i.e. our local address. For multihomed
+ * hosts, this can change from msg to msg. Note that only the IP
+ * address changes, the port number should remain the same.
+ */
+static void svc_udp_get_dest_address(struct svc_rqst *rqstp,
+				     struct cmsghdr *cmh)
 {
 	switch (rqstp->rq_sock->sk_sk->sk_family) {
 	case AF_INET: {
@@ -787,7 +774,10 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		svc_xprt_received(&svsk->sk_xprt);
 		return -EAGAIN;
 	}
-	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
+	len = svc_addr_len(svc_addr(rqstp));
+	if (len < 0)
+		return len;
+	rqstp->rq_addrlen = len;
 	if (skb->tstamp.tv64 == 0) {
 		skb->tstamp = ktime_get_real();
 		/* Don't enable netstamp, sunrpc doesn't
@@ -1097,14 +1087,13 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
 				 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
 		goto failed;
-	memcpy(&newsvsk->sk_remote, sin, slen);
-	newsvsk->sk_remotelen = slen;
+	svc_xprt_set_remote(&newsvsk->sk_xprt, sin, slen);
 	err = kernel_getsockname(newsock, sin, &slen);
 	if (unlikely(err < 0)) {
 		dprintk("svc_tcp_accept: kernel_getsockname error %d\n", -err);
 		slen = offsetof(struct sockaddr, sa_data);
 	}
-	memcpy(&newsvsk->sk_local, sin, slen);
+	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
 
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
@@ -1245,6 +1234,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
 
+	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
 	svc_xprt_received(&svsk->sk_xprt);
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
@@ -1805,6 +1795,11 @@ int svc_addsock(struct svc_serv *serv,
 	else {
 		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
 		if (svsk) {
+			struct sockaddr_storage addr;
+			struct sockaddr *sin = (struct sockaddr *)&addr;
+			int salen;
+			if (kernel_getsockname(svsk->sk_sock, sin, &salen) == 0)
+				svc_xprt_set_local(&svsk->sk_xprt, sin, salen);
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}
@@ -1831,6 +1826,9 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	int		error;
 	int		type;
 	char		buf[RPC_MAX_ADDRBUFLEN];
+	struct sockaddr_storage addr;
+	struct sockaddr *newsin = (struct sockaddr *)&addr;
+	int		newlen;
 
 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
 			serv->sv_program->pg_name, protocol,
@@ -1855,12 +1853,18 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	if (error < 0)
 		goto bummer;
 
+	newlen = len;
+	error = kernel_getsockname(sock, newsin, &newlen);
+	if (error < 0)
+		goto bummer;
+
 	if (protocol == IPPROTO_TCP) {
 		if ((error = kernel_listen(sock, 64)) < 0)
 			goto bummer;
 	}
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
+		svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
 		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}
