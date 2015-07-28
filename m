Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34828 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbbG1LM7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:12:59 -0400
Received: by pabkd10 with SMTP id kd10so68502131pab.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:12:58 -0700 (PDT)
Message-ID: <55B763AF.6080804@gmail.com>
Date: Tue, 28 Jul 2015 19:12:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Andy Adamson <andros@netapp.com>, kinglongmee@gmail.com
Subject: [PATCH 1/5] NFS: Remove duplicate svc_xprt_put from nfs41_callback_up
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The xprt created by svc_create_xprt have be added to serv->sv_permsocks.
So putting the xprt directly is useless.
Otherwise, there is a more svc_xprt_put after the xprt be freed.

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

