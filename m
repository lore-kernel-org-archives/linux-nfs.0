From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/29] statd: Support creating a PF_INET6 socket in
	smn_create_socket()
Date: Tue, 10 Nov 2009 16:58:25 -0500
Message-ID: <20091110215824.23822.34617.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51283 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbZKJV6z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:58:55 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Socket creation is unfortunately complicated by the need to handle the
case where sm-notify is built with IPv6 support, but the local system
has disabled it entirely at run-time (ie, socket(3) returns
EAFNOSUPPORT when we try to create an AF_INET6 socket).

The run-time address family setting is made available in the global
variable nsm_family.  This setting can control the family of the
socket's bind address and what kind of addresses we want returned by
smn_lookup().  This support is added in subsequent patches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   80 ++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 75 insertions(+), 5 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index b80d90d..15f68fc 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -54,6 +54,7 @@ struct nsm_host {
 
 static char		nsm_hostname[256];
 static uint32_t		nsm_state;
+static int		nsm_family = AF_INET;
 static int		opt_debug = 0;
 static int		opt_update_state = 1;
 static unsigned int	opt_max_retry = 15 * 60;
@@ -145,6 +146,78 @@ smn_get_host(const char *hostname,
 	return 1;
 }
 
+#ifdef IPV6_SUPPORTED
+static int smn_socket(void)
+{
+	int sock;
+
+	/*
+	 * We have to use an AF_INET socket here if IPV6_SUPPORTED
+	 * is enabled at build time, but the end user's system has
+	 * disabled all IPv6 support at run time.
+	 */
+	sock = socket(AF_INET6, SOCK_DGRAM, 0);
+	if (sock < 0) {
+		if (errno != EAFNOSUPPORT) {
+			xlog(L_ERROR, "Failed to create RPC socket: %m");
+			return -1;
+		}
+		sock = socket(AF_INET, SOCK_DGRAM, 0);
+		if (sock < 0) {
+			xlog(L_ERROR, "Failed to create RPC socket: %m");
+			return -1;
+		}
+	} else
+		nsm_family = AF_INET6;
+
+	if (fcntl(sock, F_SETFL, O_NONBLOCK) == -1) {
+		xlog(L_ERROR, "fcntl(3) on network socket failed: %m");
+		goto out_close;
+	}
+
+	/*
+	 * TI-RPC over IPv6 (udp6/tcp6) does not handle IPv4.  However,
+	 * since sm-notify open-codes all of its RPC support, it can
+	 * use a single socket and let the local network stack provide
+	 * the correct mapping between address families automatically.
+	 * This is the same thing that is done in the kernel.
+	 */
+	if (nsm_family == AF_INET6) {
+		const int zero = 0;
+		if (setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
+				(char *)&zero, sizeof(zero)) == -1) {
+			xlog(L_ERROR, "setsockopt(3) on network socket failed: %m");
+			goto out_close;
+		}
+	}
+
+	return sock;
+
+out_close:
+	(void)close(sock);
+	return -1;
+}
+#else	/* !IPV6_SUPPORTED */
+static int smn_socket(void)
+{
+	int sock;
+
+	sock = socket(AF_INET, SOCK_DGRAM, 0);
+	if (sock < 0) {
+		xlog(L_ERROR, "Failed to create RPC socket: %m");
+		return -1;
+	}
+
+	if (fcntl(sock, F_SETFL, O_NONBLOCK) == -1) {
+		xlog(L_ERROR, "fcntl(3) on network socket failed: %m");
+		(void)close(sock);
+		return -1;
+	}
+
+	return sock;
+}
+#endif	/* !IPV6_SUPPORTED */
+ 
 /*
  * Prepare a socket for sending RPC requests
  *
@@ -159,12 +232,9 @@ smn_create_socket(const char *srcaddr, const uint16_t srcport)
 	int sock, retry_cnt = 0;
 
 retry:
-	sock = socket(AF_INET, SOCK_DGRAM, 0);
-	if (sock < 0) {
-		xlog(L_ERROR, "Failed to create RPC socket: %m");
+	sock = smn_socket();
+	if (sock < 0)
 		return -1;
-	}
-	fcntl(sock, F_SETFL, O_NONBLOCK);
 
 	memset(&address, 0, sizeof(address));
 	local_addr->sa_family = AF_INET;	/* Default to IPv4 */

