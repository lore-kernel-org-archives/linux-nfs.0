Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:45402 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725944AbeHTKLL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Aug 2018 06:11:11 -0400
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [IPv6:2001:638:700:1038::1:a4])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id D29CA2807D6
        for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2018 08:56:44 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: trondmy@hammerspace.com, Anna.Schumaker@Netapp.com,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly coupled DSes
Date: Mon, 20 Aug 2018 08:56:08 +0200
Message-Id: <20180820065608.11860-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

for tightly coupled DSes client must ignore provided synthetic uid and
gid as stated in draft-ietf-nfsv4-flex-files-19#section-5.1.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index d62279d3fc5d..290625cfd369 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -452,7 +452,7 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
 	struct rpc_cred *cred;
 
-	if (mirror) {
+	if (mirror && !mirror->mirror_ds->ds_versions[0].tightly_coupled) {
 		cred = ff_layout_get_mirror_cred(mirror, lseg->pls_range.iomode);
 		if (!cred)
 			cred = get_rpccred(mdscred);
-- 
2.17.1
