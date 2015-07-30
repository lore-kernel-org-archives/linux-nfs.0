Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34854 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbbG3NkU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:40:20 -0400
Received: by pdrg1 with SMTP id g1so24888054pdr.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:40:20 -0700 (PDT)
Message-ID: <55BA2936.4030404@gmail.com>
Date: Thu, 30 Jul 2015 21:40:06 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 1/7] NFS: Remove duplicate svc_xprt_put from nfs41_callback_up
References: <55BA290B.2020704@gmail.com>
In-Reply-To: <55BA290B.2020704@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The xprt created by svc_create_xprt have be added to serv->sv_permsocks.
So putting the xprt directly is useless.
Otherwise, there is a more svc_xprt_put after the xprt be freed.

v2, same as v1.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 682529c..6d27d72 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -162,10 +162,6 @@ nfs41_callback_up(struct svc_serv *serv)
 	spin_lock_init(&serv->sv_cb_lock);
 	init_waitqueue_head(&serv->sv_cb_waitq);
 	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0], NUMA_NO_NODE);
-	if (IS_ERR(rqstp)) {
-		svc_xprt_put(serv->sv_bc_xprt);
-		serv->sv_bc_xprt = NULL;
-	}
 	dprintk("--> %s return %d\n", __func__, PTR_ERR_OR_ZERO(rqstp));
 	return rqstp;
 }
-- 
2.4.3

