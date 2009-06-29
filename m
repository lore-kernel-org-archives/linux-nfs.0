From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/31] support: Use HAVE_LIBTIRPC to switch in
	bindresvport_sa(3t)
Date: Mon, 29 Jun 2009 13:35:54 -0400
Message-ID: <20090629173554.2076.60138.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:37156 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758589AbZF2RgQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:36:16 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 383a026d99624c88c0e802103ef4c4865db8eb71, which fixed an
earlier commit, is still not quite correct.

bindresvport_sa(3t) is available whenever libtirpc is linked.
There's no need to use IPV6_SUPPORTED here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpc_socket.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index cebf83d..2f76542 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -132,7 +132,7 @@ static int nfs_bind(const int sock, const sa_family_t family)
 	return -1;
 }
 
-#ifdef IPV6_SUPPORTED
+#ifdef HAVE_LIBTIRPC
 
 /*
  * Bind a socket using an unused privileged source port.
@@ -162,7 +162,7 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
 	return -1;
 }
 
-#else	/* !IPV6_SUPPORTED */
+#else	/* !HAVE_LIBTIRPC */
 
 /*
  * Bind a socket using an unused privileged source port.
@@ -180,7 +180,7 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
 	return bindresvport(sock, NULL);
 }
 
-#endif	/* !IPV6_SUPPORTED */
+#endif	/* !HAVE_LIBTIRPC */
 
 /*
  * Perform a non-blocking connect on the socket fd.

