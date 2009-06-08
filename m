From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 09/11] nfs-utils: add IPv6 support to nfssvc_setfds
Date: Mon,  8 Jun 2009 14:00:42 -0400
Message-ID: <1244484044-21355-10-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48183 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547AbZFHSBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:01:03 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow nfssvc_setfds to properly deal with AF_INET6.

IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set the
correct option to prevent that from occurring on IPv6 sockets.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfssvc.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 106f6e7..ee862b2 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -81,6 +81,11 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 	case AF_INET:
 		family = "inet";
 		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		family = "inet6";
+		break;
+#endif /* IPV6_SUPPORTED */
 	default:
 		xlog(L_ERROR, "Unknown address family specified: %d\n",
 				hints->ai_family);
@@ -128,6 +133,15 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 			rc = errno;
 			goto error;
 		}
+#ifdef IPV6_SUPPORTED
+		if (addr->ai_family == AF_INET6 &&
+		    setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &on, sizeof(on))) {
+			xlog(L_ERROR, "unable to set IPV6_V6ONLY: "
+				"errno %d (%m)\n", errno);
+			rc = errno;
+			goto error;
+		}
+#endif /* IPV6_SUPPORTED */
 		if (addr->ai_protocol == IPPROTO_TCP &&
 		    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on))) {
 			xlog(L_ERROR, "unable to set SO_REUSEADDR on %s "
-- 
1.6.0.6

