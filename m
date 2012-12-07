Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:62995 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2LGLwE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2012 06:52:04 -0500
From: Abhijit Pawar <abhi.c.pawar@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Abhijit Pawar <abhi.c.pawar@gmail.com>
Subject: [PATCH 3/4] include/sunrpc: remove obsolete simple_strto<foo>
Date: Fri,  7 Dec 2012 17:21:36 +0530
Message-Id: <1354881096-23480-1-git-send-email-abhi.c.pawar@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replace the obsolete simple_strto<foo> with kstrto<foo>

Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
---
 include/linux/sunrpc/cache.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 5dc9ee4..96d2545 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -218,7 +218,7 @@ static inline int get_int(char **bpp, int *anint)
 {
 	char buf[50];
 	char *ep;
-	int rv;
+	int rv, rc;
 	int len = qword_get(bpp, buf, sizeof(buf));
 
 	if (len < 0)
@@ -226,8 +226,8 @@ static inline int get_int(char **bpp, int *anint)
 	if (len == 0)
 		return -ENOENT;
 
-	rv = simple_strtol(buf, &ep, 0);
-	if (*ep)
+	rc = kstrtoint(buf, 0, &rv);
+	if (rc)
 		return -EINVAL;
 
 	*anint = rv;
-- 
1.7.7.6

