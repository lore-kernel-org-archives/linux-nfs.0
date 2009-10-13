From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/26] statd: Support creating a PF_INET6 socket in
	smn_create_socket()
Date: Tue, 13 Oct 2009 10:56:26 -0400
Message-ID: <20091013145626.2424.74062.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:44161 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760130AbZJMO5j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:57:39 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEuvcf031891
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:58 GMT
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEfZTt015953
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:53 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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

 utils/statd/sm-notify.c |   67 +++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index c57dd6c..cbf77c4 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -54,6 +54,7 @@ struct nsm_host {
 
 static char		nsm_hostname[256];
 static uint32_t		nsm_state;
+static int		nsm_family = AF_INET;
 static int		opt_debug = 0;
 static int		opt_update_state = 1;
 static unsigned int	opt_max_retry = 15 * 60;
@@ -134,6 +135,65 @@ static void smn_forget_host(struct nsm_host *host)
 	free(host);
 }
 
+static int smn_socket(void)
+{
+	int sock;
+
+	/*
+	 * We have to use an AF_INET socket here if IPV6_SUPPORTED
+	 * is enabled at build time, but the end user's system has
+	 * disabled all IPv6 support at run time.
+	 */
+#ifdef IPV6_SUPPORTED
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
+#else	/* !IPV6_SUPPORTED */
+	sock = socket(AF_INET, SOCK_DGRAM, 0);
+	if (sock < 0) {
+		xlog(L_ERROR, "Failed to create RPC socket: %m");
+		return -1;
+	}
+#endif	/* !IPV6_SUPPORTED */
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
+ 
 /*
  * Prepare a socket for sending RPC requests
  *
@@ -148,12 +208,9 @@ smn_create_socket(const char *srcaddr, const uint16_t srcport)
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

