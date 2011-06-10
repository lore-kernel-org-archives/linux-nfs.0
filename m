Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53563 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757806Ab1FJSKn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 14:10:43 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 4/7] nfs-utils:  Implement srcaddr binding in network.c
Date: Fri, 10 Jun 2011 11:09:36 -0700
Message-Id: <1307729379-7702-5-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307729379-7702-1-git-send-email-greearb@candelatech.com>
References: <1307729379-7702-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

Implement binding logic in get_socket() if local_ip
argument is not NULL.

Note that this method had issues with supporting IPv6 before
this patch, and this patch does NOT resolve them.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 36c2e94... 5419c5d... M	utils/mount/network.c
 utils/mount/network.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 36c2e94..5419c5d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -461,19 +461,34 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 	int so, cc, type;
 	struct sockaddr_in laddr;
 	socklen_t namelen = sizeof(laddr);
+	int f = AF_INET;
+
+	if (local_ip && local_ip->is_set)
+		f = local_ip->addr.sa.sa_family;
 
 	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
-	if ((so = socket (AF_INET, type, p_prot)) < 0)
+
+	so = socket(f, type, p_prot);
+	if (so < 0)
 		goto err_socket;
 
-	laddr.sin_family = AF_INET;
+	laddr.sin_family = f;
 	laddr.sin_port = 0;
 	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
 	if (resvp) {
+		/* TODO:  Support IPv6 */
+		if (local_ip && local_ip->is_set
+		    && local_ip->addr.sa.sa_family == AF_INET) {
+			struct sockaddr_in *si = &local_ip->addr.s4;
+			laddr.sin_addr.s_addr = si->sin_addr.s_addr;
+		}
 		if (bindresvport(so, &laddr) < 0)
 			goto err_bindresvport;
 	} else {
-		cc = bind(so, SAFE_SOCKADDR(&laddr), namelen);
+		if (local_ip && local_ip->is_set)
+			cc = bind(so, &local_ip->addr.sa, local_ip->addrlen);
+		else
+			cc = bind(so, SAFE_SOCKADDR(&laddr), namelen);
 		if (cc < 0)
 			goto err_bind;
 	}
-- 
1.7.3.4

