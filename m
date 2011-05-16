Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:54189 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751452Ab1EPQd2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:33:28 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1QM03i-0000Aq-Qm
	for linux-nfs@vger.kernel.org; Mon, 16 May 2011 11:50:15 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] Removed compilation warnings from mountd/cache.c
Date: Mon, 16 May 2011 11:50:14 -0400
Message-Id: <1305561014-25688-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Commit 5604b35a6 introduced a number of missing initializer
warnings that were missed. This patch removes those warnings.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/cache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index df6b38f..86a2790 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -825,7 +825,6 @@ struct {
 	char *cache_name;
 	void (*cache_handle)(FILE *f);
 	FILE *f;
-	char vbuf[RPC_CHAN_BUF_SIZE];
 } cachelist[] = {
 	{ "auth.unix.ip", auth_unix_ip, NULL},
 	{ "auth.unix.gid", auth_unix_gid, NULL},
@@ -833,6 +832,9 @@ struct {
 	{ "nfsd.fh", nfsd_fh, NULL},
 	{ NULL, NULL, NULL }
 };
+struct vbs {
+	char vbuf[RPC_CHAN_BUF_SIZE];
+} vbufs [(sizeof(cachelist)/sizeof(cachelist[0])) - 1];
 
 extern int manage_gids;
 
@@ -850,7 +852,7 @@ void cache_open(void)
 		sprintf(path, "/proc/net/rpc/%s/channel", cachelist[i].cache_name);
 		cachelist[i].f = fopen(path, "r+");
 		if (cachelist[i].f != NULL) {
-			setvbuf(cachelist[i].f, cachelist[i].vbuf, _IOLBF, 
+			setvbuf(cachelist[i].f, vbufs[i].vbuf, _IOLBF, 
 				RPC_CHAN_BUF_SIZE);
 		}
 	}
-- 
1.7.4.4

