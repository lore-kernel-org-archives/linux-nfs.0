From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/6] nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
Date: Tue, 26 May 2009 11:15:48 -0400
Message-ID: <1243350951-13462-4-git-send-email-jlayton@redhat.com>
References: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46738 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402AbZEZPP4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 11:15:56 -0400
In-Reply-To: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set the
correct option to prevent it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/nfssvc.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index c2c5480..b14d37d 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -60,18 +60,26 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 	int fd, on = 1;
 	char buf[BUFSIZ];
 	int udpfd = -1, tcpfd = -1;
+	unsigned short family = sa->sa_family;
 
 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
 	if (fd < 0)
 		return;
 
 	if (NFSCTL_UDPISSET(ctlbits)) {
-		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
+		udpfd = socket(family, SOCK_DGRAM, IPPROTO_UDP);
 		if (udpfd < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to create UDP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
 		}
+		if (family == AF_INET6 && setsockopt(udpfd, IPPROTO_IPV6,
+						     IPV6_V6ONLY, &on,
+						     sizeof(on))) {
+			syslog(LOG_ERR, "nfssvc: unable to set IPV6_V6ONLY: "
+				"errno %d (%s)\n", errno, strerror(errno));
+			exit(1);
+		}
 		if (bind(udpfd, sa, addrlen) < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to bind UDP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
@@ -80,7 +88,7 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 	}
 
 	if (NFSCTL_TCPISSET(ctlbits)) {
-		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
+		tcpfd = socket(family, SOCK_STREAM, IPPROTO_TCP);
 		if (tcpfd < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to create TCP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
@@ -91,6 +99,14 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
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

