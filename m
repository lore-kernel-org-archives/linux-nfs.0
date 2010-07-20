From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 05/24] emove warnings from cacheio.c
Date: Tue, 20 Jul 2010 19:37:18 -0400
Message-ID: <1279669057-17509-6-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60371 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761890Ab0GUAm6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:42:58 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNW-0004K5-S2
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:38 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cacheio.c: In function 'cache_flush':
cacheio.c:352: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/cacheio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 55fa45d..9bad8e6 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -349,7 +349,7 @@ cache_flush(int force)
 		sprintf(path, "/proc/net/rpc/%s/flush", cachelist[c]);
 		fd = open(path, O_RDWR);
 		if (fd >= 0) {
-			if (write(fd, stime, strlen(stime)) != strlen(stime)) {
+			if (write(fd, stime, strlen(stime)) != (ssize_t)strlen(stime)) {
 				xlog_warn("Writing to '%s' failed: errno %d (%s)",
 				path, errno, strerror(errno));
 			}
-- 
1.7.0.1

