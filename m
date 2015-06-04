Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521AbbFDQqR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:46:17 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 09/10] SUNRPC: add AF_VSOCK support to svc_xprt.c
Date: Thu,  4 Jun 2015 17:45:52 +0100
Message-Id: <1433436353-6761-10-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow creation of AF_VSOCK service xprts.  This is needed for the
"vsock-bc" backchannel.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h | 12 ++++++++++++
 net/sunrpc/svc_xprt.c           | 13 +++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 79f6f8f..f0cb5a8 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -8,6 +8,7 @@
 #define SUNRPC_SVC_XPRT_H
 
 #include <linux/sunrpc/svc.h>
+#include <linux/vm_sockets.h>
 
 struct module;
 
@@ -150,12 +151,15 @@ static inline unsigned short svc_addr_port(const struct sockaddr *sa)
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
@@ -168,6 +172,8 @@ static inline size_t svc_addr_len(const struct sockaddr *sa)
 		return sizeof(struct sockaddr_in);
 	case AF_INET6:
 		return sizeof(struct sockaddr_in6);
+	case AF_VSOCK:
+		return sizeof(struct sockaddr_vm);
 	}
 	BUG();
 }
@@ -187,6 +193,7 @@ static inline char *__svc_print_addr(const struct sockaddr *addr,
 {
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
 	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
+	const struct sockaddr_vm *svm = (const struct sockaddr_vm *)addr;
 
 	switch (addr->sa_family) {
 	case AF_INET:
@@ -200,6 +207,11 @@ static inline char *__svc_print_addr(const struct sockaddr *addr,
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
index 163ac45..9e011d1 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -188,6 +188,13 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		.sin6_port		= htons(port),
 	};
 #endif
+#if IS_ENABLED(CONFIG_VSOCKETS)
+	struct sockaddr_vm svm = {
+		.svm_family		= AF_VSOCK,
+		.svm_cid		= VMADDR_CID_ANY,
+		.svm_port		= VMADDR_PORT_ANY,
+	};
+#endif
 	struct sockaddr *sap;
 	size_t len;
 
@@ -202,6 +209,12 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		len = sizeof(sin6);
 		break;
 #endif
+#if IS_ENABLED(CONFIG_VSOCKETS)
+	case AF_VSOCK:
+		sap = (struct sockaddr *)&svm;
+		len = sizeof(svm);
+		break;
+#endif
 	default:
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
-- 
2.4.2

