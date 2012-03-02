Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45757 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758615Ab2CBV7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 16:59:24 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so2853208iag.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 13:59:24 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/12] SUNRPC: Add API to acquire source address
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 02 Mar 2012 16:59:23 -0500
Message-ID: <20120302215922.12758.79594.stgit@degas.1015granger.net>
In-Reply-To: <20120302215559.12758.39526.stgit@degas.1015granger.net>
References: <20120302215559.12758.39526.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.0 clients must send endpoint information for their callback
service to NFSv4.0 servers during their first contact with a server.
Traditionally on Linux, user space provides the callback endpoint IP
address via the "clientaddr=" mount option.

During an NFSv4 migration event, it is possible that an FSID may be
migrated to a destination server that is accessible via a different
source IP address than the source server was.  The client must update
callback endpoint information on the destination server so that it can
maintain leases and allow delegation.

Without a new "clientaddr=" option from user space, however, the
kernel itself must construct an appropriate IP address for the
callback update.  Provide an API in the RPC client for upper layer
RPC consumers to acquire a source address for a remote.

The mechanism used by the mount.nfs command is copied: set up a
connected UDP socket to the designated remote, then scrape the source
address off the socket.  We are careful to select the correct network
namespace when setting up the temporary UDP socket.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    1 
 net/sunrpc/clnt.c           |  149 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 150 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index acd5502..523547e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -161,6 +161,7 @@ size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
+int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
 
 size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
 size_t		rpc_pton(struct net *, const char *, const size_t,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 84bebb1..064e55bb 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -898,6 +898,155 @@ const char *rpc_peeraddr2str(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
 
+static const struct sockaddr_in rpc_inaddr_loopback = {
+	.sin_family		= AF_INET,
+	.sin_addr.s_addr	= htonl(INADDR_ANY),
+};
+
+static const struct sockaddr_in6 rpc_in6addr_loopback = {
+	.sin6_family		= AF_INET6,
+	.sin6_addr		= IN6ADDR_ANY_INIT,
+};
+
+/*
+ * Try a getsockname() on a connected datagram socket.  Using a
+ * connected datagram socket prevents leaving a socket in TIME_WAIT.
+ * This conserves the ephemeral port number space.
+ *
+ * Returns zero and fills in "buf" if successful; otherwise, a
+ * negative errno is returned.
+ */
+static int rpc_sockname(struct net *net, struct sockaddr *sap, size_t salen,
+			struct sockaddr *buf, int buflen)
+{
+	struct socket *sock;
+	int err;
+
+	err = __sock_create(net, sap->sa_family,
+				SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
+	if (err < 0) {
+		dprintk("RPC:       can't create UDP socket (%d)\n", err);
+		goto out;
+	}
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		err = kernel_bind(sock,
+				(struct sockaddr *)&rpc_inaddr_loopback,
+				sizeof(rpc_inaddr_loopback));
+		break;
+	case AF_INET6:
+		err = kernel_bind(sock,
+				(struct sockaddr *)&rpc_in6addr_loopback,
+				sizeof(rpc_in6addr_loopback));
+		break;
+	default:
+		err = -EAFNOSUPPORT;
+		goto out;
+	}
+	if (err < 0) {
+		dprintk("RPC:       can't bind UDP socket (%d)\n", err);
+		goto out_release;
+	}
+
+	err = kernel_connect(sock, sap, salen, 0);
+	if (err < 0) {
+		dprintk("RPC:       can't connect UDP socket (%d)\n", err);
+		goto out_release;
+	}
+
+	err = kernel_getsockname(sock, buf, &buflen);
+	if (err < 0) {
+		dprintk("RPC:       getsockname failed (%d)\n", err);
+		goto out_release;
+	}
+
+	err = 0;
+	if (buf->sa_family == AF_INET6) {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)buf;
+		sin6->sin6_scope_id = 0;
+	}
+	dprintk("RPC:       %s succeeded\n", __func__);
+
+out_release:
+	sock_release(sock);
+out:
+	return err;
+}
+
+/*
+ * Scraping a connected socket failed, so we don't have a useable
+ * local address.  Fallback: generate an address that will prevent
+ * the server from calling us back.
+ *
+ * Returns zero and fills in "buf" if successful; otherwise, a
+ * negative errno is returned.
+ */
+static int rpc_anyaddr(int family, struct sockaddr *buf, size_t buflen)
+{
+	switch (family) {
+	case AF_INET:
+		if (buflen < sizeof(rpc_inaddr_loopback))
+			return -EINVAL;
+		memcpy(buf, &rpc_inaddr_loopback,
+				sizeof(rpc_inaddr_loopback));
+		break;
+	case AF_INET6:
+		if (buflen < sizeof(rpc_in6addr_loopback))
+			return -EINVAL;
+		memcpy(buf, &rpc_in6addr_loopback,
+				sizeof(rpc_in6addr_loopback));
+	default:
+		dprintk("RPC:       %s: address family not supported\n",
+			__func__);
+		return -EAFNOSUPPORT;
+	}
+	dprintk("RPC:       %s: succeeded\n", __func__);
+	return 0;
+}
+
+/**
+ * rpc_localaddr - discover local endpoint address for an RPC client
+ * @clnt: RPC client structure
+ * @buf: target buffer
+ * @buflen: size of target buffer, in bytes
+ *
+ * Returns zero and fills in "buf" and "buflen" if successful;
+ * otherwise, a negative errno is returned.
+ *
+ * This works even if the underlying transport is not currently connected,
+ * or if the upper layer never previously provided a source address.
+ *
+ * The result of this function call is transient: multiple calls in
+ * succession may give different results, depending on how local
+ * networking configuration changes over time.
+ */
+int rpc_localaddr(struct rpc_clnt *clnt, struct sockaddr *buf, size_t buflen)
+{
+	struct sockaddr_storage address;
+	struct sockaddr *sap = (struct sockaddr *)&address;
+	struct rpc_xprt *xprt;
+	struct net *net;
+	size_t salen;
+	int err;
+
+	rcu_read_lock();
+	xprt = rcu_dereference(clnt->cl_xprt);
+	salen = xprt->addrlen;
+	memcpy(sap, &xprt->addr, salen);
+	net = get_net(xprt->xprt_net);
+	rcu_read_unlock();
+
+	rpc_set_port(sap, 0);
+	err = rpc_sockname(net, sap, salen, buf, buflen);
+	put_net(net);
+	if (err != 0)
+		/* Couldn't discover local address, return ANYADDR */
+		return rpc_anyaddr(sap->sa_family, buf, buflen);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_localaddr);
+
 void
 rpc_setbufsize(struct rpc_clnt *clnt, unsigned int sndsize, unsigned int rcvsize)
 {

