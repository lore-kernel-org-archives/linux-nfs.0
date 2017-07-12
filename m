Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35949 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdGLXLI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 19:11:08 -0400
Received: by mail-it0-f67.google.com with SMTP id k3so4446613ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 16:11:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/4] pNFS/flexfiles: Handle expired layout segments in ff_layout_initiate_commit()
Date: Wed, 12 Jul 2017 19:10:58 -0400
Message-Id: <20170712231059.32293-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170712231059.32293-3-trond.myklebust@primarydata.com>
References: <20170712231059.32293-1-trond.myklebust@primarydata.com>
 <20170712231059.32293-2-trond.myklebust@primarydata.com>
 <20170712231059.32293-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout has expired due to a fencing event, then we should not
attempt to commit to the DS.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 23542dc44a25..d41e1f2c5991 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1875,6 +1875,10 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	int vers, ret;
 	struct nfs_fh *fh;
 
+	if (!lseg || !(pnfs_is_valid_lseg(lseg) ||
+	    test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags)))
+		goto out_err;
+
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
 	ds = nfs4_ff_layout_prepare_ds(lseg, idx, true);
 	if (!ds)
-- 
2.13.0

