Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f42.google.com ([209.85.214.42]:41161 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161152Ab3DENWk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 09:22:40 -0400
Received: by mail-bk0-f42.google.com with SMTP id jc3so2079667bkc.29
        for <linux-nfs@vger.kernel.org>; Fri, 05 Apr 2013 06:22:39 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 5 Apr 2013 21:22:39 +0800
Message-ID: <CAPgLHd-Op0pJQq5SJi5grQB9EhupYWOf=Udrpt_PUjFsB4j9Uw@mail.gmail.com>
Subject: [PATCH -next] nfsd: make symbol nfsd_reply_cache_shrinker static
From: Wei Yongjun <weiyj.lk@gmail.com>
To: bfields@fieldses.org
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

symbol 'nfsd_reply_cache_shrinker' only used within this file. It should
be static.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 fs/nfsd/nfscache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index f8bb605..890a507 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -56,7 +56,7 @@ static void	cache_cleaner_func(struct work_struct *unused);
 static int 	nfsd_reply_cache_shrink(struct shrinker *shrink,
 					struct shrink_control *sc);
 
-struct shrinker nfsd_reply_cache_shrinker = {
+static struct shrinker nfsd_reply_cache_shrinker = {
 	.shrink	= nfsd_reply_cache_shrink,
 	.seeks	= 1,
 };

