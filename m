From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/26] statd: factor socket creation out of notify()
Date: Tue, 13 Oct 2009 10:56:16 -0400
Message-ID: <20091013145616.2424.50011.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43810 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760113AbZJMO53 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:57:29 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEulGV031330
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:49 GMT
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9D4Elro001169
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:57:24 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first half of notify() creates the main socket that sm-notify uses
to do its job.  To make adding IPv6 support simpler, refactor that piece
into a separate function.

The logic is modified slightly so that exit(3) is invoked only in
main().  This is not required, but it makes the code slightly easier to
understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |  134 ++++++++++++++++++++++++++---------------------
 1 files changed, 75 insertions(+), 59 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 4c4e95d..c57dd6c 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -60,7 +60,7 @@ static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = 0;
 static uint16_t		opt_srcport = 0;
 
-static void		notify(void);
+static void		notify(const int sock);
 static int		notify_host(int, struct nsm_host *);
 static void		recv_reply(int);
 static void		insert_host(struct nsm_host *);
@@ -134,10 +134,74 @@ static void smn_forget_host(struct nsm_host *host)
 	free(host);
 }
 
+/*
+ * Prepare a socket for sending RPC requests
+ *
+ * Returns a bound datagram socket file descriptor, or -1 if
+ * an error occurs.
+ */
+static int
+smn_create_socket(const char *srcaddr, const uint16_t srcport)
+{
+	struct sockaddr_storage address;
+	struct sockaddr *local_addr = (struct sockaddr *)&address;
+	int sock, retry_cnt = 0;
+
+retry:
+	sock = socket(AF_INET, SOCK_DGRAM, 0);
+	if (sock < 0) {
+		xlog(L_ERROR, "Failed to create RPC socket: %m");
+		return -1;
+	}
+	fcntl(sock, F_SETFL, O_NONBLOCK);
+
+	memset(&address, 0, sizeof(address));
+	local_addr->sa_family = AF_INET;	/* Default to IPv4 */
+
+	/* Bind source IP if provided on command line */
+	if (srcaddr) {
+		struct addrinfo *ai = smn_lookup(srcaddr);
+		if (!ai) {
+			xlog(L_ERROR,
+				"Not a valid hostname or address: \"%s\"",
+				srcaddr);
+			return -1;
+		}
+
+		/* We know it's IPv4 at this point */
+		memcpy(local_addr, ai->ai_addr, ai->ai_addrlen);
+
+		freeaddrinfo(ai);
+	}
+
+	/* Use source port if provided on the command line,
+	 * otherwise use bindresvport */
+	if (srcport) {
+		nfs_set_port(local_addr, srcport);
+		if (bind(sock, local_addr, sizeof(struct sockaddr_in)) < 0) {
+			xlog(L_ERROR, "Failed to bind RPC socket: %m");
+			return -1;
+		}
+	} else {
+		struct servent *se;
+		struct sockaddr_in *sin = (struct sockaddr_in *)local_addr;
+		(void) bindresvport(sock, sin);
+		/* try to avoid known ports */
+		se = getservbyport(sin->sin_port, "udp");
+		if (se && retry_cnt < 100) {
+			retry_cnt++;
+			close(sock);
+			goto retry;
+		}
+	}
+
+	return sock;
+}
+
 int
 main(int argc, char **argv)
 {
-	int	c;
+	int	c, sock;
 	int	force = 0;
 	char *	progname;
 
@@ -235,7 +299,14 @@ usage:		fprintf(stderr,
 		close(2);
 	}
 
-	notify();
+	sock = smn_create_socket(opt_srcaddr, opt_srcport);
+	if (sock < 0)
+		exit(1);
+
+	if (!nsm_drop_privileges(-1))
+		exit(1);
+
+	notify(sock);
 
 	if (hosts) {
 		struct nsm_host	*hp;
@@ -255,68 +326,13 @@ usage:		fprintf(stderr,
  * Notify hosts
  */
 static void
-notify(void)
+notify(const int sock)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *local_addr = (struct sockaddr *)&address;
 	time_t	failtime = 0;
-	int	sock = -1;
-	int retry_cnt = 0;
-
- retry:
-	sock = socket(AF_INET, SOCK_DGRAM, 0);
-	if (sock < 0) {
-		xlog(L_ERROR, "Failed to create RPC socket: %m");
-		exit(1);
-	}
-	fcntl(sock, F_SETFL, O_NONBLOCK);
-
-	memset(&address, 0, sizeof(address));
-	local_addr->sa_family = AF_INET;	/* Default to IPv4 */
-
-	/* Bind source IP if provided on command line */
-	if (opt_srcaddr) {
-		struct addrinfo *ai = smn_lookup(opt_srcaddr);
-		if (!ai) {
-			xlog(L_ERROR,
-				"Not a valid hostname or address: \"%s\"",
-				opt_srcaddr);
-			exit(1);
-		}
-
-		/* We know it's IPv4 at this point */
-		memcpy(local_addr, ai->ai_addr, ai->ai_addrlen);
-
-		freeaddrinfo(ai);
-	}
-
-	/* Use source port if provided on the command line,
-	 * otherwise use bindresvport */
-	if (opt_srcport) {
-		nfs_set_port(local_addr, opt_srcport);
-		if (bind(sock, local_addr, sizeof(struct sockaddr_in)) < 0) {
-			xlog(L_ERROR, "Failed to bind RPC socket: %m");
-			exit(1);
-		}
-	} else {
-		struct servent *se;
-		struct sockaddr_in *sin = (struct sockaddr_in *)local_addr;
-		(void) bindresvport(sock, sin);
-		/* try to avoid known ports */
-		se = getservbyport(sin->sin_port, "udp");
-		if (se && retry_cnt < 100) {
-			retry_cnt++;
-			close(sock);
-			goto retry;
-		}
-	}
 
 	if (opt_max_retry)
 		failtime = time(NULL) + opt_max_retry;
 
-	if (!nsm_drop_privileges(-1))
-		exit(1);
-
 	while (hosts) {
 		struct pollfd	pfd;
 		time_t		now = time(NULL);

