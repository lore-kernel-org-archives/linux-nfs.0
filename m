Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751661AbdIMK1N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:13 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 03/14] nfs-utils: add AF_VSOCK support to sockaddr.h
Date: Wed, 13 Sep 2017 11:26:39 +0100
Message-Id: <20170913102650.10377-4-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/include/sockaddr.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
index 446b537..dfcc492 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -32,6 +32,8 @@
 #include <sys/socket.h>
 #include <netinet/in.h>
 
+#include "vsock.h"
+
 /*
  * This type is for defining buffers that contain network socket
  * addresses.
@@ -51,6 +53,7 @@ union nfs_sockaddr {
 	struct sockaddr		sa;
 	struct sockaddr_in	s4;
 	struct sockaddr_in6	s6;
+	struct sockaddr_vm	svm;
 };
 
 #if SIZEOF_SOCKLEN_T - 0 == 0
@@ -66,6 +69,8 @@ union nfs_sockaddr {
 #define SIZEOF_SOCKADDR_IN6	SIZEOF_SOCKADDR_UNKNOWN
 #endif	/* !IPV6_SUPPORTED */
 
+#define SIZEOF_SOCKADDR_VM	(socklen_t)sizeof(struct sockaddr_vm)
+
 /**
  * nfs_sockaddr_length - return the size in bytes of a socket address
  * @sap: pointer to socket address
@@ -81,6 +86,8 @@ nfs_sockaddr_length(const struct sockaddr *sap)
 		return SIZEOF_SOCKADDR_IN;
 	case AF_INET6:
 		return SIZEOF_SOCKADDR_IN6;
+	case AF_VSOCK:
+		return SIZEOF_SOCKADDR_VM;
 	}
 	return SIZEOF_SOCKADDR_UNKNOWN;
 }
@@ -218,6 +225,15 @@ compare_sockaddr6(__attribute__ ((unused)) const struct sockaddr *sa1,
 }
 #endif	/* !IPV6_SUPPORTED */
 
+static inline _Bool
+compare_sockaddr_vsock(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	const struct sockaddr_vm *svm1 = (const struct sockaddr_vm *)sa1;
+	const struct sockaddr_vm *svm2 = (const struct sockaddr_vm *)sa2;
+
+	return svm1->svm_cid == svm2->svm_cid;
+}
+
 /**
  * nfs_compare_sockaddr - compare two socket addresses for equality
  * @sa1: pointer to a socket address
@@ -238,6 +254,8 @@ nfs_compare_sockaddr(const struct sockaddr *sa1, const struct sockaddr *sa2)
 			return compare_sockaddr4(sa1, sa2);
 		case AF_INET6:
 			return compare_sockaddr6(sa1, sa2);
+		case AF_VSOCK:
+			return compare_sockaddr_vsock(sa1, sa2);
 		}
 
 	return false;
-- 
2.13.5

