Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38055 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753582Ab1EIRLN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:11:13 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 25/29] pnfs-obj: objio_osd report osd_errors for layoutreturn
Date: Mon,  9 May 2011 20:11:07 +0300
Message-Id: <1304961067-4719-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

* Allocate io-error descriptors space as part of io_state
* Use generic objlayout error reporting at end of io.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 023f2b2..9c9dc9a 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -319,13 +319,17 @@ int objio_alloc_io_state(void *seg, struct objlayout_io_state **outp)
 	struct objio_state *ios;
 	const unsigned first_size = sizeof(*ios) +
 				objio_seg->num_comps * sizeof(ios->per_dev[0]);
+	const unsigned sec_size = objio_seg->num_comps *
+						sizeof(ios->ol_state.ioerrs[0]);
 
 	dprintk("%s: num_comps=%d\n", __func__, objio_seg->num_comps);
-	ios = kzalloc(first_size, GFP_KERNEL);
+	ios = kzalloc(first_size + sec_size, GFP_KERNEL);
 	if (unlikely(!ios))
 		return -ENOMEM;
 
 	ios->objio_seg = objio_seg;
+	ios->ol_state.ioerrs = ((void *)ios) + first_size;
+	ios->ol_state.num_comps = objio_seg->num_comps;
 
 	*outp = &ios->ol_state;
 	return 0;
@@ -412,6 +416,10 @@ static int _io_check(struct objio_state *ios, bool is_write)
 
 			continue; /* we recovered */
 		}
+		objlayout_io_set_result(&ios->ol_state, i,
+					osd_pri_2_pnfs_err(osi.osd_err_pri),
+					ios->ol_state.offset, ios->length,
+					is_write);
 
 		if (osi.osd_err_pri >= oep) {
 			oep = osi.osd_err_pri;
-- 
1.7.3.4

