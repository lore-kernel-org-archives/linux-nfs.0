From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 16/24] Removed warnings from gssd_main_loop.c
Date: Tue, 20 Jul 2010 19:37:29 -0400
Message-ID: <1279669057-17509-17-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60373 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761886Ab0GUAnA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:00 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNY-0004K5-Qa
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:40 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gssd_main_loop.c: In function 'dir_notify_handler':
gssd_main_loop.c:64: warning: unused parameter 'sig'
gssd_main_loop.c:64: warning: unused parameter 'si'
gssd_main_loop.c:64: warning: unused parameter 'data'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_main_loop.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index f1a68d3..b06c223 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -63,6 +63,8 @@ static volatile int dir_changed = 1;
 
 static void dir_notify_handler(int sig, siginfo_t *si, void *data)
 {
+	printerr(2, "dir_notify_handler: sig %d si %p data %p\n", sig, si, data);
+
 	dir_changed = 1;
 }
 
-- 
1.7.0.1

