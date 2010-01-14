From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/24] sm-notify: IPv6 support in reserved port binding in
	smn_create_socket()
Date: Thu, 14 Jan 2010 12:29:44 -0500
Message-ID: <20100114172944.26079.34662.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43325 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757388Ab0ANRbH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:07 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch updates the "bind to an arbitrary privileged port" arm of
smn_create_socket() so it can deal with IPv6 bind addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 0ba817a..928d1c5 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -215,6 +215,26 @@ static int smn_socket(void)
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
+	return bindresvport(sock, (struct sockaddr_in *)(char *)sap);
+}
+#endif	/* !HAVE_LIBTIRPC */
+
 /*
  * Prepare a socket for sending RPC requests
  *
@@ -265,7 +285,14 @@ retry:
 	} else {
 		struct servent *se;
 		struct sockaddr_in *sin = (struct sockaddr_in *)local_addr;
-		(void) bindresvport(sock, sin);
+
+		if (smn_bindresvport(sock, local_addr) == -1) {
+			xlog(L_ERROR,
+				"bindresvport on RPC socket failed: %m");
+			(void)close(sock);
+			return -1;
+		}
+
 		/* try to avoid known ports */
 		se = getservbyport(sin->sin_port, "udp");
 		if (se && retry_cnt < 100) {

