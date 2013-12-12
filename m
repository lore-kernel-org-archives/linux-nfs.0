Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:9002 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab3LLNtw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 08:49:52 -0500
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] net/sunrpc/cache: simplify code by using hex_pack_byte()
Date: Thu, 12 Dec 2013 15:49:21 +0200
Message-Id: <1386856161-29889-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hex_pack_byte() is a fast way to convert a byte in its ASCII representation. We
may use it instead of custom approach.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/sunrpc/cache.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a72de07..0877db0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1111,9 +1111,7 @@ void qword_addhex(char **bpp, int *lp, char *buf, int blen)
 		*bp++ = 'x';
 		len -= 2;
 		while (blen && len >= 2) {
-			unsigned char c = *buf++;
-			*bp++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'9'-1);
-			*bp++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'9'-1);
+			bp = hex_byte_pack(bp, *buf++);
 			len -= 2;
 			blen--;
 		}
-- 
1.8.4.4

