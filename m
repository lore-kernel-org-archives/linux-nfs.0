From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/29] statd: IPv6 support in reserved port binding in
	smn_create_socket()
Date: Tue, 10 Nov 2009 16:58:34 -0500
Message-ID: <20091110215833.23822.97389.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50200 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758446AbZKJV7H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:59:07 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch updates the "bind to an arbitrary privileged port" arm of
smn_create_socket() so it can deal with IPv6 bind addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   33 +++++++++++++++++++++++++++++----
 1 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 15f68fc..0069a99 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -218,6 +218,26 @@ static int smn_socket(void)
 }
 #endif	/* !IPV6_SUPPORTED */
  
+#ifdef HAVE_LIBTIRPC
+static int
+smn_bindresvport(int sock, struct sockaddr *sap)
+{
+	return bindresvport_sa(sock, sap);
+}
+
+#else	/* !HAVE_LIBTIRPC */
+static int
+smn_bindresvport(int sock, struct sockaddr *sap)
+{
+	if (sap->sa_family != AF_INET) {
+		errno = EAFNOSUPPORT;
+		return -1;
+	}
+
+	return bindresvport(sock, (struct sockaddr_in *)sap);
+}
+#endif	/* !HAVE_LIBTIRPC */
+
 /*
  * Prepare a socket for sending RPC requests
  *
@@ -265,13 +285,18 @@ retry:
 		}
 	} else {
 		struct servent *se;
-		struct sockaddr_in *sin = (struct sockaddr_in *)local_addr;
-		(void) bindresvport(sock, sin);
+
+		if (smn_bindresvport(sock, local_addr) == -1) {
+			xlog(L_ERROR, "bindresvport(3): %m");
+			(void)close(sock);
+			return -1;
+		}
+
 		/* try to avoid known ports */
-		se = getservbyport(sin->sin_port, "udp");
+		se = getservbyport(nfs_get_port(local_addr), "udp");
 		if (se && retry_cnt < 100) {
 			retry_cnt++;
-			close(sock);
+			(void)close(sock);
 			goto retry;
 		}
 	}

