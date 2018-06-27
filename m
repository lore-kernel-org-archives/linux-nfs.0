Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34475 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965736AbeF0SSw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2018 14:18:52 -0400
Received: by mail-io0-f193.google.com with SMTP id e15-v6so2778231iog.1
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 11:18:52 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([50.105.87.45])
        by smtp.gmail.com with ESMTPSA id x5-v6sm2105233ioa.65.2018.06.27.11.18.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 11:18:51 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] pNFS: Don't update the stateid when replying NFS4ERR_DELAY to a layout recall
Date: Wed, 27 Jun 2018 14:18:25 -0400
Message-Id: <20180627181828.27680-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180627181828.27680-1-trond.myklebust@hammerspace.com>
References: <20180627181828.27680-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 doesn't state directly that the client should update the layout
stateid if it returns NFS4ERR_NOMATCHING_LAYOUT in response to a recall,
however it does state that this error will "cleanly indicate completion"
on par with returning the layout. For this reason, we assume that the
client should update the layout stateid. The Linux pNFS server definitely
does expect this behaviour.

However, if the client replies NFS4ERR_DELAY, then it is stating that
the recall was not processed, so it would be very wrong to update the
layout stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index af2322256aa4..efca3d6c89f2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -273,7 +273,6 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	rv = pnfs_check_callback_stateid(lo, &args->cbl_stateid);
 	if (rv != NFS_OK)
 		goto unlock;
-	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 
 	/*
 	 * Enforce RFC5661 Section 12.5.5.2.1.5 (Bulk Recall and Return)
@@ -283,6 +282,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto unlock;
 	}
 
+	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	switch (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
 				&args->cbl_range,
 				be32_to_cpu(args->cbl_stateid.seqid))) {
-- 
2.17.1

