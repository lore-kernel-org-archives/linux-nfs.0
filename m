From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 19/24] Removed warnings from svcgssd.c
Date: Tue, 20 Jul 2010 19:37:32 -0400
Message-ID: <1279669057-17509-20-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60378 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761683Ab0GUAnK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:10 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNZ-0004K5-4a
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:41 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svcgssd.c: In function 'sig_hup':
svcgssd.c:160: warning: unused parameter 'signal'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/svcgssd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 729b6a6..e7375a4 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -160,7 +160,7 @@ void
 sig_hup(int signal)
 {
 	/* don't exit on SIGHUP */
-	printerr(1, "Received SIGHUP... Ignoring.\n");
+	printerr(1, "Received SIGHUP(%d)... Ignoring.\n", signal);
 	return;
 }
 
-- 
1.7.0.1

