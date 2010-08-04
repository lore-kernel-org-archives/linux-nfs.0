From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 18/24] Removed warnings from nfs4mount.c
Date: Wed,  4 Aug 2010 11:12:14 -0400
Message-ID: <1280934740-11366-19-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45183 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754883Ab0HDPvV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:51:21 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdo-0002SZ-9N
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:24 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4mount.c: In function 'fill_ipv4_sockaddr':
nfs4mount.c:149: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/nfs4mount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 4a2fab7..028e7cd 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -146,7 +146,7 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 				progname, hostname);
 		return -1;
 	}
-	if (hp->h_length > sizeof(struct in_addr)) {
+	if (hp->h_length > (int)sizeof(struct in_addr)) {
 		nfs_error(_("%s: got bad hp->h_length"), progname);
 		hp->h_length = sizeof(struct in_addr);
 	}
-- 
1.7.2

