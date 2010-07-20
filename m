From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 13/24] Removed warnings from atomicio.c
Date: Tue, 20 Jul 2010 19:37:26 -0400
Message-ID: <1279669057-17509-14-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60375 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761898Ab0GUAnG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:06 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNY-0004K5-Fc
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:40 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomicio.c: In function 'atomicio':
atomicio.c:48: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/atomicio.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/idmapd/atomicio.c b/utils/idmapd/atomicio.c
index 05e7147..1fb1ff9 100644
--- a/utils/idmapd/atomicio.c
+++ b/utils/idmapd/atomicio.c
@@ -43,7 +43,8 @@ atomicio(
 	size_t n)
 {
 	char *s = _s;
-	ssize_t res, pos = 0;
+	ssize_t res;
+	size_t pos = 0;
 
 	while (n > pos) {
 		res = (f) (fd, s + pos, n - pos);
-- 
1.7.0.1

