Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54086 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab1FPPif (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 11:38:35 -0400
Message-ID: <4DFA2374.1090008@panasas.com>
Date: Thu, 16 Jun 2011 11:38:28 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] SQUASHME: pnfs-obj: mds_offset is set in the generic
 layer
References: <4DF9278A.5010103@panasas.com>
In-Reply-To: <4DF9278A.5010103@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Benny you can just remove the previous patch that adds it:
	b5157c1 FIXME: BUG wdata->mds_offset never gets set

This patch is just a reminder

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index e76cdab..1d06f8e 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -430,8 +430,6 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	status = objio_write_pagelist(state, how & FLUSH_STABLE);
  out:
 	dprintk("%s: Return status %Zd\n", __func__, status);
-	/* pnfs_set_layoutcommit needs this */
-	wdata->mds_offset = wdata->args.offset;
 	wdata->pnfs_error = status;
 	return PNFS_ATTEMPTED;
 }
-- 
1.7.3.4


