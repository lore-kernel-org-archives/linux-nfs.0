From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 15/24] Removed warnings from gssd.c
Date: Tue, 20 Jul 2010 19:37:28 -0400
Message-ID: <1279669057-17509-16-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60370 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761886Ab0GUAm5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:42:57 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNY-0004K5-NC
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:40 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gssd.c: In function 'sig_hup':
gssd.c:78: warning: unused parameter 'signal'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index bd37a5f..ccadb07 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -78,7 +78,7 @@ void
 sig_hup(int signal)
 {
 	/* don't exit on SIGHUP */
-	printerr(1, "Received SIGHUP... Ignoring.\n");
+	printerr(1, "Received SIGHUP(%d)... Ignoring.\n", signal);
 	return;
 }
 
-- 
1.7.0.1

