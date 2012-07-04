Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57420 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755910Ab2GDXAm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jul 2012 19:00:42 -0400
Received: by eeit10 with SMTP id t10so3034925eei.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jul 2012 16:00:41 -0700 (PDT)
From: Eldad Zack <eldad@fogrefinery.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 1/2] sunrpc/cache.h: fix coding style
Date: Thu,  5 Jul 2012 01:00:25 +0200
Message-Id: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neaten code style in get_int()

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 include/linux/sunrpc/cache.h |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index f5fd616..0757887 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -220,10 +220,16 @@ static inline int get_int(char **bpp, int *anint)
 	char *ep;
 	int rv;
 	int len = qword_get(bpp, buf, 50);
-	if (len < 0) return -EINVAL;
-	if (len ==0) return -ENOENT;
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

