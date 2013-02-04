Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:40587 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229Ab3BDPaY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 10:30:24 -0500
Received: by mail-qc0-f173.google.com with SMTP id b12so2725461qca.32
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 07:30:23 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: move address copy/cmp/convert routines and prototypes from clnt.h to addr.h
Date: Mon,  4 Feb 2013 10:23:51 -0500
Message-Id: <1359991431-25579-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These routines are used by server and client code, so having them in a
separate header would be best.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/clntlock.c             |   2 +-
 fs/lockd/host.c                 |   1 +
 fs/lockd/mon.c                  |   1 +
 fs/lockd/svcsubs.c              |   2 +-
 fs/nfs/dns_resolve.c            |   1 +
 fs/nfs/nfs4client.c             |   1 +
 fs/nfs/nfs4filelayoutdev.c      |   1 +
 fs/nfs/nfs4namespace.c          |   1 +
 fs/nfs/super.c                  |   1 +
 fs/nfsd/nfs4state.c             |   2 +-
 fs/nfsd/nfscache.c              |   2 +-
 fs/nfsd/nfsctl.c                |   2 +-
 include/linux/sunrpc/addr.h     | 170 ++++++++++++++++++++++++++++++++++++++++
 include/linux/sunrpc/clnt.h     | 155 ------------------------------------
 net/sunrpc/addr.c               |   3 +-
 net/sunrpc/clnt.c               |   1 +
 net/sunrpc/rpcb_clnt.c          |   1 +
 net/sunrpc/svcauth_unix.c       |   2 +-
 net/sunrpc/xprtrdma/transport.c |   1 +
 net/sunrpc/xprtsock.c           |   1 +
 20 files changed, 189 insertions(+), 162 deletions(-)
 create mode 100644 include/linux/sunrpc/addr.h

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index ca0a080..4885b53 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -11,7 +11,7 @@
 #include <linux/slab.h>
 #include <linux/time.h>
 #include <linux/nfs_fs.h>
-#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/kthread.h>
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 0e17090..764c4d2 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -13,6 +13,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/mutex.h>
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 3c2cfc6..1812f02 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 0deb5f6..8064435 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -13,7 +13,7 @@
 #include <linux/slab.h>
 #include <linux/mutex.h>
 #include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/export.h>
 #include <linux/lockd/lockd.h>
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 0ff1f4c..178fb24 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -10,6 +10,7 @@
 
 #include <linux/module.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/dns_resolver.h>
 #include "dns_resolve.h"
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index acc3472..e5f2fad 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -6,6 +6,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_idmap.h>
 #include <linux/nfs_mount.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/bc_xprt.h>
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index b720064..1fe284f 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -31,6 +31,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/vmalloc.h>
 #include <linux/module.h>
+#include <linux/sunrpc/addr.h>
 
 #include "internal.h"
 #include "nfs4session.h"
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 1e09eb7..0dd7660 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -14,6 +14,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include "internal.h"
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c25cadf8..3250b41 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -31,6 +31,7 @@
 #include <linux/errno.h>
 #include <linux/unistd.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/xprtsock.h>
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4db46aa..8c2bdfa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -40,7 +40,7 @@
 #include <linux/pagemap.h>
 #include <linux/ratelimit.h>
 #include <linux/sunrpc/svcauth_gss.h>
-#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include "xdr4.h"
 #include "vfs.h"
 #include "current_stateid.h"
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index cb655f3..07b4c19 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -9,7 +9,7 @@
  */
 
 #include <linux/slab.h>
-#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/highmem.h>
 #include <linux/crc32.h>
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 65889ec..29c3f0d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -10,7 +10,7 @@
 
 #include <linux/sunrpc/svcsock.h>
 #include <linux/lockd/lockd.h>
-#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/sunrpc/gss_krb5_enctypes.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
diff --git a/include/linux/sunrpc/addr.h b/include/linux/sunrpc/addr.h
new file mode 100644
index 0000000..07d8e53
--- /dev/null
+++ b/include/linux/sunrpc/addr.h
@@ -0,0 +1,170 @@
+/*
+ * linux/include/linux/sunrpc/addr.h
+ *
+ * Various routines for copying and comparing sockaddrs and for
+ * converting them to and from presentation format.
+ */
+#ifndef _LINUX_SUNRPC_ADDR_H
+#define _LINUX_SUNRPC_ADDR_H
+
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
+
+size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
+size_t		rpc_pton(struct net *, const char *, const size_t,
+			 struct sockaddr *, const size_t);
+char *		rpc_sockaddr2uaddr(const struct sockaddr *, gfp_t);
+size_t		rpc_uaddr2sockaddr(struct net *, const char *, const size_t,
+				   struct sockaddr *, const size_t);
+
+static inline unsigned short rpc_get_port(const struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		return ntohs(((struct sockaddr_in *)sap)->sin_port);
+	case AF_INET6:
+		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+	}
+	return 0;
+}
+
+static inline void rpc_set_port(struct sockaddr *sap,
+				const unsigned short port)
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
+
+#define IPV6_SCOPE_DELIMITER		'%'
+#define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
+
+static inline bool __rpc_cmp_addr4(const struct sockaddr *sap1,
+				   const struct sockaddr *sap2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
+
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+}
+
+static inline bool __rpc_copy_addr4(struct sockaddr *dst,
+				    const struct sockaddr *src)
+{
+	const struct sockaddr_in *ssin = (struct sockaddr_in *) src;
+	struct sockaddr_in *dsin = (struct sockaddr_in *) dst;
+
+	dsin->sin_family = ssin->sin_family;
+	dsin->sin_addr.s_addr = ssin->sin_addr.s_addr;
+	return true;
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
+				   const struct sockaddr *sap2)
+{
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
+
+	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
+		return false;
+	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		return sin1->sin6_scope_id == sin2->sin6_scope_id;
+
+	return true;
+}
+
+static inline bool __rpc_copy_addr6(struct sockaddr *dst,
+				    const struct sockaddr *src)
+{
+	const struct sockaddr_in6 *ssin6 = (const struct sockaddr_in6 *) src;
+	struct sockaddr_in6 *dsin6 = (struct sockaddr_in6 *) dst;
+
+	dsin6->sin6_family = ssin6->sin6_family;
+	dsin6->sin6_addr = ssin6->sin6_addr;
+	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
+	return true;
+}
+#else	/* !(IS_ENABLED(CONFIG_IPV6) */
+static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
+				   const struct sockaddr *sap2)
+{
+	return false;
+}
+
+static inline bool __rpc_copy_addr6(struct sockaddr *dst,
+				    const struct sockaddr *src)
+{
+	return false;
+}
+#endif	/* !(IS_ENABLED(CONFIG_IPV6) */
+
+/**
+ * rpc_cmp_addr - compare the address portion of two sockaddrs.
+ * @sap1: first sockaddr
+ * @sap2: second sockaddr
+ *
+ * Just compares the family and address portion. Ignores port, but
+ * compares the scope if it's a link-local address.
+ *
+ * Returns true if the addrs are equal, false if they aren't.
+ */
+static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
+				const struct sockaddr *sap2)
+{
+	if (sap1->sa_family == sap2->sa_family) {
+		switch (sap1->sa_family) {
+		case AF_INET:
+			return __rpc_cmp_addr4(sap1, sap2);
+		case AF_INET6:
+			return __rpc_cmp_addr6(sap1, sap2);
+		}
+	}
+	return false;
+}
+
+/**
+ * rpc_copy_addr - copy the address portion of one sockaddr to another
+ * @dst: destination sockaddr
+ * @src: source sockaddr
+ *
+ * Just copies the address portion and family. Ignores port, scope, etc.
+ * Caller is responsible for making certain that dst is large enough to hold
+ * the address in src. Returns true if address family is supported. Returns
+ * false otherwise.
+ */
+static inline bool rpc_copy_addr(struct sockaddr *dst,
+				 const struct sockaddr *src)
+{
+	switch (src->sa_family) {
+	case AF_INET:
+		return __rpc_copy_addr4(dst, src);
+	case AF_INET6:
+		return __rpc_copy_addr6(dst, src);
+	}
+	return false;
+}
+
+/**
+ * rpc_get_scope_id - return scopeid for a given sockaddr
+ * @sa: sockaddr to get scopeid from
+ *
+ * Returns the value of the sin6_scope_id for AF_INET6 addrs, or 0 if
+ * not an AF_INET6 address.
+ */
+static inline u32 rpc_get_scope_id(const struct sockaddr *sa)
+{
+	if (sa->sa_family != AF_INET6)
+		return 0;
+
+	return ((struct sockaddr_in6 *) sa)->sin6_scope_id;
+}
+
+#endif /* _LINUX_SUNRPC_ADDR_H */
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6a7c261..4a4abde 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -165,160 +165,5 @@ size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
 
-size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
-size_t		rpc_pton(struct net *, const char *, const size_t,
-			 struct sockaddr *, const size_t);
-char *		rpc_sockaddr2uaddr(const struct sockaddr *, gfp_t);
-size_t		rpc_uaddr2sockaddr(struct net *, const char *, const size_t,
-				   struct sockaddr *, const size_t);
-
-static inline unsigned short rpc_get_port(const struct sockaddr *sap)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		return ntohs(((struct sockaddr_in *)sap)->sin_port);
-	case AF_INET6:
-		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
-	}
-	return 0;
-}
-
-static inline void rpc_set_port(struct sockaddr *sap,
-				const unsigned short port)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)sap)->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
-		break;
-	}
-}
-
-#define IPV6_SCOPE_DELIMITER		'%'
-#define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
-
-static inline bool __rpc_cmp_addr4(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
-	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
-
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
-}
-
-static inline bool __rpc_copy_addr4(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	const struct sockaddr_in *ssin = (struct sockaddr_in *) src;
-	struct sockaddr_in *dsin = (struct sockaddr_in *) dst;
-
-	dsin->sin_family = ssin->sin_family;
-	dsin->sin_addr.s_addr = ssin->sin_addr.s_addr;
-	return true;
-}
-
-#if IS_ENABLED(CONFIG_IPV6)
-static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
-	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
-
-	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
-		return false;
-	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		return sin1->sin6_scope_id == sin2->sin6_scope_id;
-
-	return true;
-}
-
-static inline bool __rpc_copy_addr6(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	const struct sockaddr_in6 *ssin6 = (const struct sockaddr_in6 *) src;
-	struct sockaddr_in6 *dsin6 = (struct sockaddr_in6 *) dst;
-
-	dsin6->sin6_family = ssin6->sin6_family;
-	dsin6->sin6_addr = ssin6->sin6_addr;
-	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
-	return true;
-}
-#else	/* !(IS_ENABLED(CONFIG_IPV6) */
-static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	return false;
-}
-
-static inline bool __rpc_copy_addr6(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	return false;
-}
-#endif	/* !(IS_ENABLED(CONFIG_IPV6) */
-
-/**
- * rpc_cmp_addr - compare the address portion of two sockaddrs.
- * @sap1: first sockaddr
- * @sap2: second sockaddr
- *
- * Just compares the family and address portion. Ignores port, but
- * compares the scope if it's a link-local address.
- *
- * Returns true if the addrs are equal, false if they aren't.
- */
-static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
-				const struct sockaddr *sap2)
-{
-	if (sap1->sa_family == sap2->sa_family) {
-		switch (sap1->sa_family) {
-		case AF_INET:
-			return __rpc_cmp_addr4(sap1, sap2);
-		case AF_INET6:
-			return __rpc_cmp_addr6(sap1, sap2);
-		}
-	}
-	return false;
-}
-
-/**
- * rpc_copy_addr - copy the address portion of one sockaddr to another
- * @dst: destination sockaddr
- * @src: source sockaddr
- *
- * Just copies the address portion and family. Ignores port, scope, etc.
- * Caller is responsible for making certain that dst is large enough to hold
- * the address in src. Returns true if address family is supported. Returns
- * false otherwise.
- */
-static inline bool rpc_copy_addr(struct sockaddr *dst,
-				 const struct sockaddr *src)
-{
-	switch (src->sa_family) {
-	case AF_INET:
-		return __rpc_copy_addr4(dst, src);
-	case AF_INET6:
-		return __rpc_copy_addr6(dst, src);
-	}
-	return false;
-}
-
-/**
- * rpc_get_scope_id - return scopeid for a given sockaddr
- * @sa: sockaddr to get scopeid from
- *
- * Returns the value of the sin6_scope_id for AF_INET6 addrs, or 0 if
- * not an AF_INET6 address.
- */
-static inline u32 rpc_get_scope_id(const struct sockaddr *sa)
-{
-	if (sa->sa_family != AF_INET6)
-		return 0;
-
-	return ((struct sockaddr_in6 *) sa)->sin6_scope_id;
-}
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index d11418f..a622ad6 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -17,7 +17,8 @@
  */
 
 #include <net/ipv6.h>
-#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
+#include <linux/sunrpc/msg_prot.h>
 #include <linux/slab.h>
 #include <linux/export.h>
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 822f020..c8193ce 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -33,6 +33,7 @@
 #include <linux/rcupdate.h>
 
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/bc_xprt.h>
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 795a0f4..3df764d 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -26,6 +26,7 @@
 #include <net/ipv6.h>
 
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xprtsock.h>
 
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 002ddd9..5085804 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -6,6 +6,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/sunrpc/gss_api.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/err.h>
 #include <linux/seq_file.h>
 #include <linux/hash.h>
@@ -17,7 +18,6 @@
 #include <linux/user_namespace.h>
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
-#include <linux/sunrpc/clnt.h>
 
 #include "netns.h"
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index c9aa7a3..66591dc 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/seq_file.h>
+#include <linux/sunrpc/addr.h>
 
 #include "xprt_rdma.h"
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 68b0a81..bbc0915 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -33,6 +33,7 @@
 #include <linux/udp.h>
 #include <linux/tcp.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/xprtsock.h>
-- 
1.7.11.7

