Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:1646 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383Ab1FOVnr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2011 17:43:47 -0400
Message-ID: <4DF9278A.5010103@panasas.com>
Date: Wed, 15 Jun 2011 17:43:38 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] FIXME: BUG wdata->mds_offset never gets set
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The fileslayout and blockslayout drivers had a set of
wdata->mds_offset in their .write_pagelist member.

The objects driver did not. Which breaks layout_commit.

FIXME: Since all drivers set mds_offset in exactly the same place
to the same value. And then never touch it. It calls for the
generic layer to take care of it.
(I'll send the fix tomorrow)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index dc3956c..96dd474 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -430,6 +430,8 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	status = objio_write_pagelist(state, how & FLUSH_STABLE);
  out:
 	dprintk("%s: Return status %Zd\n", __func__, status);
+	/* pnfs_set_layoutcommit needs this */
+	wdata->mds_offset = wdata->args.offset;
 	wdata->pnfs_error = status;
 	return PNFS_ATTEMPTED;
 }
-- 
1.7.3.4

