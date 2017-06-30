Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751936AbdF3NY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:27 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
Date: Fri, 30 Jun 2017 14:23:46 +0100
Message-Id: <20170630132352.32133-9-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow creation of AF_VSOCK service xprts.  This is needed for the
"vsock-bc" backchannel.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h | 12 ++++++++++++
 net/sunrpc/svc_xprt.c           | 18 ++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index ddb7f94..938f9ee 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -8,6 +8,7 @@
 #define SUNRPC_SVC_XPRT_H
 
 #include <linux/sunrpc/svc.h>
+#include <linux/vm_sockets.h>
 
 struct module;
 
@@ -156,12 +157,15 @@ static inline unsigned short svc_addr_port(const struct sockaddr *sa)
 {
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sa;
 	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sa;
+	const struct sockaddr_vm *svm = (const struct sockaddr_vm *)sa;
 
 	switch (sa->sa_family) {
 	case AF_INET:
 		return ntohs(sin->sin_port);
 	case AF_INET6:
 		return ntohs(sin6->sin6_port);
+	case AF_VSOCK:
+		return svm->svm_port;
 	}
 
 	return 0;
@@ -174,6 +178,8 @@ static inline size_t svc_addr_len(const struct sockaddr *sa)
 		return sizeof(struct sockaddr_in);
 	case AF_INET6:
 		return sizeof(struct sockaddr_in6);
+	case AF_VSOCK:
+		return sizeof(struct sockaddr_vm);
 	}
 	BUG();
 }
@@ -193,6 +199,7 @@ static inline char *__svc_print_addr(const struct sockaddr *addr,
 {
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
 	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
+	const struct sockaddr_vm *svm = (const struct sockaddr_vm *)addr;
 
 	switch (addr->sa_family) {
 	case AF_INET:
@@ -206,6 +213,11 @@ static inline char *__svc_print_addr(const struct sockaddr *addr,
 			ntohs(sin6->sin6_port));
 		break;
 
+	case AF_VSOCK:
+		snprintf(buf, len, "%u, port=%u",
+			 svm->svm_cid, svm->svm_port);
+		break;
+
 	default:
 		snprintf(buf, len, "unknown address type: %d", addr->sa_family);
 		break;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 7bfe1fb..2a8ccc1 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -10,6 +10,7 @@
 #include <linux/kthread.h>
 #include <linux/slab.h>
 #include <net/sock.h>
+#include <net/af_vsock.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc_xprt.h>
@@ -195,6 +196,13 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		.sin6_port		= htons(port),
 	};
 #endif
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	struct sockaddr_vm svm = {
+		.svm_family		= AF_VSOCK,
+		.svm_cid		= VMADDR_CID_ANY,
+		.svm_port		= port,
+	};
+#endif
 	struct sockaddr *sap;
 	size_t len;
 
@@ -209,6 +217,12 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		len = sizeof(sin6);
 		break;
 #endif
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	case AF_VSOCK:
+		sap = (struct sockaddr *)&svm;
+		len = sizeof(svm);
+		break;
+#endif
 	default:
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
@@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *sin)
 	case AF_INET6:
 		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
 			< PROT_SOCK;
+	case AF_VSOCK:
+		return ((struct sockaddr_vm *)sin)->svm_port <=
+			LAST_RESERVED_PORT;
+
 	default:
 		return 0;
 	}
-- 
2.9.4

