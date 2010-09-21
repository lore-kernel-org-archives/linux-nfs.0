Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54530 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756077Ab0IUGkp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Sep 2010 02:40:45 -0400
From: Andy Shevchenko <andy.shevchenko@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCHv1.5 2/3] sunrpc/cache: don't use custom hex_to_bin() converter
Date: Tue, 21 Sep 2010 09:40:25 +0300
Message-Id: <9ff9c1f334999e0128fe6426aaad4e9d465f310f.1285051188.git.andy.shevchenko@gmail.com>
In-Reply-To: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
References: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
In-Reply-To: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
References: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
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

