From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/24] sm-notify: Use getaddrinfo(3) to create bind address in
	smn_create_socket()
Date: Thu, 14 Jan 2010 12:29:52 -0500
Message-ID: <20100114172952.26079.49742.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:43064 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757342Ab0ANRa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:30:57 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

 utils/statd/sm-notify.c |   82 +++++++++++++++++++++++++++++------------------
 1 files changed, 51 insertions(+), 31 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 928d1c5..259db09 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -53,8 +53,8 @@ static int		nsm_family = AF_INET;
 static int		opt_debug = 0;
 static _Bool		opt_update_state = true;
 static unsigned int	opt_max_retry = 15 * 60;
-static char *		opt_srcaddr = 0;
-static uint16_t		opt_srcport = 0;
+static char *		opt_srcaddr = NULL;
+static char *		opt_srcport = NULL;
 
 static void		notify(const int sock);
 static int		notify_host(int, struct nsm_host *);
@@ -215,6 +215,39 @@ static int smn_socket(void)
 }
 #endif	/* !IPV6_SUPPORTED */
 
+/*
+ * If admin specified a source address or srcport, then convert those
+ * to a sockaddr and return it.   Otherwise, return an ANYADDR address.
+ */
+__attribute_malloc__
+static struct addrinfo *
+smn_bind_address(const char *srcaddr, const char *srcport)
+{
+	struct addrinfo *ai = NULL;
+	struct addrinfo hint = {
+		.ai_flags	= AI_NUMERICSERV,
+		.ai_family	= nsm_family,
+		.ai_protocol	= (int)IPPROTO_UDP,
+	};
+	int error;
+
+	if (srcaddr == NULL)
+		hint.ai_flags |= AI_PASSIVE;
+
+	if (srcport == NULL)
+		error = getaddrinfo(srcaddr, "", &hint, &ai);
+	else
+		error = getaddrinfo(srcaddr, srcport, &hint, &ai);
+	if (error != 0) {
+		xlog(L_ERROR,
+			"Invalid bind address or port for RPC socket: %s",
+				gai_strerror(error));
+		return NULL;
+	}
+
+	return ai;
+}
+
 #ifdef HAVE_LIBTIRPC
 static int
 smn_bindresvport(int sock, struct sockaddr *sap)
@@ -242,66 +275,53 @@ smn_bindresvport(int sock, struct sockaddr *sap)
  * an error occurs.
  */
 static int
-smn_create_socket(const char *srcaddr, const uint16_t srcport)
+smn_create_socket(const char *srcaddr, const char *srcport)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *local_addr = (struct sockaddr *)&address;
 	int sock, retry_cnt = 0;
+	struct addrinfo *ai;
 
 retry:
 	sock = smn_socket();
 	if (sock == -1)
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
-			(void)close(sock);
-			return -1;
-		}
-
-		/* We know it's IPv4 at this point */
-		memcpy(local_addr, ai->ai_addr, ai->ai_addrlen);
-
-		freeaddrinfo(ai);
+	ai = smn_bind_address(srcaddr, srcport);
+	if (ai == NULL) {
+		(void)close(sock);
+		return -1;
 	}
 
 	/* Use source port if provided on the command line,
 	 * otherwise use bindresvport */
 	if (srcport) {
-		nfs_set_port(local_addr, srcport);
-		if (bind(sock, local_addr, sizeof(struct sockaddr_in)) < 0) {
+		if (bind(sock, ai->ai_addr, ai->ai_addrlen) == -1) {
 			xlog(L_ERROR, "Failed to bind RPC socket: %m");
+			freeaddrinfo(ai);
 			(void)close(sock);
 			return -1;
 		}
 	} else {
 		struct servent *se;
-		struct sockaddr_in *sin = (struct sockaddr_in *)local_addr;
 
-		if (smn_bindresvport(sock, local_addr) == -1) {
+		if (smn_bindresvport(sock, ai->ai_addr) == -1) {
 			xlog(L_ERROR,
 				"bindresvport on RPC socket failed: %m");
+			freeaddrinfo(ai);
 			(void)close(sock);
 			return -1;
 		}
 
 		/* try to avoid known ports */
-		se = getservbyport(sin->sin_port, "udp");
-		if (se && retry_cnt < 100) {
+		se = getservbyport((int)nfs_get_port(ai->ai_addr), "udp");
+		if (se != NULL && retry_cnt < 100) {
 			retry_cnt++;
-			close(sock);
+			freeaddrinfo(ai);
+			(void)close(sock);
 			goto retry;
 		}
 	}
 
+	freeaddrinfo(ai);
 	return sock;
 }
 
@@ -332,7 +352,7 @@ main(int argc, char **argv)
 			opt_update_state = false;
 			break;
 		case 'p':
-			opt_srcport = atoi(optarg);
+			opt_srcport = optarg;
 			break;
 		case 'v':
 			opt_srcaddr = optarg;

