Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64060 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756009Ab2GDXAs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jul 2012 19:00:48 -0400
Received: by mail-ee0-f46.google.com with SMTP id t10so3034926eei.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jul 2012 16:00:48 -0700 (PDT)
From: Eldad Zack <eldad@fogrefinery.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 2/2] sunrpc/cache.h: replace simple_strtoul
Date: Thu,  5 Jul 2012 01:00:26 +0200
Message-Id: <1341442827-21339-2-git-send-email-eldad@fogrefinery.com>
In-Reply-To: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com>
References: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces the usage of simple_strtoul with kstrtoint in
get_int().

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 include/linux/sunrpc/cache.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 0757887..9a60bcc 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -217,7 +217,7 @@ extern int qword_get(char **bpp, char *dest, int bufsize);
 static inline int get_int(char **bpp, int *anint)
 {
 	char buf[50];
-	char *ep;
+	ssize_t ret;
 	int rv;
 	int len = qword_get(bpp, buf, 50);
 
@@ -226,8 +226,8 @@ static inline int get_int(char **bpp, int *anint)
 	if (len == 0)
 		return -ENOENT;
 
-	rv = simple_strtol(buf, &ep, 0);
-	if (*ep)
+	ret = kstrtoint(buf, 0, &rv);
+	if (ret)
 		return -EINVAL;
 
 	*anint = rv;
-- 
1.7.10

