From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 16/24] Removed warnings from svcgssd.c
Date: Wed,  4 Aug 2010 11:12:12 -0400
Message-ID: <1280934740-11366-17-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45171 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755161Ab0HDPvE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:51:04 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdo-0002SZ-3a
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:24 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
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
1.7.2

