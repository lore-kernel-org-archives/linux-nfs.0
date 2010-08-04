From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 05/24] Remove warnings from nfs_mntent.c
Date: Wed,  4 Aug 2010 11:12:01 -0400
Message-ID: <1280934740-11366-6-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:54505 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752711Ab0HDPMY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:12:24 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdm-0002SZ-Do
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:22 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
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
1.7.2

