Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:44722 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbaC2A3w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Mar 2014 20:29:52 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so5677278iec.11
        for <linux-nfs@vger.kernel.org>; Fri, 28 Mar 2014 17:29:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a use-after-free problem in open()
Date: Fri, 28 Mar 2014 20:29:49 -0400
Message-Id: <1396052989-3485-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we interrupt the nfs4_wait_for_completion_rpc_task() call in
nfs4_run_open_task(), then we don't prevent the RPC call from
completing. So freeing up the opendata->f_attr.mdsthreshold
in the error path in _nfs4_do_open() leads to a use-after-free
when the XDR decoder tries to decode the mdsthreshold information
from the server.

Fixes: 82be417aa37c0 (NFSv4.1 cache mdsthreshold values on OPEN)
Tested-by: Steve Dickson <SteveD@redhat.com>
Cc: stable@vger.kernel.org # 3.5+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c866e325577f..397be39c6dc8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1068,6 +1068,7 @@ static void nfs4_opendata_free(struct kref *kref)
 	dput(p->dentry);
 	nfs_sb_deactive(sb);
 	nfs_fattr_free_names(&p->f_attr);
+	kfree(p->f_attr.mdsthreshold);
 	kfree(p);
 }
 
@@ -2304,10 +2305,12 @@ static int _nfs4_do_open(struct inode *dir,
 		}
 	}
 
-	if (ctx_th && server->attr_bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD) {
-		opendata->f_attr.mdsthreshold = pnfs_mdsthreshold_alloc();
-		if (!opendata->f_attr.mdsthreshold)
-			goto err_free_label;
+	if (server->attr_bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD) {
+		if (!opendata->f_attr.mdsthreshold) {
+			opendata->f_attr.mdsthreshold = pnfs_mdsthreshold_alloc();
+			if (!opendata->f_attr.mdsthreshold)
+				goto err_free_label;
+		}
 		opendata->o_arg.open_bitmap = &nfs4_pnfs_open_bitmap[0];
 	}
 	if (dentry->d_inode != NULL)
@@ -2335,11 +2338,10 @@ static int _nfs4_do_open(struct inode *dir,
 	if (opendata->file_created)
 		*opened |= FILE_CREATED;
 
-	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server))
+	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server)) {
 		*ctx_th = opendata->f_attr.mdsthreshold;
-	else
-		kfree(opendata->f_attr.mdsthreshold);
-	opendata->f_attr.mdsthreshold = NULL;
+		opendata->f_attr.mdsthreshold = NULL;
+	}
 
 	nfs4_label_free(olabel);
 
@@ -2349,7 +2351,6 @@ static int _nfs4_do_open(struct inode *dir,
 err_free_label:
 	nfs4_label_free(olabel);
 err_opendata_put:
-	kfree(opendata->f_attr.mdsthreshold);
 	nfs4_opendata_put(opendata);
 err_put_state_owner:
 	nfs4_put_state_owner(sp);
-- 
1.9.0

