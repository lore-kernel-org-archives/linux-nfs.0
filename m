Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162996AbbKTO4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:56:21 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs4: start callback_ident at idr 1
Date: Fri, 20 Nov 2015 09:56:20 -0500
Message-Id: <da06a514114528e639923b8ef26c0e815e91554f.1448031050.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If clp->cl_cb_ident is zero, then nfs_cb_idr_remove_locked() skips removing
it when the nfs_client is freed.  A decoding or server bug can then find
and try to put that first nfs_client which would lead to a crash.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 223bedd..10410e8 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -33,7 +33,7 @@ static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 		return ret;
 	idr_preload(GFP_KERNEL);
 	spin_lock(&nn->nfs_client_lock);
-	ret = idr_alloc(&nn->cb_ident_idr, clp, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc(&nn->cb_ident_idr, clp, 1, 0, GFP_NOWAIT);
 	if (ret >= 0)
 		clp->cl_cb_ident = ret;
 	spin_unlock(&nn->nfs_client_lock);
-- 
1.7.1

