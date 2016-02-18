Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946936AbcBRSz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2016 13:55:57 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 219AE821C3
	for <linux-nfs@vger.kernel.org>; Thu, 18 Feb 2016 18:55:57 +0000 (UTC)
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] sunrpc/cache: fix off-by-one in qword_get()
Date: Thu, 18 Feb 2016 18:55:54 +0000
Message-Id: <1455821754-24940-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The qword_get() function NUL-terminates its output buffer.  If the input
string is in hex format \xXXXX... and the same length as the output
buffer, there is an off-by-one:

  int qword_get(char **bpp, char *dest, int bufsize)
  {
      ...
      while (len < bufsize) {
          ...
          *dest++ = (h << 4) | l;
          len++;
      }
      ...
      *dest = '\0';
      return len;
  }

This patch ensures the NUL terminator doesn't fall outside the output
buffer.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2b32fd6..273bc3a 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1225,7 +1225,7 @@ int qword_get(char **bpp, char *dest, int bufsize)
 	if (bp[0] == '\\' && bp[1] == 'x') {
 		/* HEX STRING */
 		bp += 2;
-		while (len < bufsize) {
+		while (len < bufsize - 1) {
 			int h, l;
 
 			h = hex_to_bin(bp[0]);
-- 
2.5.0

