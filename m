From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/24] sm-notify: Support creating a PF_INET6 socket in
	smn_create_socket()
Date: Thu, 14 Jan 2010 12:29:35 -0500
Message-ID: <20100114172935.26079.54006.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36021 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757393Ab0ANRbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:11 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Socket creation is unfortunately complicated by the need to handle the
case where sm-notify is built with IPv6 support, but the local system
has disabled it entirely at run-time (ie, socket(3) returns
EAFNOSUPPORT when we try to create an AF_INET6 socket).

The run-time address family setting is made available in the global
variable nsm_family.  This setting can control the family of the
socket's bind address and what kind of addresses we want returned by
smn_lookup().  Support for that is added in subsequent patches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   81 ++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 462ba79..0ba817a 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -49,6 +49,7 @@ struct nsm_host {
 
 static char		nsm_hostname[256];
 static int		nsm_state;
+static int		nsm_family = AF_INET;
 static int		opt_debug = 0;
 static _Bool		opt_update_state = true;
 static unsigned int	opt_max_retry = 15 * 60;
@@ -141,6 +142,79 @@ smn_get_host(const char *hostname,
 	return 1;
 }
 
+#ifdef IPV6_SUPPORTED
+static int smn_socket(void)
+{
+	int sock;
+
+	/*
+	 * Use an AF_INET socket if IPv6 is disabled on the
+	 * local system.
+	 */
+	sock = socket(AF_INET6, SOCK_DGRAM, 0);
+	if (sock == -1) {
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
+		xlog(L_ERROR, "fcntl(3) on RPC socket failed: %m");
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
+		socklen_t zerolen = (socklen_t)sizeof(zero);
+
+		if (setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
+					(char *)&zero, zerolen) == -1) {
+			xlog(L_ERROR, "setsockopt(3) on RPC socket failed: %m");
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
+	if (sock == -1) {
+		xlog(L_ERROR, "Failed to create RPC socket: %m");
+		return -1;
+	}
+
+	if (fcntl(sock, F_SETFL, O_NONBLOCK) == -1) {
+		xlog(L_ERROR, "fcntl(3) on RPC socket failed: %m");
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
@@ -155,12 +229,9 @@ smn_create_socket(const char *srcaddr, const uint16_t srcport)
 	int sock, retry_cnt = 0;
 
 retry:
-	sock = socket(AF_INET, SOCK_DGRAM, 0);
-	if (sock < 0) {
-		xlog(L_ERROR, "Failed to create RPC socket: %m");
+	sock = smn_socket();
+	if (sock == -1)
 		return -1;
-	}
-	fcntl(sock, F_SETFL, O_NONBLOCK);
 
 	memset(&address, 0, sizeof(address));
 	local_addr->sa_family = AF_INET;	/* Default to IPv4 */

