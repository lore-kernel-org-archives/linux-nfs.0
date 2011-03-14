Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52145 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab1CNM4p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:56:45 -0400
Received: by iyb26 with SMTP id 26so4900509iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:56:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/12] SUNRPC: Add API to acquire source address
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:56:42 -0400
Message-ID: <20110314125642.2413.4936.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFSv4.0 clients have to send endpoint information for their callback
service to NFSv4.0 servers during SETCLIENTID negotiation.
Traditionally, user space provides the callback endpoint IP address
via the "clientaddr=" mount option.

During an NFSv4 migration event, it is possible that an FSID may be
migrated to a destination server that is accessible by a different NIC
than the source server.  The client must update the callback endpoint
information on the destination server so that it can maintain leases
and allow delegation.  Without a new "clientaddr=" option, though, the
kernel itself must construct an appropriate IP address for the
callback service.

Provide an API in the RPC client for upper layers to acquire a source
address for a remote.  We copy the mechanism used by the mount
command: set up a connected UDP socket to the remote, then scrape the
source address off the socket.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    1 
 net/sunrpc/clnt.c           |  132 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 133 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 70acded..ca48893 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -169,6 +169,7 @@ size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
+int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t *);
 
 size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
 size_t		rpc_pton(const char *, const size_t,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 042e7da..49d8460 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -930,6 +930,138 @@ const char *rpc_peeraddr2str(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
 
+/*
+ * Try a getsockname() on a connected datagram socket.  Using a
+ * connected datagram socket prevents leaving a socket in TIME_WAIT.
+ * This conserves the ephemeral port number space.
+ *
+ * Returns zero and fills in "buf" and "bufsize" if successful;
+ * otherwise, a negative errno is returned.
+ */
+static int rpc_sockname(struct net *net, struct sockaddr *sap, size_t salen,
+			struct sockaddr *buf, size_t *bufsize)
+{
+	struct socket *sock;
+	int err, buflen;
+
+	err = __sock_create(net, sap->sa_family,
+				SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
+	if (err < 0) {
+		dprintk("RPC:       can't create UDP socket (%d)\n", -err);
+		goto out;
+	}
+
+	err = kernel_bind(sock, sap, salen);
+	if (err < 0) {
+		dprintk("RPC:       can't bind UDP socket (%d)\n", -err);
+		goto out_release;
+	}
+
+	err = kernel_connect(sock, sap, salen, 0);
+	if (err < 0) {
+		dprintk("RPC:       can't connect UDP socket (%d)\n", -err);
+		goto out_release;
+	}
+
+	err = kernel_getsockname(sock, buf, &buflen);
+	if (err < 0) {
+		dprintk("RPC:       getsockname failed (%d)\n", -err);
+		goto out_release;
+	}
+
+	err = 0;
+	*bufsize = buflen;
+	if (buf->sa_family == AF_INET6) {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)buf;
+		sin6->sin6_scope_id = 0;
+	}
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
+ * Returns zero and fills in "buf" and "bufsize" if successful;
+ * otherwise, a negative errno is returned.
+ */
+static int rpc_anyaddr(int family, struct sockaddr *buf, size_t *bufsize)
+{
+	static const struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+	};
+	static const struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+	};
+	size_t buflen = *bufsize;
+
+	switch (family) {
+	case AF_INET:
+		if (buflen < sizeof(sin))
+			return -EINVAL;
+		memcpy(buf, &sin, sizeof(sin));
+		*bufsize = sizeof(sin);
+		break;
+	case AF_INET6:
+		if (buflen < sizeof(sin6))
+			return -EINVAL;
+		memcpy(buf, &sin6, sizeof(sin6));
+		*bufsize = sizeof(sin);
+	default:
+		return -EAFNOSUPPORT;
+	}
+	return 0;
+}
+
+/**
+ * rpc_localaddr - discover local endpoint address for an RPC client
+ * @clnt: RPC client structure
+ * @buf: target buffer
+ * @bufsize: IN: length of target buffer; OUT: length of local address
+ *
+ * Returns zero and fills in "buf" and "bufsize" if successful;
+ * otherwise, a negative errno is returned.
+ *
+ * This works even if the underlying transport is not currently connected,
+ * or if the upper layer never previously provided a source address.
+ *
+ * The results of this function call are transient: multiple calls in
+ * succession may give different results, depending on how local
+ * networking configuration changes over time.
+ */
+int rpc_localaddr(struct rpc_clnt *clnt, struct sockaddr *buf, size_t *bufsize)
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
+	err = rpc_sockname(net, sap, salen, buf, bufsize);
+	put_net(net);
+	if (err < 0) {
+		err = rpc_anyaddr(sap->sa_family, buf, bufsize);
+		if (err < 0)
+			return err;
+	}
+	return 0;
+}
+
 void
 rpc_setbufsize(struct rpc_clnt *clnt, unsigned int sndsize, unsigned int rcvsize)
 {

