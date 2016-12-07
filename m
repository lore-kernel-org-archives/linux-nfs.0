Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32860 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932339AbcLGUma (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2016 15:42:30 -0500
Received: by mail-io0-f195.google.com with SMTP id j92so16260748ioi.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2016 12:42:30 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS/flexfiles: Fix ff_layout_add_ds_error_locked()
Date: Wed,  7 Dec 2016 15:42:25 -0500
Message-Id: <20161207204226.15927-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161207204226.15927-1-trond.myklebust@primarydata.com>
References: <20161207204226.15927-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we're merging an old entry into our new entry, we want to ensure that
we add the list entry in the correct place.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index eb98395c3651..142bfd0b1663 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -254,8 +254,9 @@ ff_layout_add_ds_error_locked(struct nfs4_flexfile_layout *flo,
 		}
 		/* Entries match, so merge "err" into "dserr" */
 		extend_ds_error(dserr, err->offset, err->length);
-		list_del(&err->list);
+		list_replace(&err->list, &dserr->list);
 		kfree(err);
+		return;
 	}
 
 	list_add_tail(&dserr->list, head);
-- 
2.9.3

