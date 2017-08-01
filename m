Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33657 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752025AbdHAUZV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 16:25:21 -0400
Received: by mail-it0-f66.google.com with SMTP id m34so2440350iti.0
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 13:25:20 -0700 (PDT)
From: Weston Andros Adamson <dros@monkey.org>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] nfs/flexfiles: fix leak of nfs4_ff_ds_version arrays
Date: Tue,  1 Aug 2017 16:25:01 -0400
Message-Id: <20170801202501.4876-1-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client was freeing the nfs4_ff_layout_ds, but not the contained
nfs4_ff_ds_version array.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 6df7a0cf5660..f32c58bbe556 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -32,6 +32,7 @@ void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds *mirror_ds)
 {
 	nfs4_print_deviceid(&mirror_ds->id_node.deviceid);
 	nfs4_pnfs_ds_put(mirror_ds->ds);
+	kfree(mirror_ds->ds_versions);
 	kfree_rcu(mirror_ds, id_node.rcu);
 }
 
-- 
2.11.0 (Apple Git-81)

