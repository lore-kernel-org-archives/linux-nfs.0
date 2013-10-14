Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:49441 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab3JNTMH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 15:12:07 -0400
From: "Geyslan G. Bem" <geyslan@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-br@googlegroups.com, "Geyslan G. Bem" <geyslan@gmail.com>
Subject: [PATCH] nfs: Use PTR_ERR_OR_ZERO in 'nfs41_callback_up' function
Date: Mon, 14 Oct 2013 16:07:40 -0300
Message-Id: <1381777661-28780-1-git-send-email-geyslan@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use 'PTR_ERR_OR_ZERO()' rather than 'IS_ERR(...) ? PTR_ERR(...) : 0'.

Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>
---
 fs/nfs/callback.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 67cd732..1c9e867 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -164,8 +164,7 @@ nfs41_callback_up(struct svc_serv *serv)
 		svc_xprt_put(serv->sv_bc_xprt);
 		serv->sv_bc_xprt = NULL;
 	}
-	dprintk("--> %s return %ld\n", __func__,
-		IS_ERR(rqstp) ? PTR_ERR(rqstp) : 0);
+	dprintk("--> %s return %ld\n", __func__, PTR_ERR_OR_ZERO(rqstp));
 	return rqstp;
 }
 
-- 
1.8.4

