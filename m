From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/29] statd: factor socket creation out of notify()
Date: Tue, 10 Nov 2009 16:58:15 -0500
Message-ID: <20091110215815.23822.89905.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:27056 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758445AbZKJV6h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:58:37 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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
index 9ed5df1..b80d90d 100644
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
@@ -145,10 +145,74 @@ smn_get_host(const char *hostname,
 	return 1;
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
 
@@ -246,7 +310,14 @@ usage:		fprintf(stderr,
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
@@ -266,68 +337,13 @@ usage:		fprintf(stderr,
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

