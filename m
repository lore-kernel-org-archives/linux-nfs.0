From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/5] nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
Date: Wed, 27 May 2009 07:54:33 -0400
Message-ID: <1243425275-6284-4-git-send-email-jlayton@redhat.com>
References: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40503 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762012AbZE0Lyj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2009 07:54:39 -0400
In-Reply-To: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set the
correct option to prevent it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/nfssvc.c |   31 ++++++++++++++++++++++++++-----
 1 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index 7634562..2aa5281 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -60,6 +60,7 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 	int fd, on = 1;
 	char buf[BUFSIZ];
 	int udpfd = -1, tcpfd = -1, rc = 0;
+	unsigned short family = sa->sa_family;
 
 	/*
 	 * if file can't be opened, then assume that it's not available and
@@ -70,9 +71,19 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 		return 0;
 
 	if (NFSCTL_UDPISSET(ctlbits)) {
-		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
+		udpfd = socket(family, SOCK_DGRAM, IPPROTO_UDP);
 		if (udpfd < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to create UDP socket: "
+			syslog(LOG_ERR, "nfssvc: unable to create %s UDP "
+				"socket: errno %d (%s)\n",
+				family == AF_INET6 ? "ipv6" : "ipv4", errno,
+				strerror(errno));
+			rc = -errno;
+			goto error;
+		}
+		if (family == AF_INET6 && setsockopt(udpfd, IPPROTO_IPV6,
+						     IPV6_V6ONLY, &on,
+						     sizeof(on))) {
+			syslog(LOG_ERR, "nfssvc: unable to set IPV6_V6ONLY: "
 				"errno %d (%s)\n", errno, strerror(errno));
 			rc = -errno;
 			goto error;
@@ -86,10 +97,12 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 	}
 
 	if (NFSCTL_TCPISSET(ctlbits)) {
-		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
+		tcpfd = socket(family, SOCK_STREAM, IPPROTO_TCP);
 		if (tcpfd < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to create TCP socket: "
-				"errno %d (%s)\n", errno, strerror(errno));
+			syslog(LOG_ERR, "nfssvc: unable to create %s TCP "
+				"socket: errno %d (%s)\n",
+				family == AF_INET6 ? "ipv6" : "ipv4", errno,
+				strerror(errno));
 			rc = -errno;
 			goto error;
 		}
@@ -99,6 +112,14 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 			rc = -errno;
 			goto error;
 		}
+		if (family == AF_INET6 && setsockopt(tcpfd, IPPROTO_IPV6,
+						     IPV6_V6ONLY, &on,
+						     sizeof(on))) {
+			syslog(LOG_ERR, "nfssvc: unable to set IPV6_V6ONLY: "
+				"errno %d (%s)\n", errno, strerror(errno));
+			exit(1);
+		}
+
 		if (bind(tcpfd, sa, addrlen) < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to bind TCP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
-- 
1.6.0.6

