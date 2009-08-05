From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/10] SUNRPC: Clean up RPCBIND_MAXUADDRLEN definitions
Date: Wed, 05 Aug 2009 15:39:58 -0400
Message-ID: <20090805193957.3359.33308.stgit@matisse.1015granger.net>
References: <20090805193709.3359.34559.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:42690
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751866AbZHETj7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 15:39:59 -0400
In-Reply-To: <20090805193709.3359.34559.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace the single-integer definition of RPCBIND_MAXUADDRLEN
with a definition that is based on previously defined address string
sizes, and document the way this maximum is calculated.  Also provide
a separate macro for the size of the port number extension.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/msg_prot.h |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 70df4f1..77e6248 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -189,7 +189,22 @@ typedef __be32	rpc_fraghdr;
  * Additionally, the two alternative forms specified in Section 2.2 of
  * [RFC2373] are also acceptable.
  */
-#define RPCBIND_MAXUADDRLEN	(56u)
+
+#include <linux/inet.h>
+
+/* Maximum size of the port number part of a universal address */
+#define RPCBIND_MAXUADDRPLEN	sizeof(".255.255")
+
+/* Maximum size of an IPv4 universal address */
+#define RPCBIND_MAXUADDR4LEN	\
+		(INET_ADDRSTRLEN + RPCBIND_MAXUADDRPLEN)
+
+/* Maximum size of an IPv6 universal address */
+#define RPCBIND_MAXUADDR6LEN	\
+		(INET6_ADDRSTRLEN + RPCBIND_MAXUADDRPLEN)
+
+/* Assume INET6_ADDRSTRLEN will always be larger than INET_ADDRSTRLEN... */
+#define RPCBIND_MAXUADDRLEN	RPCBIND_MAXUADDR6LEN
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_MSGPROT_H_ */

