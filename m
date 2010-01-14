From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/24] nfs-utils: Collect socket address helpers into one
	location
Date: Thu, 14 Jan 2010 12:30:10 -0500
Message-ID: <20100114173010.26079.97168.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32039 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757392Ab0ANRbK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:10 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce generic helpers for managing socket addresses.  These are
general enough that they are useful for pretty much any component of
nfs-utils.

We also include the definition of nfs_sockaddr here, so it can be
shared.  See:

  https://bugzilla.redhat.com/show_bug.cgi?id=448743

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h   |   12 --
 support/include/sockaddr.h |  237 ++++++++++++++++++++++++++++++++++++++++++++
 support/nfs/getport.c      |   21 ++--
 support/nfs/rpc_socket.c   |   55 +---------
 utils/mount/network.c      |   13 +-
 utils/mount/stropts.c      |    7 -
 utils/statd/sm-notify.c    |    1 
 7 files changed, 264 insertions(+), 82 deletions(-)
 create mode 100644 support/include/sockaddr.h

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index d6d4a1c..4db35ab 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -59,16 +59,6 @@ static inline void nfs_clear_rpc_createerr(void)
 }
 
 /*
- * Extract port value from a socket address
- */
-extern uint16_t		nfs_get_port(const struct sockaddr *);
-
-/*
- * Set port value in a socket address
- */
-extern void		nfs_set_port(struct sockaddr *, const uint16_t);
-
-/*
  * Look up an RPC program name in /etc/rpc
  */
 extern rpcprog_t	nfs_getrpcbyname(const rpcprog_t, const char *table[]);
@@ -170,4 +160,4 @@ extern int		nfs_rpc_ping(const struct sockaddr *sap,
 				const unsigned short protocol,
 				const struct timeval *timeout);
 
-#endif	/* __NFS_UTILS_NFSRPC_H */
+#endif	/* !__NFS_UTILS_NFSRPC_H */
diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
new file mode 100644
index 0000000..732514b
--- /dev/null
+++ b/support/include/sockaddr.h
@@ -0,0 +1,237 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef NFS_UTILS_SOCKADDR_H
+#define NFS_UTILS_SOCKADDR_H
+
+#include <stdbool.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+
+/*
+ * This type is for defining buffers that contain network socket
+ * addresses.
+ *
+ * Casting a "struct sockaddr *" to the address of a "struct
+ * sockaddr_storage" breaks C aliasing rules.  The "union
+ * nfs_sockaddr" type follows C aliasing rules yet specifically
+ * allows converting pointers to it between "struct sockaddr *"
+ * and a few other network sockaddr-related pointer types.
+ *
+ * Note that this union is much smaller than a sockaddr_storage.
+ * It should be used only for AF_INET or AF_INET6 socket addresses.
+ * An AF_LOCAL sockaddr_un, for example, will clearly not fit into
+ * a buffer of this type.
+ */
+union nfs_sockaddr {
+	struct sockaddr		sa;
+	struct sockaddr_in	s4;
+	struct sockaddr_in6	s6;
+};
+
+#if SIZEOF_SOCKLEN_T - 0 == 0
+#define socklen_t unsigned int
+#endif
+
+#define SIZEOF_SOCKADDR_UNKNOWN	(socklen_t)0
+#define SIZEOF_SOCKADDR_IN	(socklen_t)sizeof(struct sockaddr_in)
+
+#ifdef IPV6_SUPPORTED
+#define SIZEOF_SOCKADDR_IN6	(socklen_t)sizeof(struct sockaddr_in6)
+#else	/* !IPV6_SUPPORTED */
+#define SIZEOF_SOCKADDR_IN6	SIZEOF_SOCKADDR_UNKNOWN
+#endif	/* !IPV6_SUPPORTED */
+
+/**
+ * nfs_sockaddr_length - return the size in bytes of a socket address
+ * @sap: pointer to socket address
+ *
+ * Returns the size in bytes of @sap, or zero if the family is
+ * not recognized.
+ */
+static inline socklen_t
+nfs_sockaddr_length(const struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		return SIZEOF_SOCKADDR_IN;
+	case AF_INET6:
+		return SIZEOF_SOCKADDR_IN6;
+	}
+	return SIZEOF_SOCKADDR_UNKNOWN;
+}
+
+static inline uint16_t
+get_port4(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	return ntohs(sin->sin_port);
+}
+
+#ifdef IPV6_SUPPORTED
+static inline uint16_t
+get_port6(const struct sockaddr *sap)
+{
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
+	return ntohs(sin6->sin6_port);
+}
+#else	/* !IPV6_SUPPORTED */
+static inline uint16_t
+get_port6(__attribute__ ((unused)) const struct sockaddr *sap)
+{
+	return 0;
+}
+#endif	/* !IPV6_SUPPORTED */
+
+/**
+ * nfs_get_port - extract port value from a socket address
+ * @sap: pointer to socket address
+ *
+ * Returns port value in host byte order, or zero if the
+ * socket address contains an unrecognized family.
+ */
+static inline uint16_t
+nfs_get_port(const struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		return get_port4(sap);
+	case AF_INET6:
+		return get_port6(sap);
+	}
+	return 0;
+}
+
+static inline void
+set_port4(struct sockaddr *sap, const uint16_t port)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	sin->sin_port = htons(port);
+}
+
+#ifdef IPV6_SUPPORTED
+static inline void
+set_port6(struct sockaddr *sap, const uint16_t port)
+{
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	sin6->sin6_port = htons(port);
+}
+#else	/* !IPV6_SUPPORTED */
+static inline void
+set_port6(__attribute__ ((unused)) struct sockaddr *sap,
+		__attribute__ ((unused)) const uint16_t port)
+{
+}
+#endif	/* !IPV6_SUPPORTED */
+
+/**
+ * nfs_set_port - set port value in a socket address
+ * @sap: pointer to socket address
+ * @port: port value to set
+ *
+ */
+static inline void
+nfs_set_port(struct sockaddr *sap, const uint16_t port)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		set_port4(sap, port);
+		break;
+	case AF_INET6:
+		set_port6(sap, port);
+		break;
+	}
+}
+
+/**
+ * nfs_is_v4_loopback - test to see if socket address is AF_INET loopback
+ * @sap: pointer to socket address
+ *
+ * Returns true if the socket address is the standard IPv4 loopback
+ * address; otherwise false is returned.
+ */
+static inline _Bool
+nfs_is_v4_loopback(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+
+	if (sin->sin_family != AF_INET)
+		return false;
+	if (sin->sin_addr.s_addr != htonl(INADDR_LOOPBACK))
+		return false;
+        return true;
+}
+
+static inline _Bool
+compare_sockaddr4(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+}
+
+#ifdef IPV6_SUPPORTED
+static inline _Bool
+compare_sockaddr6(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
+
+	if ((IN6_IS_ADDR_LINKLOCAL((char *)&sin1->sin6_addr) &&
+	     IN6_IS_ADDR_LINKLOCAL((char *)&sin2->sin6_addr)) ||
+	    (IN6_IS_ADDR_SITELOCAL((char *)&sin1->sin6_addr) &&
+	     IN6_IS_ADDR_SITELOCAL((char *)&sin2->sin6_addr)))
+		if (sin1->sin6_scope_id != sin2->sin6_scope_id)
+			return false;
+
+	return IN6_ARE_ADDR_EQUAL((char *)&sin1->sin6_addr,
+					(char *)&sin2->sin6_addr);
+}
+#else	/* !IPV6_SUPPORTED */
+static inline _Bool
+compare_sockaddr6(__attribute__ ((unused)) const struct sockaddr *sa1,
+		__attribute__ ((unused)) const struct sockaddr *sa2)
+{
+	return false;
+}
+#endif	/* !IPV6_SUPPORTED */
+
+/**
+ * nfs_compare_sockaddr - compare two socket addresses for equality
+ * @sa1: pointer to a socket address
+ * @sa2: pointer to a socket address
+ *
+ * Returns true if the two socket addresses contain equivalent
+ * network addresses; otherwise false is returned.
+ */
+static inline _Bool
+nfs_compare_sockaddr(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	if (sa1->sa_family == sa2->sa_family)
+		switch (sa1->sa_family) {
+		case AF_INET:
+			return compare_sockaddr4(sa1, sa2);
+		case AF_INET6:
+			return compare_sockaddr6(sa1, sa2);
+		}
+
+	return false;
+}
+
+#endif	/* !NFS_UTILS_SOCKADDR_H */
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 7e0f798..c930539 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -45,6 +45,7 @@
 #include <rpc/rpcb_prot.h>
 #endif
 
+#include "sockaddr.h"
 #include "nfsrpc.h"
 
 /*
@@ -705,8 +706,8 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 		 const rpcprog_t program, const rpcvers_t version,
 		 const unsigned short protocol, const struct timeval *timeout)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *saddr = (struct sockaddr *)&address;
+	union nfs_sockaddr address;
+	struct sockaddr *saddr = &address.sa;
 	CLIENT *client;
 	struct timeval tout = { -1, 0 };
 	int result = 0;
@@ -774,8 +775,8 @@ unsigned short nfs_getport(const struct sockaddr *sap,
 			   const rpcvers_t version,
 			   const unsigned short protocol)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *saddr = (struct sockaddr *)&address;
+	union nfs_sockaddr address;
+	struct sockaddr *saddr = &address.sa;
 	struct timeval timeout = { -1, 0 };
 	unsigned short port = 0;
 	CLIENT *client;
@@ -833,8 +834,8 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 	}
 
 	if (port != 0) {
-		struct sockaddr_storage address;
-		struct sockaddr *saddr = (struct sockaddr *)&address;
+		union nfs_sockaddr address;
+		struct sockaddr *saddr = &address.sa;
 
 		memcpy(saddr, sap, (size_t)salen);
 		nfs_set_port(saddr, port);
@@ -885,8 +886,8 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 				const rpcvers_t version,
 				const unsigned short protocol)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *lb_addr = (struct sockaddr *)&address;
+	union nfs_sockaddr address;
+	struct sockaddr *lb_addr = &address.sa;
 	socklen_t lb_len = sizeof(*lb_addr);
 	unsigned short port = 0;
 
@@ -969,8 +970,8 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 				const unsigned short protocol,
 				const struct timeval *timeout)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *saddr = (struct sockaddr *)&address;
+	union nfs_sockaddr address;
+	struct sockaddr *saddr = &address.sa;
 	CLIENT *client;
 	struct rpcb parms;
 	struct timeval tout = { -1, 0 };
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 9c20f61..0e20824 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -26,6 +26,8 @@
 
 #include <sys/types.h>
 #include <sys/time.h>
+
+#include <stdbool.h>
 #include <unistd.h>
 #include <fcntl.h>
 #include <errno.h>
@@ -38,6 +40,7 @@
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
 
+#include "sockaddr.h"
 #include "nfsrpc.h"
 
 #ifdef HAVE_LIBTIRPC
@@ -51,6 +54,7 @@
 #define NFSRPC_TIMEOUT_UDP	(3)
 #define NFSRPC_TIMEOUT_TCP	(10)
 
+
 /*
  * Set up an RPC client for communicating via a AF_LOCAL socket.
  *
@@ -121,10 +125,10 @@ static int nfs_bind(const int sock, const sa_family_t family)
 
 	switch (family) {
 	case AF_INET:
-		return bind(sock, (struct sockaddr *)&sin,
+		return bind(sock, (struct sockaddr *)(char *)&sin,
 					(socklen_t)sizeof(sin));
 	case AF_INET6:
-		return bind(sock, (struct sockaddr *)&sin6,
+		return bind(sock, (struct sockaddr *)(char *)&sin6,
 					(socklen_t)sizeof(sin6));
 	}
 
@@ -153,9 +157,9 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
 
 	switch (family) {
 	case AF_INET:
-		return bindresvport_sa(sock, (struct sockaddr *)&sin);
+		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin);
 	case AF_INET6:
-		return bindresvport_sa(sock, (struct sockaddr *)&sin6);
+		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin6);
 	}
 
 	errno = EAFNOSUPPORT;
@@ -416,49 +420,6 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 }
 
 /**
- * nfs_get_port - extract port value from a socket address
- * @sap: pointer to socket address
- *
- * Returns port value in host byte order.
- */
-uint16_t
-nfs_get_port(const struct sockaddr *sap)
-{
-       const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
-       const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
-
-       switch (sap->sa_family) {
-       case AF_INET:
-               return ntohs(sin->sin_port);
-       case AF_INET6:
-               return ntohs(sin6->sin6_port);
-       }
-       return 0;
-}
-
-/**
- * nfs_set_port - set port value in a socket address
- * @sap: pointer to socket address
- * @port: port value to set
- *
- */
-void
-nfs_set_port(struct sockaddr *sap, const uint16_t port)
-{
-       struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-       struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-
-       switch (sap->sa_family) {
-       case AF_INET:
-               sin->sin_port = htons(port);
-               break;
-       case AF_INET6:
-               sin6->sin6_port = htons(port);
-               break;
-       }
-}
-
-/**
  * nfs_get_rpcclient - acquire an RPC client
  * @sap: pointer to socket address of RPC server
  * @salen: length of socket address
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 906e20c..92bba2d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -42,6 +42,7 @@
 #include <rpc/pmap_prot.h>
 #include <rpc/pmap_clnt.h>
 
+#include "sockaddr.h"
 #include "xcommon.h"
 #include "mount.h"
 #include "nls.h"
@@ -56,10 +57,6 @@
 #define CONNECT_TIMEOUT	(20)
 #define MOUNT_TIMEOUT	(30)
 
-#if SIZEOF_SOCKLEN_T - 0 == 0
-#define socklen_t unsigned int
-#endif
-
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -540,8 +537,8 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 			  struct pmap *pmap, const unsigned long *versions,
 			  const unsigned int *protos)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *saddr = (struct sockaddr *)&address;
+	union nfs_sockaddr address;
+	struct sockaddr *saddr = &address.sa;
 	const unsigned long prog = pmap->pm_prog, *p_vers;
 	const unsigned int prot = (u_int)pmap->pm_prot, *p_prot;
 	const u_short port = (u_short) pmap->pm_port;
@@ -831,8 +828,8 @@ int start_statd(void)
 int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 		      const struct pmap *pmap, const dirpath *argp)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *saddr = (struct sockaddr *)&address;
+	union nfs_sockaddr address;
+	struct sockaddr *saddr = &address.sa;
 	struct pmap mnt_pmap = *pmap;
 	struct timeval timeout = {
 		.tv_sec		= MOUNT_TIMEOUT >> 3,
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 8e7e8a5..74224ff 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -35,6 +35,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 
+#include "sockaddr.h"
 #include "xcommon.h"
 #include "mount.h"
 #include "nls.h"
@@ -77,12 +78,6 @@ extern char *progname;
 extern int verbose;
 extern int sloppy;
 
-union nfs_sockaddr {
-	struct sockaddr		sa;
-	struct sockaddr_in	s4;
-	struct sockaddr_in6	s6;
-};
-
 struct nfsmount_info {
 	const char		*spec,		/* server:/path */
 				*node,		/* mounted-on dir */
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 8d90d1f..66a52eb 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -29,6 +29,7 @@
 #include <errno.h>
 #include <grp.h>
 
+#include "sockaddr.h"
 #include "xlog.h"
 #include "nsm.h"
 #include "nfsrpc.h"

