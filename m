Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:7787 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbaK1Pum (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Nov 2014 10:50:42 -0500
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] sunrpc/cache: convert to use string_escape_str()
Date: Fri, 28 Nov 2014 17:50:28 +0200
Message-Id: <1417189828-25688-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is nice kernel helper to escape a given strings by provided rules. Let's
use it instead of custom approach.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/sunrpc/cache.c | 27 ++++++---------------------
 1 file changed, 6 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 0663621..5cf60a4 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -20,6 +20,7 @@
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/ctype.h>
+#include <linux/string_helpers.h>
 #include <asm/uaccess.h>
 #include <linux/poll.h>
 #include <linux/seq_file.h>
@@ -1067,32 +1068,16 @@ void qword_add(char **bpp, int *lp, char *str)
 {
 	char *bp = *bpp;
 	int len = *lp;
-	char c;
+	int ret;
 
 	if (len < 0) return;
 
-	while ((c=*str++) && len)
-		switch(c) {
-		case ' ':
-		case '\t':
-		case '\n':
-		case '\\':
-			if (len >= 4) {
-				*bp++ = '\\';
-				*bp++ = '0' + ((c & 0300)>>6);
-				*bp++ = '0' + ((c & 0070)>>3);
-				*bp++ = '0' + ((c & 0007)>>0);
-			}
-			len -= 4;
-			break;
-		default:
-			*bp++ = c;
-			len--;
-		}
-	if (c || len <1) len = -1;
+	ret = string_escape_str(str, &bp, len, ESCAPE_OCTAL, "\\ \n\t");
+	if (ret < 0 || ret == len)
+		len = -1;
 	else {
 		*bp++ = ' ';
-		len--;
+		len -= ret - 1;
 	}
 	*bpp = bp;
 	*lp = len;
-- 
2.1.3

