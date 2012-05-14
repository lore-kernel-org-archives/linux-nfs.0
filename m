Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:26732 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757606Ab2ENTph (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2012 15:45:37 -0400
Date: Mon, 14 May 2012 22:45:28 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] NFS: kmalloc() doesn't return an ERR_PTR()
Message-ID: <20120514194528.GA19613@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Obviously we should check for NULL here instead of IS_ERR().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index ba3019f..233beea 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -644,14 +644,14 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 
 	/* msg and im are freed in idmap_pipe_destroy_msg */
 	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
-	if (IS_ERR(msg)) {
-		ret = PTR_ERR(msg);
+	if (!msg) {
+		ret = -ENOMEM;
 		goto out0;
 	}
 
 	im = kmalloc(sizeof(*im), GFP_KERNEL);
-	if (IS_ERR(im)) {
-		ret = PTR_ERR(im);
+	if (!im) {
+		ret = -ENOMEM;
 		goto out1;
 	}
 
