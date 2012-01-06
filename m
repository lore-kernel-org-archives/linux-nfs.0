Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54585 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab2AFHff (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 02:35:35 -0500
Message-ID: <4F06A28C.7050003@panasas.com>
Date: Fri, 6 Jan 2012 09:28:12 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, Fred Isaman <iisaman@netapp.com>
CC: Stable Tree <stable@kernel.org>
Subject: [PATCH 1/2] pnfs-obj: pNFS errors are communicated on iodata->pnfs_error
References: <4F06A18E.4010706@panasas.com>
In-Reply-To: <4F06A18E.4010706@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Some time along the way pNFS IO errors were switched to
communicate with a special iodata->pnfs_error member instead
of the regular RPC members. But objlayout was not switched
over.

Fix that!
Without this fix any IO error is hanged, because IO is not
switched to MDS and pages are never cleared or read.

[Applies to 3.2.0. Same bug different patch for 3.1/0 Kernels]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 72074e3..b3c2903 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -254,6 +254,8 @@ objlayout_read_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	oir->status = rdata->task.tk_status = status;
 	if (status >= 0)
 		rdata->res.count = status;
+	else
+		rdata->pnfs_error = status;
 	objlayout_iodone(oir);
 	/* must not use oir after this point */
 
@@ -334,6 +336,8 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	if (status >= 0) {
 		wdata->res.count = status;
 		wdata->verf.committed = oir->committed;
+	} else {
+		wdata->pnfs_error = status;
 	}
 	objlayout_iodone(oir);
 	/* must not use oir after this point */
-- 
1.7.2.3


