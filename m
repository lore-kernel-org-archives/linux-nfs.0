Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f47.google.com ([209.85.214.47]:33661 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161152Ab3DENVr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 09:21:47 -0400
Received: by mail-bk0-f47.google.com with SMTP id ik5so2060156bkc.34
        for <linux-nfs@vger.kernel.org>; Fri, 05 Apr 2013 06:21:46 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 5 Apr 2013 21:21:46 +0800
Message-ID: <CAPgLHd-D4OmKTRt6ChOi6eJROTmiOsoTG+kB5oOBeea9XOtSPA@mail.gmail.com>
Subject: [PATCH -next] nfsd4: make local function put_client_renew_locked() static
From: Wei Yongjun <weiyj.lk@gmail.com>
To: bfields@fieldses.org
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

put_client_renew_locked() only used within this file. It should be static.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2fd0155..3225544 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -192,7 +192,7 @@ renew_client(struct nfs4_client *clp)
 	spin_unlock(&nn->client_lock);
 }
 
-void put_client_renew_locked(struct nfs4_client *clp)
+static void put_client_renew_locked(struct nfs4_client *clp)
 {
 	if (!atomic_dec_and_test(&clp->cl_refcount))
 		return;

