From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 17/24] Removed warnings from nfsmount.c
Date: Wed,  4 Aug 2010 11:12:13 -0400
Message-ID: <1280934740-11366-18-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45184 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755583Ab0HDPvW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:51:22 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdo-0002SZ-71
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:24 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsmount.c: In function 'nfsmount':
nfsmount.c:513: warning: missing initializer
nfsmount.c:513: warning: (near initialization for 'mnt_server.saddr')
nfsmount.c:514: warning: missing initializer
nfsmount.c:514: warning: (near initialization for 'nfs_server.saddr')

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/nfsmount.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6b3356c..5b934b5 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -510,8 +510,12 @@ nfsmount(const char *spec, const char *node, int flags,
 	int val;
 	static int doonce = 0;
 
-	clnt_addr_t mnt_server = { &mounthost, };
-	clnt_addr_t nfs_server = { &hostname, };
+	clnt_addr_t mnt_server = { 
+		.hostname = &mounthost 
+	};
+	clnt_addr_t nfs_server = { 
+		.hostname = &hostname 
+	};
 	struct sockaddr_in *nfs_saddr = &nfs_server.saddr;
 	struct pmap  *mnt_pmap = &mnt_server.pmap,
 		     *nfs_pmap = &nfs_server.pmap;
-- 
1.7.2

