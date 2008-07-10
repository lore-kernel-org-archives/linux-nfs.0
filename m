From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/14] text-based mount command: get_client_address support
	for IPv6
Date: Wed, 09 Jul 2008 20:37:24 -0400
Message-ID: <20080710003723.6137.51761.stgit@tarkus.1015granger.net>
References: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:61667 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbYGJEIJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 00:08:09 -0400
In-Reply-To: <20080710001725.6137.83845.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce IPv6-enabled version of get_client_address.  The legacy mount
command could use this eventually as well.

I don't remember how to tell an NFSv4 server to disable the callback
channel:  whether an ANY address is passed with SETCLIENTID, or a
loopback address is passed.  The patch allows either to be used with a
compile-time switch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |  122 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    2 +
 2 files changed, 124 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 3f2721b..128d7f7 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -918,3 +918,125 @@ int get_client_address(struct sockaddr_in *saddr, struct sockaddr_in *caddr)
 	}
 	return 1;
 }
+
+/*
+ * Try a getsockname() on a connected datagram socket.
+ *
+ * Returns 1 and fills in @buf if successful; otherwise, zero.
+ *
+ * A connected datagram socket prevents leaving a socket in TIME_WAIT.
+ * This conserves the ephemeral port number space, helping reduce failed
+ * socket binds during mount storms.
+ */
+static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
+			   struct sockaddr *buf, socklen_t *buflen)
+{
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+	};
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+	};
+	int sock;
+
+	sock = socket(sap->sa_family, SOCK_DGRAM, IPPROTO_UDP);
+	if (sock < 0)
+		return 0;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		if (bind(sock, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
+			close(sock);
+			return 0;
+		}
+		break;
+	case AF_INET6:
+		if (bind(sock, (struct sockaddr *)&sin6, sizeof(sin6)) < 0) {
+			close(sock);
+			return 0;
+		}
+		break;
+	default:
+		errno = EAFNOSUPPORT;
+		return 0;
+	}
+
+	if (connect(sock, sap, salen) < 0) {
+		close(sock);
+		return 0;
+	}
+
+	return !getsockname(sock, buf, buflen);
+}
+
+/*
+ * Try to generate an address that prevents the server from calling us.
+ *
+ * Returns 1 and fills in @buf if successful; otherwise, zero.
+ */
+static int nfs_ca_gai(const struct sockaddr *sap, const socklen_t salen,
+		      struct sockaddr *buf, socklen_t *buflen)
+{
+	struct addrinfo *gai_results;
+	struct addrinfo gai_hint = {
+		.ai_family	= sap->sa_family,
+#ifdef GENERATE_LOOPBACK_ADDRESS
+		.ai_flags	= 0,		/* loopback */
+#else
+		.ai_flags	= AI_PASSIVE,	/* ANYADDR */
+#endif
+	};
+
+	if (getaddrinfo(NULL, "", &gai_hint, &gai_results))
+		return 0;
+
+	*buflen = gai_results->ai_addrlen;
+	memcpy(buf, gai_results->ai_addr, *buflen);
+
+	freeaddrinfo(gai_results);
+
+	return 1;
+}
+
+/**
+ * nfs_callback_address - acquire our local network address
+ * @sap: pointer to address of remote
+ * @sap_len: length of address
+ * @buf: pointer to buffer to be filled in with local network address
+ * @buflen: IN: length of buffer to fill in; OUT: length of filled-in address
+ *
+ * Discover a network address that an NFSv4 server can use to call us back.
+ * On multi-homed clients, this address depends on which NIC we use to
+ * route requests to the server.
+ *
+ * Returns 1 and fills in @buf if an unambiguous local address is
+ * available; returns 1 and fills in an appropriate ANYADDR address
+ * if a local address isn't available; otherwise, returns zero.
+ */
+int nfs_callback_address(const struct sockaddr *sap, const socklen_t salen,
+			 struct sockaddr *buf, socklen_t *buflen)
+{
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)buf;
+
+	if (nfs_ca_sockname(sap, salen, buf, buflen) == 0)
+		if (nfs_ca_gai(sap, salen, buf, buflen) == 0)
+			goto out_failed;
+
+	/*
+	 * The server can't use an interface ID that was generated
+	 * here on the client, so always clear sin6_scope_id.
+	 */
+	if (sin6->sin6_family == AF_INET6)
+		sin6->sin6_scope_id = 0;
+
+	return 1;
+
+out_failed:
+	*buflen = 0;
+	if (verbose)
+		nfs_error(_("%s: failed to construct callback address"));
+	return 0;
+
+}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 8da7e20..2f4ff3a 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -58,6 +58,8 @@ int nfs_string_to_sockaddr(const char *, const size_t,
 int nfs_present_sockaddr(const struct sockaddr *,
 			 const socklen_t, char *, const size_t);
 int get_client_address(struct sockaddr_in *, struct sockaddr_in *);
+int nfs_callback_address(const struct sockaddr *, const socklen_t,
+		struct sockaddr *, socklen_t *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,

