From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/26] statd: IPv6 support in reserved port binding in
	smn_create_socket()
Date: Tue, 13 Oct 2009 10:56:36 -0400
Message-ID: <20091013145636.2424.35509.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:59093 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760051AbZJMO5a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:57:30 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEuVND006602
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:32 GMT
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9D1c5R3030276
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:57:25 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch updates the "bind to an arbitrary privileged port" arm of
smn_create_socket() so it can deal with IPv6 bind addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   33 +++++++++++++++++++++++++++++----
 1 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index cbf77c4..f58783d 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -194,6 +194,26 @@ out_close:
 	return -1;
 }
  
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
@@ -241,13 +261,18 @@ retry:
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

