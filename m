From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] nfs-utils: Fix IPv6 support in support/nfs/rpc_socket.c
Date: Mon, 18 May 2009 12:13:03 -0400
Message-ID: <20090518161301.12029.41834.stgit@seurat.1015granger.net>
References: <20090518161224.12029.86761.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:18655 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758367AbZERQPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2009 12:15:17 -0400
In-Reply-To: <20090518161224.12029.86761.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the correct #ifdef variable to enable IPv6 support for privileged
RPC clients.  Without this fix, unmounting an IPv6 NFSv2/v3 server
fails.

Introduced by commit 8c94296bc84f3a204f2061c0391a1d2350e4f37e.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpc_socket.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 85e6064..cebf83d 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -132,7 +132,7 @@ static int nfs_bind(const int sock, const sa_family_t family)
 	return -1;
 }
 
-#ifdef IPV6_SUPPORT
+#ifdef IPV6_SUPPORTED
 
 /*
  * Bind a socket using an unused privileged source port.
@@ -153,18 +153,16 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
 
 	switch (family) {
 	case AF_INET:
-		return bindresvport_sa(sock, (struct sockaddr *)&sin,
-					(socklen_t)sizeof(sin));
+		return bindresvport_sa(sock, (struct sockaddr *)&sin);
 	case AF_INET6:
-		return bindresvport_sa(sock, (struct sockaddr *)&sin6,
-					(socklen_t)sizeof(sin6));
+		return bindresvport_sa(sock, (struct sockaddr *)&sin6);
 	}
 
 	errno = EAFNOSUPPORT;
 	return -1;
 }
 
-#else	/* !IPV6_SUPPORT */
+#else	/* !IPV6_SUPPORTED */
 
 /*
  * Bind a socket using an unused privileged source port.
@@ -182,7 +180,7 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
 	return bindresvport(sock, NULL);
 }
 
-#endif	/* !IPV6_SUPPORT */
+#endif	/* !IPV6_SUPPORTED */
 
 /*
  * Perform a non-blocking connect on the socket fd.

