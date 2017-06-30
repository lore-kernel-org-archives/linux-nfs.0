Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52458 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3NVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:30 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 02/12] nfs-utils: add AF_VSOCK support to sockaddr.h
Date: Fri, 30 Jun 2017 14:21:10 +0100
Message-Id: <20170630132120.31578-3-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/include/sockaddr.h | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
index 446b537..0577859 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -31,6 +31,9 @@
 #include <stdbool.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
+#ifdef AF_VSOCK
+#include <linux/vm_sockets.h>
+#endif
 
 /*
  * This type is for defining buffers that contain network socket
@@ -51,6 +54,9 @@ union nfs_sockaddr {
 	struct sockaddr		sa;
 	struct sockaddr_in	s4;
 	struct sockaddr_in6	s6;
+#ifdef AF_VSOCK
+	struct sockaddr_vm	svm;
+#endif
 };
 
 #if SIZEOF_SOCKLEN_T - 0 == 0
@@ -66,6 +72,10 @@ union nfs_sockaddr {
 #define SIZEOF_SOCKADDR_IN6	SIZEOF_SOCKADDR_UNKNOWN
 #endif	/* !IPV6_SUPPORTED */
 
+#ifdef AF_VSOCK
+#define SIZEOF_SOCKADDR_VM	(socklen_t)sizeof(struct sockaddr_vm)
+#endif
+
 /**
  * nfs_sockaddr_length - return the size in bytes of a socket address
  * @sap: pointer to socket address
@@ -81,6 +91,10 @@ nfs_sockaddr_length(const struct sockaddr *sap)
 		return SIZEOF_SOCKADDR_IN;
 	case AF_INET6:
 		return SIZEOF_SOCKADDR_IN6;
+#ifdef AF_VSOCK
+	case AF_VSOCK:
+		return SIZEOF_SOCKADDR_VM;
+#endif /* !AF_VSOCK */
 	}
 	return SIZEOF_SOCKADDR_UNKNOWN;
 }
@@ -218,6 +232,17 @@ compare_sockaddr6(__attribute__ ((unused)) const struct sockaddr *sa1,
 }
 #endif	/* !IPV6_SUPPORTED */
 
+#ifdef AF_VSOCK
+static inline _Bool
+compare_sockaddr_vsock(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	const struct sockaddr_vm *svm1 = (const struct sockaddr_vm *)sa1;
+	const struct sockaddr_vm *svm2 = (const struct sockaddr_vm *)sa2;
+
+	return svm1->svm_cid == svm2->svm_cid;
+}
+#endif
+
 /**
  * nfs_compare_sockaddr - compare two socket addresses for equality
  * @sa1: pointer to a socket address
@@ -238,6 +263,10 @@ nfs_compare_sockaddr(const struct sockaddr *sa1, const struct sockaddr *sa2)
 			return compare_sockaddr4(sa1, sa2);
 		case AF_INET6:
 			return compare_sockaddr6(sa1, sa2);
+#ifdef AF_VSOCK
+		case AF_VSOCK:
+			return compare_sockaddr_vsock(sa1, sa2);
+#endif
 		}
 
 	return false;
-- 
2.9.4

