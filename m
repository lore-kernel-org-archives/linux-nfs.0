Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:32827 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752719AbdGLO6Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 10:58:16 -0400
Received: by mail-it0-f68.google.com with SMTP id 188so2353826itx.0
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 07:58:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pNFS/flexfiles: Handle expired layout segments in ff_layout_initiate_commit()
Date: Wed, 12 Jul 2017 10:58:06 -0400
Message-Id: <20170712145807.5727-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170712145807.5727-2-trond.myklebust@primarydata.com>
References: <20170712145807.5727-1-trond.myklebust@primarydata.com>
 <20170712145807.5727-2-trond.myklebust@primarydata.com>
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

