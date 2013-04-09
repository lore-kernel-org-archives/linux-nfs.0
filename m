Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f47.google.com ([209.85.214.47]:51022 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759044Ab3DIGPd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2013 02:15:33 -0400
Received: by mail-bk0-f47.google.com with SMTP id ik5so3365436bkc.20
        for <linux-nfs@vger.kernel.org>; Mon, 08 Apr 2013 23:15:32 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 9 Apr 2013 14:15:31 +0800
Message-ID: <CAPgLHd_A_6Za0rOZDdrrKSpB39MquPVgUrAgXO=57T6xYyjcKA@mail.gmail.com>
Subject: [PATCH] nfsd: use kmem_cache_free() instead of kfree()
From: Wei Yongjun <weiyj.lk@gmail.com>
To: bfields@fieldses.org
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

memory allocated by kmem_cache_alloc() should be freed using
kmem_cache_free(), not kfree().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e27430..06a520b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -267,7 +267,7 @@ kmem_cache *slab)
 		min_stateid = 0;
 	return stid;
 out_free:
-	kfree(stid);
+	kmem_cache_free(slab, stid);
 	return NULL;
 }
 

