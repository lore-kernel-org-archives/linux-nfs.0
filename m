From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/19] sm-notify command: replace nsm_address typedef
Date: Fri, 05 Sep 2008 17:07:41 -0400
Message-ID: <20080905210741.10001.96435.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41427 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbYIEVIn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:08:43 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: replace "typedef struct sockaddr_storage nsm_address" with
standard socket address types.  This makes sm-notify.c consistent with other
parts of nfs-utils, and with typical network application coding conventions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |  129 +++++++++++++++++++++++------------------------
 1 files changed, 63 insertions(+), 66 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index e5ca904..8108765 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -53,13 +53,11 @@ char *_SM_BAK_PATH = DEFAULT_SM_BAK_PATH;
 #define NSM_MAX_TIMEOUT	120	/* don't make this too big */
 #define MAXMSGSIZE	256
 
-typedef struct sockaddr_storage nsm_address;
-
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
 	char *			path;
-	nsm_address		addr;
+	struct sockaddr_storage	addr;
 	struct addrinfo		*ai;
 	time_t			last_used;
 	time_t			send_next;
@@ -86,9 +84,6 @@ static void		backup_hosts(const char *, const char *);
 static void		get_hosts(const char *);
 static void		insert_host(struct nsm_host *);
 struct nsm_host *	find_host(uint32_t);
-static int		addr_get_port(nsm_address *);
-static void		addr_set_port(nsm_address *, int);
-static struct addrinfo	*host_lookup(int, const char *);
 void			nsm_log(int fac, const char *fmt, ...);
 static int		record_pid(void);
 static void		drop_privs(void);
@@ -96,6 +91,46 @@ static void set_kernel_nsm_state(int state);
 
 static struct nsm_host *	hosts = NULL;
 
+/*
+ * Address handling utilities
+ */
+
+static unsigned short smn_get_port(const struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		return ntohs(((struct sockaddr_in *)sap)->sin_port);
+	case AF_INET6:
+		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+	}
+	return 0;
+}
+
+static void smn_set_port(struct sockaddr *sap, const unsigned short port)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *)sap)->sin_port = htons(port);
+		break;
+	case AF_INET6:
+		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
+		break;
+	}
+}
+
+static struct addrinfo *smn_lookup(const sa_family_t family, const char *name)
+{
+	struct addrinfo	*ai, hint = {
+		.ai_family	= family,
+		.ai_protocol	= IPPROTO_UDP,
+	};
+
+	if (getaddrinfo(name, NULL, &hint, &ai) != 0)
+		return NULL;
+
+	return ai;
+}
+
 int
 main(int argc, char **argv)
 {
@@ -217,7 +252,8 @@ usage:		fprintf(stderr,
 void
 notify(void)
 {
-	nsm_address local_addr;
+	struct sockaddr_storage address;
+	struct sockaddr *local_addr = (struct sockaddr *)&address;
 	time_t	failtime = 0;
 	int	sock = -1;
 	int retry_cnt = 0;
@@ -231,12 +267,12 @@ notify(void)
 	}
 	fcntl(sock, F_SETFL, O_NONBLOCK);
 
-	memset(&local_addr, 0, sizeof(local_addr));
-	local_addr.ss_family = AF_INET; /* Default to IPv4 */
+	memset(&address, 0, sizeof(address));
+	local_addr->sa_family = AF_INET;	/* Default to IPv4 */
 
 	/* Bind source IP if provided on command line */
 	if (opt_srcaddr) {
-		struct addrinfo *ai = host_lookup(AF_INET, opt_srcaddr);
+		struct addrinfo *ai = smn_lookup(AF_INET, opt_srcaddr);
 		if (!ai) {
 			nsm_log(LOG_ERR,
 				"Not a valid hostname or address: \"%s\"",
@@ -245,7 +281,7 @@ notify(void)
 		}
 
 		/* We know it's IPv4 at this point */
-		memcpy(&local_addr, ai->ai_addr, ai->ai_addrlen);
+		memcpy(local_addr, ai->ai_addr, ai->ai_addrlen);
 
 		freeaddrinfo(ai);
 	}
@@ -253,15 +289,15 @@ notify(void)
 	/* Use source port if provided on the command line,
 	 * otherwise use bindresvport */
 	if (opt_srcport) {
-		addr_set_port(&local_addr, opt_srcport);
-		if (bind(sock, (struct sockaddr *) &local_addr, sizeof(local_addr)) < 0) {
+		smn_set_port(local_addr, opt_srcport);
+		if (bind(sock, local_addr, sizeof(struct sockaddr_in)) < 0) {
 			nsm_log(LOG_ERR, "Failed to bind RPC socket: %s",
 				strerror(errno));
 			exit(1);
 		}
 	} else {
 		struct servent *se;
-		struct sockaddr_in *sin = (struct sockaddr_in *)&local_addr;
+		struct sockaddr_in *sin = (struct sockaddr_in *)local_addr;
 		(void) bindresvport(sock, sin);
 		/* try to avoid known ports */
 		se = getservbyport(sin->sin_port, "udp");
@@ -339,8 +375,10 @@ notify(void)
 int
 notify_host(int sock, struct nsm_host *host)
 {
+	struct sockaddr_storage address;
+	struct sockaddr *dest = (struct sockaddr *)&address;
+	socklen_t destlen = sizeof(address);
 	static unsigned int	xid = 0;
-	nsm_address		dest;
 	uint32_t		msgbuf[MAXMSGSIZE], *p;
 	unsigned int		len;
 
@@ -350,7 +388,7 @@ notify_host(int sock, struct nsm_host *host)
 		host->xid = xid++;
 
 	if (host->ai == NULL) {
-		host->ai = host_lookup(AF_UNSPEC, host->name);
+		host->ai = smn_lookup(AF_UNSPEC, host->name);
 		if (host->ai == NULL) {
 			nsm_log(LOG_WARNING,
 				"%s doesn't seem to be a valid address,"
@@ -384,16 +422,16 @@ notify_host(int sock, struct nsm_host *host)
 		/* put first entry at end */
 		*next = first;
 		memcpy(&host->addr, first->ai_addr, first->ai_addrlen);
-		addr_set_port(&host->addr, 0);
+		smn_set_port((struct sockaddr *)&host->addr, 0);
 		host->retries = 0;
 	}
 
-	dest = host->addr;
-	if (addr_get_port(&dest) == 0) {
+	memcpy(dest, &host->addr, destlen);
+	if (smn_get_port(dest) == 0) {
 		/* Build a PMAP packet */
 		nsm_log(LOG_DEBUG, "Sending portmap query to %s", host->name);
 
-		addr_set_port(&dest, 111);
+		smn_set_port(dest, 111);
 		*p++ = htonl(100000);
 		*p++ = htonl(2);
 		*p++ = htonl(3);
@@ -427,7 +465,7 @@ notify_host(int sock, struct nsm_host *host)
 	}
 	len = (p - msgbuf) << 2;
 
-	if (sendto(sock, msgbuf, len, 0, (struct sockaddr *) &dest, sizeof(dest)) < 0)
+	if (sendto(sock, msgbuf, len, 0, dest, destlen) < 0)
 		nsm_log(LOG_WARNING, "Sending Reboot Notification to "
 			"'%s' failed: errno %d (%s)", host->name, errno, strerror(errno));
 	
@@ -441,6 +479,7 @@ void
 recv_reply(int sock)
 {
 	struct nsm_host	*hp;
+	struct sockaddr *sap;
 	uint32_t	msgbuf[MAXMSGSIZE], *p, *end;
 	uint32_t	xid;
 	int		res;
@@ -466,8 +505,9 @@ recv_reply(int sock)
 	   this reply */
 	if ((hp = find_host(xid)) == NULL)
 		return;
+	sap = (struct sockaddr *)&hp->addr;
 
-	if (addr_get_port(&hp->addr) == 0) {
+	if (smn_get_port(sap) == 0) {
 		/* This was a portmap request */
 		unsigned int	port;
 
@@ -483,7 +523,7 @@ recv_reply(int sock)
 			hp->timeout = NSM_MAX_TIMEOUT;
 			hp->send_next += NSM_MAX_TIMEOUT;
 		} else {
-			addr_set_port(&hp->addr, port);
+			smn_set_port(sap, port);
 			if (hp->timeout >= NSM_MAX_TIMEOUT / 4)
 				hp->timeout = NSM_MAX_TIMEOUT / 4;
 		}
@@ -696,49 +736,6 @@ nsm_get_state(int update)
 }
 
 /*
- * Address handling utilities
- */
-
-int
-addr_get_port(nsm_address *addr)
-{
-	switch (((struct sockaddr *) addr)->sa_family) {
-	case AF_INET:
-		return ntohs(((struct sockaddr_in *) addr)->sin_port);
-	case AF_INET6:
-		return ntohs(((struct sockaddr_in6 *) addr)->sin6_port);
-	}
-	return 0;
-}
-
-static void
-addr_set_port(nsm_address *addr, int port)
-{
-	switch (((struct sockaddr *) addr)->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *) addr)->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *) addr)->sin6_port = htons(port);
-	}
-}
-
-static struct addrinfo *
-host_lookup(int af, const char *name)
-{
-	struct addrinfo	hints, *ai;
-
-	memset(&hints, 0, sizeof(hints));
-	hints.ai_family = af;
-	hints.ai_protocol = IPPROTO_UDP;
-
-	if (getaddrinfo(name, NULL, &hints, &ai) != 0)
-		return NULL;
-
-	return ai;
-}
-
-/*
  * Log a message
  */
 void

