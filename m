From: Neil Brown <neilb@suse.de>
Subject: [PATCH] validateascii in idmapd.c access beyond end of array.
Date: Mon, 18 Feb 2008 13:44:34 +1100
Message-ID: <18360.61714.319143.365424@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcus Meissner <meissner@novell.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:56428 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087AbYBRCob (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Feb 2008 21:44:31 -0500
Cc: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If validateascii is passed a string containing only non-zero 7bit
values, then the loop with exit with i == len, and the following
test will access beyond the end of the array.

So add an extra test to fix this.

Found by Marcus Meissner <meissner@novell.com>.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 355c6e1..6b5971c 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -848,7 +848,7 @@ validateascii(char *string, u_int32_t len)
 			return (-1);
 	}
 
-	if (string[i] != '\0')
+	if ((i >= len) || string[i] != '\0')
 		return (-1);
 
 	return (i + 1);
