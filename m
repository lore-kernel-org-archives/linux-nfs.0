From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/6] nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
Date: Tue,  2 Jun 2009 07:43:47 -0400
Message-ID: <1243943029-6400-5-git-send-email-jlayton@redhat.com>
References: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Cc: steved@redhat.com, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42915 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760066AbZFBLoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 07:44:00 -0400
In-Reply-To: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set the
correct option to prevent it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/nfssvc.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index e7f3262..1bb64f0 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -123,6 +123,13 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 			rc = errno;
 			goto error;
 		}
+		if (addr->ai_family == AF_INET6 &&
+		    setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &on, sizeof(on))) {
+			xlog(L_ERROR, "unable to set IPV6_V6ONLY: "
+				"errno %d (%s)\n", errno, strerror(errno));
+			rc = -errno;
+			goto error;
+		}
 		if (addr->ai_protocol == IPPROTO_TCP &&
 		    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on))) {
 			xlog(L_ERROR, "unable to set SO_REUSEADDR on %s "
-- 
1.6.0.6

