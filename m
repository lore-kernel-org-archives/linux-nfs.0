Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:62431 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304Ab0ITX12 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 19:27:28 -0400
From: Andy Shevchenko <andy.shevchenko@gmail.com>
To: linux-kernel@vger.krenel.org
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] sunrpc/cache: don't use custom hex_to_bin() converter
Date: Tue, 21 Sep 2010 02:27:07 +0300
Message-Id: <caff03788e07cab152f750489ea08d43bc13efed.1285024850.git.andy.shevchenko@gmail.com>
In-Reply-To: <ee8a4349cc0eb3a881994b77e1e415b92ff7e669.1285024850.git.andy.shevchenko@gmail.com>
References: <ee8a4349cc0eb3a881994b77e1e415b92ff7e669.1285024850.git.andy.shevchenko@gmail.com>
In-Reply-To: <ee8a4349cc0eb3a881994b77e1e415b92ff7e669.1285024850.git.andy.shevchenko@gmail.com>
References: <ee8a4349cc0eb3a881994b77e1e415b92ff7e669.1285024850.git.andy.shevchenko@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 net/sunrpc/cache.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 5b7b56f..c944a24 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1171,13 +1171,19 @@ int qword_get(char **bpp, char *dest, int bufsize)
 	if (bp[0] == '\\' && bp[1] == 'x') {
 		/* HEX STRING */
 		bp += 2;
-		while (isxdigit(bp[0]) && isxdigit(bp[1]) && len < bufsize) {
-			int byte = isdigit(*bp) ? *bp-'0' : toupper(*bp)-'A'+10;
-			bp++;
-			byte <<= 4;
-			byte |= isdigit(*bp) ? *bp-'0' : toupper(*bp)-'A'+10;
-			*dest++ = byte;
-			bp++;
+		while (len < bufsize) {
+			int h, l;
+
+			h = hex_to_bin(bp[0]);
+			if (h < 0)
+				break;
+
+			l = hex_to_bin(bp[1]);
+			if (l < 0)
+				break;
+
+			*dest++ = (h << 4) | l;
+			bp += 2;
 			len++;
 		}
 	} else {
-- 
1.7.2.2

