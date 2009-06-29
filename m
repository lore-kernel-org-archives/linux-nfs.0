From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/31] support: Set proper retransmit timeout for datagram
	transports
Date: Mon, 29 Jun 2009 13:36:13 -0400
Message-ID: <20090629173613.2076.27482.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:52351 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbZF2RiY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:38:24 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of setting the total timeout and the retransmit timeout to the
same value for datagram transports, use a 1 second retransmit timeout,
so we actually get a retransmit or two before failing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpc_socket.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index a2255c3..ac4e6d8 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -326,7 +326,9 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 					version, *timeout, &sock);
 #endif	/* !HAVE_LIBTIRPC */
 	if (client != NULL) {
-		CLNT_CONTROL(client, CLSET_RETRY_TIMEOUT, (char *)timeout);
+		struct timeval retry_timeout = { 1, 0 };
+		CLNT_CONTROL(client, CLSET_RETRY_TIMEOUT,
+						(char *)&retry_timeout);
 		CLNT_CONTROL(client, CLSET_FD_CLOSE, NULL);
 	} else
 		(void)close(sock);

