Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48942 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743Ab2H2OLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Aug 2012 10:11:06 -0400
From: Namjae Jeon <linkinjeon@gmail.com>
To: bfields@fieldses.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Namjae Jeon <linkinjeon@gmail.com>,
        Vivek Trivedi <vtrivedi018@gmail.com>
Subject: [PATCH] nfsd: remove duplicate init in nfsd4_cb_recall
Date: Wed, 29 Aug 2012 10:10:53 -0400
Message-Id: <1346249453-3549-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

remove duplicate init in nfsd4_cb_recall

Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
---
 fs/nfsd/nfs4callback.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 4c7bd35..bdf29c9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1028,7 +1028,6 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 	cb->cb_msg.rpc_cred = callback_cred;
 
 	cb->cb_ops = &nfsd4_cb_recall_ops;
-	dp->dl_retries = 1;
 
 	INIT_LIST_HEAD(&cb->cb_per_client);
 	cb->cb_done = true;
-- 
1.7.9.5

