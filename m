From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
Date: Mon, 11 May 2009 13:58:16 -0400
Message-ID: <1242064697-32520-3-git-send-email-jlayton@redhat.com>
References: <1242064697-32520-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:32972 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758626AbZEKR6S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 13:58:18 -0400
In-Reply-To: <1242064697-32520-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set the
correct option to prevent it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/nfssvc.c |   26 +++++++++++++++++++++-----
 1 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index c9b09dd..914bb3f 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -60,29 +60,37 @@ nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
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
-			syslog(LOG_ERR, "nfssvc: unable to create UPD socket: "
+			syslog(LOG_ERR, "nfssvc: unable to create UDP socket: "
+				"errno %d (%s)\n", errno, strerror(errno));
+			exit(1);
+		}
+		if (family == AF_INET6 && setsockopt(udpfd, IPPROTO_IPV6,
+						     IPV6_V6ONLY, &on,
+						     sizeof(on))) {
+			syslog(LOG_ERR, "nfssvc: unable to set IPV6_V6ONLY: "
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
 		}
 		if (bind(udpfd, sa, addrlen) < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to bind UPD socket: "
+			syslog(LOG_ERR, "nfssvc: unable to bind UDP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
 		}
 	}
 
 	if (NFSCTL_TCPISSET(ctlbits)) {
-		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
+		tcpfd = socket(family, SOCK_STREAM, IPPROTO_TCP);
 		if (tcpfd < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to createt tcp socket: "
+			syslog(LOG_ERR, "nfssvc: unable to createt TCP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
 		}
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

