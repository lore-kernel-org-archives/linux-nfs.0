Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbbFDQp6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:45:58 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 01/10] SUNRPC: add AF_VSOCK support to addr.h
Date: Thu,  4 Jun 2015 17:45:44 +0100
Message-Id: <1433436353-6761-2-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AF_VSOCK addresses are a Context ID (CID) and port number tuple.  The
CID is a unique address, similar to a IP address on a local subnet.

Extend the addr.h functions to handle AF_VSOCK addresses.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/sunrpc/addr.h |  6 +++++
 net/sunrpc/addr.c           | 57 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+)

diff --git a/include/linux/sunrpc/addr.h b/include/linux/sunrpc/addr.h
index 07d8e53..b6530de 100644
--- a/include/linux/sunrpc/addr.h
+++ b/include/linux/sunrpc/addr.h
@@ -10,6 +10,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/in6.h>
+#include <linux/vm_sockets.h>
 #include <net/ipv6.h>
 
 size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
@@ -26,6 +27,8 @@ static inline unsigned short rpc_get_port(const struct sockaddr *sap)
 		return ntohs(((struct sockaddr_in *)sap)->sin_port);
 	case AF_INET6:
 		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+	case AF_VSOCK:
+		return ((struct sockaddr_vm *)sap)->svm_port;
 	}
 	return 0;
 }
@@ -40,6 +43,9 @@ static inline void rpc_set_port(struct sockaddr *sap,
 	case AF_INET6:
 		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
 		break;
+	case AF_VSOCK:
+		((struct sockaddr_vm *)sap)->svm_port = port;
+		break;
 	}
 }
 
diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 2e0a6f9..fe6eb31 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -16,11 +16,14 @@
  * RFC 4291, Section 2.2 for details on IPv6 presentation formats.
  */
 
+ /* TODO register netid and uaddr with IANA? (See RFC 5665 5.1/5.2) */
+
 #include <net/ipv6.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/vm_sockets.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 
@@ -108,6 +111,26 @@ static size_t rpc_ntop6(const struct sockaddr *sap,
 
 #endif	/* !IS_ENABLED(CONFIG_IPV6) */
 
+#if IS_ENABLED(CONFIG_VSOCKETS)
+
+static size_t rpc_ntop_vsock(const struct sockaddr *sap,
+			     char *buf, const size_t buflen)
+{
+	const struct sockaddr_vm *svm = (struct sockaddr_vm *)sap;
+
+	return snprintf(buf, buflen, "%u", svm->svm_cid);
+}
+
+#else	/* !IS_ENABLED(CONFIG_VSOCKETS) */
+
+static size_t rpc_ntop_vsock(const struct sockaddr *sap,
+			     char *buf, const size_t buflen)
+{
+	return 0;
+}
+
+#endif	/* !IS_ENABLED(CONFIG_VSOCKETS) */
+
 static int rpc_ntop4(const struct sockaddr *sap,
 		     char *buf, const size_t buflen)
 {
@@ -132,6 +155,8 @@ size_t rpc_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
 		return rpc_ntop4(sap, buf, buflen);
 	case AF_INET6:
 		return rpc_ntop6(sap, buf, buflen);
+	case AF_VSOCK:
+		return rpc_ntop_vsock(sap, buf, buflen);
 	}
 
 	return 0;
@@ -229,6 +254,34 @@ static size_t rpc_pton6(struct net *net, const char *buf, const size_t buflen,
 }
 #endif
 
+#if IS_ENABLED(CONFIG_VSOCKETS)
+static size_t rpc_pton_vsock(const char *buf, const size_t buflen,
+			     struct sockaddr *sap, const size_t salen)
+{
+	const size_t prefix_len = strlen("vsock:");
+	struct sockaddr_vm *svm = (struct sockaddr_vm *)sap;
+	unsigned int cid;
+
+	if (strncmp(buf, "vsock:", prefix_len) != 0 ||
+	    salen < sizeof(struct sockaddr_vm))
+		return 0;
+
+	if (kstrtouint(buf + prefix_len, 10, &cid) != 0)
+		return 0;
+
+	memset(svm, 0, sizeof(struct sockaddr_vm));
+	svm->svm_family = AF_VSOCK;
+	svm->svm_cid = cid;
+	return sizeof(struct sockaddr_vm);
+}
+#else
+static size_t rpc_pton_vsock(const char *buf, const size_t buflen,
+			     struct sockaddr *sap, const size_t salen)
+{
+	return 0;
+}
+#endif
+
 /**
  * rpc_pton - Construct a sockaddr in @sap
  * @net: applicable network namespace
@@ -249,6 +302,10 @@ size_t rpc_pton(struct net *net, const char *buf, const size_t buflen,
 {
 	unsigned int i;
 
+	/* TODO is there a nicer way to distinguish vsock addresses? */
+	if (strncmp(buf, "vsock:", 6) == 0)
+		return rpc_pton_vsock(buf, buflen, sap, salen);
+
 	for (i = 0; i < buflen; i++)
 		if (buf[i] == ':')
 			return rpc_pton6(net, buf, buflen, sap, salen);
-- 
2.4.2

