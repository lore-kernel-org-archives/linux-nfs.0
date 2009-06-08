From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 07/11] nfs-utils: convert nfssvc_setfds to use getaddrinfo
Date: Mon,  8 Jun 2009 14:00:40 -0400
Message-ID: <1244484044-21355-8-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48171 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038AbZFHSBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:01:01 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert nfssvc_setfds to use getaddrinfo. Change the args that it takes
and fix up nfssvc function to pass in the proper args. The things that
nfssvc has to do to call the new nfssvc_setfds is a little cumbersome
for now, but that will eventually be cleaned up in a later patch.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.c   |   18 +++--
 utils/nfsd/nfssvc.c |  191 ++++++++++++++++++++++++++++++++++----------------
 2 files changed, 140 insertions(+), 69 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 1589a9f..78dddc2 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -76,14 +76,16 @@ main(int argc, char **argv)
 			xlog_config(D_ALL, 1);
 			break;
 		case 'H':
-			if (inet_addr(optarg) != INADDR_NONE) {
-				haddr = strdup(optarg);
-			} else if ((hp = gethostbyname(optarg)) != NULL) {
-				haddr = inet_ntoa((*(struct in_addr*)(hp->h_addr_list[0])));
-			} else {
-				fprintf(stderr, "%s: Unknown hostname: %s\n",
-					progname, optarg);
-				usage(progname);
+			/*
+			 * for now, this only handles one -H option. Use the
+			 * last one specified.
+			 */
+			free(haddr);
+			haddr = strdup(optarg);
+			if (!haddr) {
+				fprintf(stderr, "%s: unable to allocate "
+					"memory.\n", progname);
+				exit(1);
 			}
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 7ecaea9..68899cb 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -10,7 +10,9 @@
 #include <config.h>
 #endif
 
+#include <sys/types.h>
 #include <sys/socket.h>
+#include <netdb.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <unistd.h>
@@ -59,84 +61,148 @@ nfssvc_inuse(void)
 	return (n > 0);
 }
 
-static void
-nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
+static int
+nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 {
-	int fd, on=1;
-	int udpfd = -1, tcpfd = -1;
-	struct sockaddr_in sin;
-
-	if (nfssvc_inuse())
-		return;
+	int fd, on = 1, fac = L_ERROR;
+	int sockfd = -1, rc = 0;
+	struct addrinfo *addrhead = NULL, *addr;
+	char *proto, *family;
 
+	/*
+	 * if file can't be opened, then assume that it's not available and
+	 * that the caller should just fall back to the old nfsctl interface
+ 	 */
 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
 	if (fd < 0)
-		return;
-	sin.sin_family = AF_INET;
-	sin.sin_port   = htons(port);
-	sin.sin_addr.s_addr =  inet_addr(haddr);
-
-	if (NFSCTL_UDPISSET(ctlbits)) {
-		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
-		if (udpfd < 0) {
-			xlog(L_ERROR, "unable to create UDP socket: "
-				"errno %d (%m)", errno);
-			exit(1);
-		}
-		if (bind(udpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
-			xlog(L_ERROR, "unable to bind UDP socket: "
-				"errno %d (%m)", errno);
-			exit(1);
-		}
+		return 0;
+
+	switch(hints->ai_family) {
+	case AF_INET:
+		family = "inet";
+		break;
+	default:
+		xlog(L_ERROR, "Unknown address family specified: %d\n",
+				hints->ai_family);
+		rc = EAFNOSUPPORT;
+		goto error;
 	}
 
-	if (NFSCTL_TCPISSET(ctlbits)) {
-		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
-		if (tcpfd < 0) {
-			xlog(L_ERROR, "unable to create TCP socket: "
-				"errno %d (%m)", errno);
-			exit(1);
+	rc = getaddrinfo(node, port, hints, &addrhead);
+	if (rc == EAI_NONAME && !strcmp(port, "nfs")) {
+		snprintf(buf, sizeof(buf), "%d", NFS_PORT);
+		rc = getaddrinfo(node, buf, hints, &addrhead);
+	}
+
+	if (rc != 0) {
+		xlog(L_ERROR, "unable to resolve %s:%s to %s address: "
+				"%s", node ? node : "ANYADDR", port, family,
+				rc == EAI_SYSTEM ? strerror(errno) :
+					gai_strerror(rc));
+		goto error;
+	}
+
+	addr = addrhead;
+	while(addr) {
+		/* skip non-TCP / non-UDP sockets */
+		switch(addr->ai_protocol) {
+		case IPPROTO_UDP:
+			proto = "UDP";
+			break;
+		case IPPROTO_TCP:
+			proto = "TCP";
+			break;
+		default:
+			addr = addr->ai_next;
+			continue;
 		}
-		if (setsockopt(tcpfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0) {
-			xlog(L_ERROR, "unable to set SO_REUSEADDR: "
-				"errno %d (%m)", errno);
-			exit(1);
+
+		xlog(D_GENERAL, "Creating %s %s socket.", family, proto);
+
+		/* open socket and prepare to hand it off to kernel */
+		sockfd = socket(addr->ai_family, addr->ai_socktype,
+				addr->ai_protocol);
+		if (sockfd < 0) {
+			xlog(L_ERROR, "unable to create %s %s socket: "
+				"errno %d (%m)", family, proto, errno);
+			rc = errno;
+			goto error;
 		}
-		if (bind(tcpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
-			xlog(L_ERROR, "unable to bind TCP socket: "
-				"errno %d (%m)", errno);
-			exit(1);
+		if (addr->ai_protocol == IPPROTO_TCP &&
+		    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on))) {
+			xlog(L_ERROR, "unable to set SO_REUSEADDR on %s "
+				"socket: errno %d (%m)", family, errno);
+			rc = errno;
+			goto error;
+		}
+		if (bind(sockfd, addr->ai_addr, addr->ai_addrlen)) {
+			xlog(L_ERROR, "unable to bind %s %s socket: "
+				"errno %d (%m)", family, proto, errno);
+			rc = errno;
+			goto error;
 		}
-		if (listen(tcpfd, 64) < 0){
+		if (addr->ai_protocol == IPPROTO_TCP && listen(sockfd, 64)) {
 			xlog(L_ERROR, "unable to create listening socket: "
 				"errno %d (%m)", errno);
-			exit(1);
+			rc = errno;
+			goto error;
 		}
-	}
-	if (udpfd >= 0) {
-		snprintf(buf, sizeof(buf), "%d\n", udpfd); 
-		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
-			xlog(L_ERROR, 
-			       "writing fds to kernel failed: errno %d (%m)", 
-			       errno);
-		}
-		close(fd);
-		fd = -1;
-	}
-	if (tcpfd >= 0) {
+
 		if (fd < 0)
 			fd = open(NFSD_PORTS_FILE, O_WRONLY);
-		snprintf(buf, sizeof(buf), "%d\n", tcpfd); 
+
+		if (fd < 0) {
+			xlog(L_ERROR, "couldn't open ports file: errno "
+				      "%d (%m)", errno);
+			goto error;
+		}
+
+		snprintf(buf, sizeof(buf), "%d\n", sockfd); 
 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
-			xlog(L_ERROR, 
-			       "writing fds to kernel failed: errno %d (%m)", 
-			       errno);
+			/*
+			 * this error may be common on older kernels that don't
+			 * support IPv6, so turn into a debug message.
+			 */
+			if (errno == EAFNOSUPPORT)
+				fac = D_ALL;
+			xlog(fac, "writing fd to kernel failed: errno %d (%m)",
+				  errno);
+			rc = errno;
+			goto error;
 		}
+		close(fd);
+		close(sockfd);
+		sockfd = fd = -1;
+		addr = addr->ai_next;
 	}
-	close(fd);
+error:
+	if (fd >= 0)
+		close(fd);
+	if (sockfd >= 0)
+		close(sockfd);
+	if (addrhead)
+		freeaddrinfo(addrhead);
+	return rc;
+}
 
-	return;
+static int
+nfssvc_set_sockets(const int family, const unsigned int protobits,
+		   const char *host, const char *port)
+{
+	struct addrinfo hints = { .ai_flags = AI_PASSIVE | AI_ADDRCONFIG };
+
+	hints.ai_family = family;
+
+	if (!NFSCTL_ANYPROTO(protobits))
+		return EPROTOTYPE;
+	else if (!NFSCTL_UDPISSET(protobits))
+		hints.ai_protocol = IPPROTO_TCP;
+	else if (!NFSCTL_TCPISSET(protobits))
+		hints.ai_protocol = IPPROTO_UDP;
+
+	return nfssvc_setfds(&hints, host, port);
 }
+
 static void
 nfssvc_versbits(unsigned int ctlbits, int minorvers4)
 {
@@ -180,8 +246,11 @@ nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
 	 * the ports get registered with portmap against correct
 	 * versions
 	 */
-	nfssvc_versbits(versbits, minorvers4);
-	nfssvc_setfds(port, protobits, haddr);
+	if (!nfssvc_inuse()) {
+		nfssvc_versbits(versbits, minorvers4);
+		snprintf(buf, sizeof(buf), "%d", port);
+		nfssvc_set_sockets(AF_INET, protobits, haddr, portstr);
+	}
 
 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
 	if (fd < 0)
-- 
1.6.0.6

