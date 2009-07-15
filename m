From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/10] SUNRPC: Provide functions for managing universal
	addresses
Date: Wed, 15 Jul 2009 17:37:09 -0400
Message-ID: <20090715213709.7582.56522.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38858
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752602AbZGOVhM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:37:12 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a set of functions in the kernel's RPC implementation for
converting between a socket address and either a standard
presentation address string or an RPC universal address.

The universal address functions will be used to encode and decode
RPCB_FOO and NFSv4 SETCLIENTID arguments.  The other functions are
part of a previous promise to deliver shared functions that can be
used by upper-layer protocols to display and manipulate IP
addresses.

The kernel's current address printf formatters were designed
specifically for kernel to user-space APIs that require a particular
string format for socket addresses, thus are somewhat limited for the
purposes of sunrpc.ko.  The formatter for IPv6 addresses, %pI6, does
not support short-handing or scope IDs.  Also, these printf formatters
are unique per address family, so a separate formatter string is
required for printing AF_INET and AF_INET6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h           |    2 
 include/linux/sunrpc/clnt.h |   12 +
 net/sunrpc/Makefile         |    2 
 net/sunrpc/addr.c           |  524 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 537 insertions(+), 3 deletions(-)
 create mode 100644 net/sunrpc/addr.c

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d3823d7..a19b7b9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -370,8 +370,6 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
-#define IPV6_SCOPE_DELIMITER	'%'
-
 /*
  * Set the port number in an address.  Be agnostic about the address
  * family.
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 37881f1..bf38c4a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -151,5 +151,17 @@ void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 
+unsigned short	rpc_get_port(const struct sockaddr *sap);
+void		rpc_set_port(struct sockaddr *sap, const unsigned short port);
+size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
+size_t		rpc_pton(const char *, const size_t,
+			 struct sockaddr *, const size_t);
+char *		rpc_sockaddr2uaddr(const struct sockaddr *);
+size_t		rpc_uaddr2sockaddr(const char *, const size_t,
+				   struct sockaddr *, const size_t);
+
+#define IPV6_SCOPE_DELIMITER		'%'
+#define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 7a594cc..6020f5b 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -12,7 +12,7 @@ obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
 sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    auth.o auth_null.o auth_unix.o auth_generic.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
-	    rpcb_clnt.o timer.o xdr.o \
+	    addr.o rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
 	    svc_xprt.o
 sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o bc_svc.o
diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
new file mode 100644
index 0000000..9ddcffd
--- /dev/null
+++ b/net/sunrpc/addr.c
@@ -0,0 +1,524 @@
+/*
+ * Copyright 2009, Oracle.  All rights reserved.
+ *
+ * Convert socket addresses to presentation addresses and universal
+ * addresses, and vice versa.
+ *
+ * Universal addresses are introduced by RFC 1833 and further refined by
+ * recent RFCs describing NFSv4.  The universal address format is part
+ * of the external (network) interface provided by rpcbind version 3
+ * and 4, and by NFSv4.  Such an address is a string containing a
+ * presentation format IP address followed by a port number in
+ * "hibyte.lobyte" format.
+ *
+ * There are some challenges to constructing universal addresses.
+ * In particular, constructing a presentation address string for IPv4
+ * is straightforward, but it's not so easy for IPv6 addresses.  Such
+ * addresses can be "short-handed" to remove the longest string of
+ * zeros, and mapped v4 presentation addresses can appear in a special
+ * dotted-quad form.  Refer to RFC 4291, Section 2.2 for details on
+ * IPv6 presentation formats.
+ *
+ * IPv6 addresses can also include a scope ID, typically denoted by
+ * a '%' followed by a device name or a non-negative integer.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/inet.h>
+
+#include <net/ipv6.h>
+
+#include <linux/sunrpc/clnt.h>
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
+struct rpc_zeros {
+	unsigned int	count;
+	int		index;
+};
+
+static const struct rpc_zeros zeros_init = {
+	.count		= 0,
+	.index		= -1,
+};
+
+static void rpc_find_longest_zero_run(const struct in6_addr *addr,
+				      struct rpc_zeros *longest)
+{
+	struct rpc_zeros zeros;
+	unsigned int i;
+
+	zeros = zeros_init;
+	*longest = zeros_init;
+
+	for (i = 0; i < ARRAY_SIZE(addr->s6_addr16); i++) {
+		if (addr->s6_addr16[i] == 0) {
+			if (zeros.index == -1)
+				zeros.index = i;
+			zeros.count++;
+		} else {
+			if (zeros.count > longest->count ||
+			    longest->index == -1)
+				*longest = zeros;
+			zeros = zeros_init;
+		}
+	}
+
+	/*
+	 * Maybe the last run of zeros didn't terminate.
+	 * Not likely for a host address.
+	 */
+	if (zeros.index != -1) {
+		if (zeros.count > longest->count ||
+		    longest->index == -1)
+			*longest = zeros;
+	}
+}
+
+/*
+ * Append a set of halfwords from @addr onto the string in @buf.
+ *
+ * Returns the new length of the string in @buf, or zero if
+ * some error occurs.
+ */
+static size_t rpc_append_halfword6(const struct in6_addr *addr,
+				   const char *fmt,
+				   const unsigned int start,
+				   const unsigned int end,
+				   char *buf, const size_t buflen)
+{
+	char tmp[sizeof("ffff:") + 1];
+	unsigned int i;
+	size_t len = 0;
+
+	for (i = start; i < end; i++) {
+		len = snprintf(tmp, sizeof(tmp), fmt,
+					ntohs(addr->s6_addr16[i]));
+		if (unlikely(len > sizeof(tmp)))
+			return 0;
+
+		len = strlcat(buf, tmp, buflen);
+		if (unlikely(len > buflen))
+			return 0;
+	}
+
+	return len;
+}
+
+/*
+ * This implementation depends on the Linux kernel's definition of
+ * in6_addr, which is a union of arrays that facilities dissecting
+ * the address into 16-bit chunks.
+ */
+static size_t rpc_ntop6_shorthand(const struct in6_addr *addr,
+				  struct rpc_zeros *longest,
+				  char *buf, const size_t buflen)
+{
+	size_t len;
+
+	/*
+	 * Left half, before the longest string of zeros
+	 */
+	buf[0] = '\0';
+	if (longest->index == 0) {
+		len = strlcat(buf, ":", buflen);
+		if (unlikely(len > buflen))
+			return 0;
+	} else {
+		len = rpc_append_halfword6(addr, "%x:",
+					0, longest->index, buf, buflen);
+		if (unlikely(len == 0))
+			return 0;
+	}
+
+	/*
+	 * Right half, after the longest string of zeros
+	 */
+	if (longest->index + longest->count >= ARRAY_SIZE(addr->s6_addr16)) {
+		len = strlcat(buf, ":", buflen);
+		if (unlikely(len > buflen))
+			return 0;
+	} else {
+		len = rpc_append_halfword6(addr, ":%x",
+			longest->index + longest->count,
+			ARRAY_SIZE(addr->s6_addr16), buf, buflen);
+		if (unlikely(len == 0))
+			return 0;
+	}
+
+	return len;
+}
+
+static size_t rpc_ntop6_noscopeid(const struct sockaddr *sap,
+				  char *buf, const int buflen)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	const struct in6_addr *addr = &sin6->sin6_addr;
+	struct rpc_zeros longest;
+
+	/*
+	 * RFC 4291, Section 2.2.3
+	 *
+	 * Special presentation address format for mapped v4
+	 * addresses.
+	 */
+	if (ipv6_addr_v4mapped(addr))
+		return snprintf(buf, buflen, "::ffff:%pI4",
+					&addr->s6_addr32[3]);
+
+	/*
+	 * RFC 4291, Section 2.2.2
+	 *
+	 * See if address can be short-handed.
+	 */
+	rpc_find_longest_zero_run(addr, &longest);
+	if (longest.index != -1 && longest.count > 1)
+		return rpc_ntop6_shorthand(addr, &longest, buf, buflen);
+
+	/*
+	 * RFC 4291, Section 2.2.1
+	 *
+	 * Short-handing not possible, so spell out full
+	 * address.  We don't want leading zeros in each
+	 * halfword, so avoid %pI6.
+	 */
+	return snprintf(buf, buflen, "%x:%x:%x:%x:%x:%x:%x:%x",
+		ntohs(addr->s6_addr16[0]), ntohs(addr->s6_addr16[1]),
+		ntohs(addr->s6_addr16[2]), ntohs(addr->s6_addr16[3]),
+		ntohs(addr->s6_addr16[4]), ntohs(addr->s6_addr16[5]),
+		ntohs(addr->s6_addr16[6]), ntohs(addr->s6_addr16[7]));
+}
+
+static size_t rpc_ntop6(const struct sockaddr *sap,
+			char *buf, const size_t buflen)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	char scopebuf[IPV6_SCOPE_ID_LEN];
+	size_t len;
+	int rc;
+
+	len = rpc_ntop6_noscopeid(sap, buf, buflen);
+	if (unlikely(len == 0))
+		return len;
+
+	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) &&
+	    !(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_SITELOCAL))
+		return len;
+
+	rc = snprintf(scopebuf, sizeof(scopebuf), "%c%u",
+			IPV6_SCOPE_DELIMITER, sin6->sin6_scope_id);
+	if (unlikely((size_t)rc > sizeof(scopebuf)))
+		return 0;
+
+	len += rc;
+	if (unlikely(len > buflen))
+		return 0;
+
+	strcat(buf, scopebuf);
+	return len;
+}
+
+#else	/* !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) */
+
+static size_t rpc_ntop6_noscopeid(const struct sockaddr *sap,
+				  char *buf, const int buflen)
+{
+	return 0;
+}
+
+static size_t rpc_ntop6(const struct sockaddr *sap,
+			char *buf, const size_t buflen)
+{
+	return 0;
+}
+
+#endif	/* !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) */
+
+static int rpc_ntop4(const struct sockaddr *sap,
+		     char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+
+	return snprintf(buf, buflen, "%pI4", &sin->sin_addr);
+}
+
+/**
+ * rpc_ntop - construct a presentation address in @buf
+ * @sap: socket address
+ * @buf: construction area
+ * @buflen: size of @buf, in bytes
+ *
+ * Plants a %NUL-terminated string in @buf and returns the length
+ * of the string, excluding the %NUL.  Otherwise zero is returned.
+ */
+size_t rpc_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	char tmp[INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN + 1];
+	size_t len;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		len = rpc_ntop4(sap, tmp, sizeof(tmp));
+		break;
+	case AF_INET6:
+		len = rpc_ntop6(sap, tmp, sizeof(tmp));
+		break;
+	default:
+		return 0;
+	}
+
+	if (unlikely(len == 0 || len > sizeof(tmp) || len > buflen))
+		return 0;
+	return strlcpy(buf, tmp, buflen);
+}
+EXPORT_SYMBOL_GPL(rpc_ntop);
+
+static size_t rpc_pton4(const char *buf, const size_t buflen,
+			struct sockaddr *sap, const size_t salen)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	u8 *addr = (u8 *)&sin->sin_addr.s_addr;
+
+	if (buflen > INET_ADDRSTRLEN || salen < sizeof(struct sockaddr_in))
+		return 0;
+
+	memset(sap, 0, sizeof(struct sockaddr_in));
+
+	if (in4_pton(buf, buflen, addr, '\0', NULL) == 0)
+		return 0;
+
+	sin->sin_family = AF_INET;
+	return sizeof(struct sockaddr_in);;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int rpc_parse_scope_id(const char *buf, const size_t buflen,
+			      const char *delim, struct sockaddr_in6 *sin6)
+{
+	char *p;
+	size_t len;
+
+	if ((buf + buflen) == delim)
+		return 1;
+
+	if (*delim != IPV6_SCOPE_DELIMITER)
+		return 0;
+
+	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) &&
+	    !(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_SITELOCAL))
+		return 0;
+
+	len = (buf + buflen) - delim - 1;
+	p = kstrndup(delim + 1, len, GFP_KERNEL);
+	if (p) {
+		unsigned long scope_id = 0;
+		struct net_device *dev;
+
+		dev = dev_get_by_name(&init_net, p);
+		if (dev != NULL) {
+			scope_id = dev->ifindex;
+			dev_put(dev);
+		} else {
+			if (strict_strtoul(p, 10, &scope_id) == 0) {
+				kfree(p);
+				return 0;
+			}
+		}
+
+		kfree(p);
+
+		sin6->sin6_scope_id = scope_id;
+		return 1;
+	}
+
+	return 0;
+}
+
+static size_t rpc_pton6(const char *buf, const size_t buflen,
+			struct sockaddr *sap, const size_t salen)
+{
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
+	const char *delim;
+
+	if (buflen > (INET6_ADDRSTRLEN + sizeof("%nnnnn")) ||
+	    salen < sizeof(struct sockaddr_in6))
+		return 0;
+
+	memset(sap, 0, sizeof(struct sockaddr_in6));
+
+	if (in6_pton(buf, buflen, addr, IPV6_SCOPE_DELIMITER, &delim) == 0)
+		return 0;
+
+	if (!rpc_parse_scope_id(buf, buflen, delim, sin6))
+		return 0;
+
+	sin6->sin6_family = AF_INET6;
+	return sizeof(struct sockaddr_in6);
+}
+#else
+static size_t rpc_pton6(const char *buf, const size_t buflen,
+			struct sockaddr *sap, const size_t salen)
+{
+	return 0;
+}
+#endif
+
+/**
+ * rpc_pton - Construct a sockaddr in @sap
+ * @buf: C string containing presentation format IP address
+ * @buflen: length of presentation address in bytes
+ * @sap: buffer into which to plant socket address
+ * @salen: size of buffer in bytes
+ *
+ * Returns the size of the socket address if successful; otherwise
+ * zero is returned.
+ *
+ * Plants a socket address in @sap and returns the size of the
+ * socket address, if successful.  Returns zero if an error
+ * occurred.
+ */
+size_t rpc_pton(const char *buf, const size_t buflen,
+		struct sockaddr *sap, const size_t salen)
+{
+	unsigned int i;
+
+	for (i = 0; i < buflen; i++)
+		if (buf[i] == ':')
+			return rpc_pton6(buf, buflen, sap, salen);
+	return rpc_pton4(buf, buflen, sap, salen);
+}
+EXPORT_SYMBOL_GPL(rpc_pton);
+
+/**
+ * rpc_sockaddr2uaddr - Construct a universal address string from @sap.
+ * @sap: socket address
+ *
+ * Returns a %NUL-terminated string in dynamically allocated memory;
+ * otherwise NULL is returned if an error occurred.  Caller must
+ * free the returned string.
+ */
+char *rpc_sockaddr2uaddr(const struct sockaddr *sap)
+{
+	char portbuf[RPCBIND_MAXUADDRPLEN + 1];
+	char addrbuf[RPCBIND_MAXUADDRLEN + 1];
+	unsigned short port;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		if (rpc_ntop4(sap, addrbuf, sizeof(addrbuf)) == 0)
+			return NULL;
+		port = ntohs(((struct sockaddr_in *)sap)->sin_port);
+		break;
+	case AF_INET6:
+		if (rpc_ntop6_noscopeid(sap, addrbuf, sizeof(addrbuf)) == 0)
+			return NULL;
+		port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+		break;
+	default:
+		return NULL;
+	}
+
+	if (snprintf(portbuf, sizeof(portbuf),
+		     ".%u.%u", port >> 8, port & 0xff) > (int)sizeof(portbuf))
+		return NULL;
+
+	if (strlcat(addrbuf, portbuf, sizeof(addrbuf)) > sizeof(addrbuf))
+		return NULL;
+
+	return kstrdup(addrbuf, GFP_ATOMIC);
+}
+EXPORT_SYMBOL_GPL(rpc_sockaddr2uaddr);
+
+/**
+ * rpc_uaddr2sockaddr - convert a universal address to a socket address.
+ * @uaddr: C string containing universal address to convert
+ * @uaddr_len: length of universal address string
+ * @sap: buffer into which to plant socket address
+ * @salen: size of buffer
+ *
+ * Returns the size of the socket address if successful; otherwise
+ * zero is returned.
+ */
+size_t rpc_uaddr2sockaddr(const char *uaddr, const size_t uaddr_len,
+			  struct sockaddr *sap, const size_t salen)
+{
+	char *c, buf[RPCBIND_MAXUADDRLEN + 2];
+	unsigned long portlo, porthi;
+	unsigned short port;
+
+	if (uaddr_len > sizeof(buf))
+		return 0;
+
+	memcpy(buf, uaddr, uaddr_len);
+
+	buf[uaddr_len] = '\n';
+	buf[uaddr_len + 1] = '\0';
+
+	c = strrchr(buf, '.');
+	if (unlikely(c == NULL))
+		return 0;
+	if (unlikely(strict_strtoul(c + 1, 10, &portlo) != 0))
+		return 0;
+	if (unlikely(portlo > 255))
+		return 0;
+
+	c[0] = '\n';
+	c[1] = '\0';
+
+	c = strrchr(buf, '.');
+	if (unlikely(c == NULL))
+		return 0;
+	if (unlikely(strict_strtoul(c + 1, 10, &porthi) != 0))
+		return 0;
+	if (unlikely(porthi > 255))
+		return 0;
+
+	port = (unsigned short)((porthi << 8) | portlo);
+
+	c[0] = '\0';
+
+	if (rpc_pton(buf, strlen(buf), sap, salen) == 0)
+		return 0;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *)sap)->sin_port = htons(port);
+		return sizeof(struct sockaddr_in);
+	case AF_INET6:
+		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
+		return sizeof(struct sockaddr_in6);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_uaddr2sockaddr);
+
+unsigned short rpc_get_port(const struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		return ntohs(((struct sockaddr_in *)sap)->sin_port);
+	case AF_INET6:
+		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_get_port);
+
+void rpc_set_port(struct sockaddr *sap, const unsigned short port)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *)sap)->sin_port = htons(port);
+		break;
+	case AF_INET6:
+		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(rpc_set_port);

