Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35395 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811Ab2ARVyI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jan 2012 16:54:08 -0500
Message-ID: <4F173F55.4090509@panasas.com>
Date: Wed, 18 Jan 2012 23:53:25 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <stable@vger.kernel.org>
CC: Greg KH <greg@kroah.com>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Patch Upstream: pnfs-obj: pNFS errors are communicated on iodata->pnfs_error
References: <20120111154700.61EA4262C@git.kroah.org> <20120112231355.GA20151@kroah.com>
In-Reply-To: <20120112231355.GA20151@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/13/2012 01:13 AM, Greg KH wrote:
> 
> Care to provide me such a patch for 3.0?
> 
> thanks,
> 
> greg k-h

Hi this is a 3.1 and 3.0 version of this patch. It is based on todays
stable tree checkout. It will apply cleanly to both linux-3.0.y and
linux-3.1.y branches.

Thanks
Boaz
---
From: Boaz Harrosh <bharrosh@panasas.com>
Subject: pnfs-obj: pNFS errors are communicated on iodata->pnfs_error (linux-3.0.y)

Some time along the way pNFS IO errors were switched to
communicate with a special iodata->pnfs_error member instead
of the regular RPC members. But objlayout was not switched
over.

Fix that!
Without this fix any IO error is hanged, because IO is not
switched to MDS and pages are never cleared or read.

[This is the 3.0.y and 3.1.y equal of mainline [5c0b412] patch]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 1d06f8e..fefa122 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -294,9 +294,11 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
 	dprintk("%s: Begin status=%zd eof=%d\n", __func__, status, eof);
 	rdata = state->rpcdata;
 	rdata->task.tk_status = status;
-	if (status >= 0) {
+	if (likely(status >= 0)) {
 		rdata->res.count = status;
 		rdata->res.eof = eof;
+	} else {
+		rdata->pnfs_error = status;
 	}
 	objlayout_iodone(state);
 	/* must not use state after this point */
@@ -380,15 +382,17 @@ objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
 	wdata = state->rpcdata;
 	state->status = status;
 	wdata->task.tk_status = status;
-	if (status >= 0) {
+	if (likely(status >= 0)) {
 		wdata->res.count = status;
 		wdata->verf.committed = state->committed;
 		dprintk("%s: Return status %d committed %d\n",
 			__func__, wdata->task.tk_status,
 			wdata->verf.committed);
-	} else
+	} else {
+		wdata->pnfs_error = status;
 		dprintk("%s: Return status %d\n",
 			__func__, wdata->task.tk_status);
+	}
 	objlayout_iodone(state);
 	/* must not use state after this point */
 
-- 
1.7.2.3

