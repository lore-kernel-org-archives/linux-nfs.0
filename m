Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36547 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbcF1TDF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2016 15:03:05 -0400
Received: by mail-io0-f195.google.com with SMTP id s63so2953102ioi.3
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2016 12:03:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS/pnfs: Do not clobber existing pgio_done_cb in nfs4_proc_read_setup
Date: Tue, 28 Jun 2016 15:02:19 -0400
Message-Id: <1467140539-9130-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a pNFS client sets hdr->pgio_done_cb, then we should not overwrite that
in nfs4_proc_read_setup()

Fixes: 75bf47ebf6b5 ("pNFS/flexfile: Fix erroneous fall back to...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 995c2829ac6f..519368b98762 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4405,7 +4405,8 @@ static void nfs4_proc_read_setup(struct nfs_pgio_header *hdr,
 				 struct rpc_message *msg)
 {
 	hdr->timestamp   = jiffies;
-	hdr->pgio_done_cb = nfs4_read_done_cb;
+	if (!hdr->pgio_done_cb)
+		hdr->pgio_done_cb = nfs4_read_done_cb;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
 	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 0);
 }
-- 
2.7.4

