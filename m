From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 06/24] Remove warnings from nfs_mntent.c
Date: Tue, 20 Jul 2010 19:37:19 -0400
Message-ID: <1279669057-17509-7-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60377 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761912Ab0GUAnJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:09 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNW-0004K5-Va
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:39 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_mntent.c: In function 'mangle':
nfs_mntent.c:36: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/nfs_mntent.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
index a3fecfc..9c73ae0 100644
--- a/support/nfs/nfs_mntent.c
+++ b/support/nfs/nfs_mntent.c
@@ -28,7 +28,7 @@ static char *
 mangle(const char *arg) {
 	const unsigned char *s = (const unsigned char *)arg;
 	char *ss, *sp;
-	int n;
+	unsigned int n;
 
 	n = strlen(arg);
 	ss = sp = xmalloc(4*n+1);
-- 
1.7.0.1

