Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34804 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757567Ab2GFTcY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jul 2012 15:32:24 -0400
Received: by bkwj10 with SMTP id j10so4699647bkw.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jul 2012 12:32:23 -0700 (PDT)
From: Eldad Zack <eldad@fogrefinery.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Joe Perches <joe@perches.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 1/2, resend] sunrpc/cache.h: fix coding style
Date: Fri,  6 Jul 2012 21:31:56 +0200
Message-Id: <1341603117-13064-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neaten code style in get_int().
Also use sizeof() instead of hard coded number as suggested by
Joe Perches <joe@perches.com>.

Cc: Joe Perches <joe@perches.com>
Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
Resent to include improvements from Joe Perches.
 include/linux/sunrpc/cache.h |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index f5fd616..6def1f6 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -219,11 +219,17 @@ static inline int get_int(char **bpp, int *anint)
 	char buf[50];
 	char *ep;
 	int rv;
-	int len = qword_get(bpp, buf, 50);
-	if (len < 0) return -EINVAL;
-	if (len ==0) return -ENOENT;
+	int len = qword_get(bpp, buf, sizeof(buf));
+
+	if (len < 0)
+		return -EINVAL;
+	if (len == 0)
+		return -ENOENT;
+
 	rv = simple_strtol(buf, &ep, 0);
-	if (*ep) return -EINVAL;
+	if (*ep)
+		return -EINVAL;
+
 	*anint = rv;
 	return 0;
 }
-- 
1.7.10

