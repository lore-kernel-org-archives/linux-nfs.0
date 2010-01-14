From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/24] sm-notify: factor socket creation out of notify()
Date: Thu, 14 Jan 2010 12:29:26 -0500
Message-ID: <20100114172926.26079.30399.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36010 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757390Ab0ANRbK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:10 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The top half of the notify() function creates the main socket that
sm-notify uses to do its job.  To make adding IPv6 support simpler,
refactor that piece into a separate function.

The logic is modified slightly so that exit(3) is invoked only in
main().  This is not required, but it makes the code slightly easier
to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |  137 ++++++++++++++++++++++++++---------------------
 1 files changed, 77 insertions(+), 60 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index e49c722..462ba79 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -55,7 +55,7 @@ static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = 0;
 static uint16_t		opt_srcport = 0;
 
-static void		notify(void);
+static void		notify(const int sock);
 static int		notify_host(int, struct nsm_host *);
 static void		recv_reply(int);
 static void		insert_host(struct nsm_host *);
@@ -141,11 +141,76 @@ smn_get_host(const char *hostname,
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
+			(void)close(sock);
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
+			(void)close(sock);
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
-	int	force = 0;
+	int	c, sock, force = 0;
 	char *	progname;
 
 	progname = strrchr(argv[0], '/');
@@ -242,7 +307,14 @@ usage:		fprintf(stderr,
 		close(2);
 	}
 
-	notify();
+	sock = smn_create_socket(opt_srcaddr, opt_srcport);
+	if (sock == -1)
+		exit(1);
+
+	if (!nsm_drop_privileges(-1))
+		exit(1);
+
+	notify(sock);
 
 	if (hosts) {
 		struct nsm_host	*hp;
@@ -262,68 +334,13 @@ usage:		fprintf(stderr,
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

