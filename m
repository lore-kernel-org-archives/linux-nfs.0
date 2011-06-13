Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55408 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442Ab1FMV1j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 17:27:39 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v4 3/6] nfs-utils:  Implement srcaddr binding in rpc_socket
Date: Mon, 13 Jun 2011 14:26:45 -0700
Message-Id: <1308000408-13690-4-git-send-email-greearb@candelatech.com>
In-Reply-To: <1308000408-13690-1-git-send-email-greearb@candelatech.com>
References: <1308000408-13690-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This implements the actual binding, if we are passed
a non-null local_ip structure.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 5652f6c... 936319b... M	support/nfs/rpc_socket.c
 support/nfs/rpc_socket.c |   59 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 46 insertions(+), 13 deletions(-)

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 5652f6c..936319b 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -115,6 +115,8 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
 static int nfs_bind(const int sock, const sa_family_t family,
 		    struct local_bind_info *local_ip)
 {
+	struct sockaddr *sa = NULL;
+	socklen_t salen = 0;
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
@@ -124,15 +126,26 @@ static int nfs_bind(const int sock, const sa_family_t family,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 	};
 
-	switch (family) {
-	case AF_INET:
-		return bind(sock, (struct sockaddr *)(char *)&sin,
-					(socklen_t)sizeof(sin));
-	case AF_INET6:
-		return bind(sock, (struct sockaddr *)(char *)&sin6,
-					(socklen_t)sizeof(sin6));
+	if (local_ip) {
+		sa = &local_ip->addr.sa;
+		salen = local_ip->addrlen;
+	} else {
+		switch (family) {
+		case AF_INET:
+			sa = (struct sockaddr *)&sin;
+			salen = sizeof(sin);
+			break;
+		case AF_INET6:
+			sa = (struct sockaddr *)&sin6;
+			salen = sizeof(sin6);
+		default:
+			break;
+		}
 	}
 
+	if (sa)
+		return bind(sock, sa, salen);
+
 	errno = EAFNOSUPPORT;
 	return -1;
 }
@@ -148,6 +161,7 @@ static int nfs_bind(const int sock, const sa_family_t family,
 static int nfs_bindresvport(const int sock, const sa_family_t family,
 			    struct local_bind_info *local_ip)
 {
+	struct sockaddr *sa = NULL;
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
@@ -157,13 +171,23 @@ static int nfs_bindresvport(const int sock, const sa_family_t family,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 	};
 
-	switch (family) {
-	case AF_INET:
-		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin);
-	case AF_INET6:
-		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin6);
+	if (local_ip) {
+		sa = &local_ip->addr.sa;
+	} else {
+		switch (family) {
+		case AF_INET:
+			sa = (struct sockaddr *)&sin;
+			break;
+		case AF_INET6:
+			sa = (struct sockaddr *)&sin6;
+		default:
+			break;
+		}
 	}
 
+	if (sa)
+		return bindresvport_sa(sock, sa);
+
 	errno = EAFNOSUPPORT;
 	return -1;
 }
@@ -179,12 +203,21 @@ static int nfs_bindresvport(const int sock, const sa_family_t family,
 static int nfs_bindresvport(const int sock, const sa_family_t family,
 			    struct local_bind_info *local_ip)
 {
+	struct sockaddr_in laddr;
 	if (family != AF_INET) {
 		errno = EAFNOSUPPORT;
 		return -1;
 	}
 
-	return bindresvport(sock, NULL);
+	laddr.sin_family = family;
+	laddr.sin_port = 0;
+	if (local_ip) {
+		struct sockaddr_in *si = &local_ip->addr.s4;
+		laddr.sin_addr.s_addr = si->sin_addr.s_addr;
+	} else {
+		laddr.sin_addr.s_addr = htonl(INADDR_ANY);
+	}
+	return bindresvport(sock, &laddr);
 }
 
 #endif	/* !HAVE_LIBTIRPC */
-- 
1.7.3.4

