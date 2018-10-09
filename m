Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f68.google.com ([209.85.166.68]:43450 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727729AbeJJDN7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2018 23:13:59 -0400
Received: by mail-io1-f68.google.com with SMTP id y10-v6so2137112ioa.10
        for <linux-nfs@vger.kernel.org>; Tue, 09 Oct 2018 12:55:25 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: J Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Fix an Oops in free_session()
Date: Tue,  9 Oct 2018 15:54:15 -0400
Message-Id: <20181009195415.8741-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In call_xpt_users(), we delete the entry from the list, but we
do not reinitialise it. This triggers the list poisoning when
we later call unregister_xpt_user() in nfsd4_del_conns().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/svc_xprt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 4af77b660fca..d34fea564945 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1089,7 +1089,7 @@ static void call_xpt_users(struct svc_xprt *xprt)
 	spin_lock(&xprt->xpt_lock);
 	while (!list_empty(&xprt->xpt_users)) {
 		u = list_first_entry(&xprt->xpt_users, struct svc_xpt_user, list);
-		list_del(&u->list);
+		list_del_init(&u->list);
 		u->callback(u);
 	}
 	spin_unlock(&xprt->xpt_lock);
-- 
2.17.1
