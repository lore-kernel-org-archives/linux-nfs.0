Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32924 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdALPj0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 10:39:26 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so4025725pfg.0
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 07:39:25 -0800 (PST)
From: Wei Yongjun <weiyj.lk@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-nfs@vger.kernel.org
Subject: [PATCH -next] NFSv4: Fix warning for using 0 as NULL
Date: Thu, 12 Jan 2017 15:39:18 +0000
Message-Id: <20170112153918.27888-1-weiyj.lk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

fs/nfs/nfs4state.c:862:60: warning: Using plain integer as NULL pointer

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 26b6b8b..64385b6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -859,7 +859,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
 	
 	for(;;) {
 		spin_lock(&state->state_lock);
-		lsp = __nfs4_find_lock_state(state, owner, 0);
+		lsp = __nfs4_find_lock_state(state, owner, NULL);
 		if (lsp != NULL)
 			break;
 		if (new != NULL) {



