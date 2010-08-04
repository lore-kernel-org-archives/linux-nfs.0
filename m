From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 04/24] emove warnings from cacheio.c
Date: Wed,  4 Aug 2010 11:12:00 -0400
Message-ID: <1280934740-11366-5-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:54503 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752713Ab0HDPMY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:12:24 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdm-0002SZ-AG
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:22 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
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
1.7.2

