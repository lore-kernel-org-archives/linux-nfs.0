Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36730 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbdASIh5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jan 2017 03:37:57 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so3622685pgf.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2017 00:36:59 -0800 (PST)
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH v2 1/2] NFSv4.x/callback: Create the callback service through
 svc_create_pooled
Message-ID: <322d5c7d-d3b4-1e02-de3f-8e1a900cb150@gmail.com>
Date: Thu, 19 Jan 2017 16:36:51 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As the comments for svc_set_num_threads() said, 
" Destroying threads relies on the service threads filling in
rqstp->rq_task, which only the nfs ones do.  Assumes the serv
has been created using svc_create_pooled()."

If creating service through svc_create(), the svc_pool_map_put()
will be called in svc_destroy(), but the pool map isn't used.
So that, the reference of pool map will be drop, the next using
of pool map will get a zero npools. 

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 484bebc..0a21150 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -279,7 +279,7 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
 		printk(KERN_WARNING "nfs_callback_create_svc: no kthread, %d users??\n",
 			cb_info->users);
 
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, sv_ops);
+	serv = svc_create_pooled(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, sv_ops);
 	if (!serv) {
 		printk(KERN_ERR "nfs_callback_create_svc: create service failed\n");
 		return ERR_PTR(-ENOMEM);
-- 
2.9.3

