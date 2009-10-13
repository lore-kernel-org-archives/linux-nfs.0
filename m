From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/26] statd: Use getaddrinfo(3) to generate bind address in
	smn_create_socket()
Date: Tue, 13 Oct 2009 10:56:46 -0400
Message-ID: <20091013145646.2424.6943.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43845 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760123AbZJMO5a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:57:30 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEumFY031391
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:50 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DDXlxv013370
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:57:49 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch updates the "bind to a user-specified port" arm of
smn_create_socket() so it can deal with IPv6 bind addresses.

A single getaddrinfo(3) call can convert a user-specified bind address
or hostname to a socket address, optionally plant a provided port
number, or whip up an appropriate wildcard address for use as the main
socket's bind address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   81 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 52 insertions(+), 29 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index f58783d..443fd46 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -59,7 +59,7 @@ static int		opt_debug = 0;
 static int		opt_update_state = 1;
 static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = 0;
-static uint16_t		opt_srcport = 0;
+static char *		opt_srcport = 0;
 
 static void		notify(const int sock);
 static int		notify_host(int, struct nsm_host *);
@@ -194,6 +194,40 @@ out_close:
 	return -1;
 }
  
+/*
+ * If admin specified a source address or srcport, then convert those
+ * to a sockaddr and return it.   Otherwise, return an ANYADDR address.
+ */
+static struct addrinfo *
+smn_bind_address(const char *srcaddr, char *srcport)
+{
+	struct addrinfo gai_hint = {
+		.ai_family	= nsm_family,
+ 		.ai_protocol	= IPPROTO_UDP,
+ 	};
+	struct addrinfo *gai_results;
+	int error;
+
+	if (srcaddr == NULL)
+		gai_hint.ai_flags |= AI_PASSIVE;
+	if (srcport == NULL)
+		srcport = "";
+ 
+	error = getaddrinfo(srcaddr, srcport, &gai_hint, &gai_results);
+	switch (error) {
+	case 0:
+		return gai_results;
+	case EAI_SYSTEM:
+		xlog(L_ERROR, "Failed to determine bind address: %m");
+		break;
+	default:
+		xlog(L_ERROR, "Failed to determine bind address: %s",
+				gai_strerror(error));
+	}
+
+	return NULL;
+}
+
 #ifdef HAVE_LIBTIRPC
 static int
 smn_bindresvport(int sock, struct sockaddr *sap)
@@ -221,62 +255,51 @@ smn_bindresvport(int sock, struct sockaddr *sap)
  * an error occurs.
  */
 static int
-smn_create_socket(const char *srcaddr, const uint16_t srcport)
+smn_create_socket(const char *srcaddr, char *srcport)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *local_addr = (struct sockaddr *)&address;
 	int sock, retry_cnt = 0;
+	struct addrinfo *ai;
 
 retry:
 	sock = smn_socket();
 	if (sock < 0)
 		return -1;
 
-	memset(&address, 0, sizeof(address));
-	local_addr->sa_family = AF_INET;	/* Default to IPv4 */
-
-	/* Bind source IP if provided on command line */
-	if (srcaddr) {
-		struct addrinfo *ai = smn_lookup(srcaddr);
-		if (!ai) {
-			xlog(L_ERROR,
-				"Not a valid hostname or address: \"%s\"",
-				srcaddr);
-			return -1;
-		}
-
-		/* We know it's IPv4 at this point */
-		memcpy(local_addr, ai->ai_addr, ai->ai_addrlen);
-
-		freeaddrinfo(ai);
-	}
+	ai = smn_bind_address(srcaddr, srcport);
+	if (!ai)
+		return -1;
 
 	/* Use source port if provided on the command line,
 	 * otherwise use bindresvport */
 	if (srcport) {
-		nfs_set_port(local_addr, srcport);
-		if (bind(sock, local_addr, sizeof(struct sockaddr_in)) < 0) {
+		if (bind(sock, ai->ai_addr, ai->ai_addrlen) < 0) {
 			xlog(L_ERROR, "Failed to bind RPC socket: %m");
-			return -1;
+			(void)close(sock);
+			sock = -1;
+			goto out;
 		}
 	} else {
 		struct servent *se;
 
-		if (smn_bindresvport(sock, local_addr) == -1) {
+		if (smn_bindresvport(sock, ai->ai_addr) == -1) {
 			xlog(L_ERROR, "bindresvport(3): %m");
 			(void)close(sock);
-			return -1;
+			sock = -1;
+			goto out;
 		}
 
 		/* try to avoid known ports */
-		se = getservbyport(nfs_get_port(local_addr), "udp");
+		se = getservbyport(nfs_get_port(ai->ai_addr), "udp");
 		if (se && retry_cnt < 100) {
 			retry_cnt++;
 			(void)close(sock);
+			freeaddrinfo(ai);
 			goto retry;
 		}
 	}
 
+out:
+	freeaddrinfo(ai);
 	return sock;
 }
 
@@ -308,7 +331,7 @@ main(int argc, char **argv)
 			opt_update_state = 0;
 			break;
 		case 'p':
-			opt_srcport = atoi(optarg);
+			opt_srcport = optarg;
 			break;
 		case 'v':
 			opt_srcaddr = optarg;

