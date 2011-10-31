Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43775 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166Ab1JaVpT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 17:45:19 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Brent Welch <welch@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 1/8] pnfs-obj: Remove redundant EOF from objlayout_io_state
Date: Mon, 31 Oct 2011 14:45:06 -0700
Message-ID: <1320097506-734-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4EAF146D.5060507@panasas.com>
References: <4EAF146D.5060507@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The EOF calculation was done on .read_pagelist(), cached
in objlayout_io_state->eof, and set in objlayout_read_done()
into nfs_read_data->res.eof.

So set it directly into nfs_read_data->res.eof and avoid
the extra member.

This is a slight behaviour change because before eof was
*not* set on an error update at objlayout_read_done(). But
is that a problem? Is Generic layer so sensitive that it
will miss the error IO if eof was set? From my testing
I did not see such a problem.

Benny please review.

Which brings me to a more abstract problem. Why does the
LAYOUT driver needs to do this eof calculation? .i.e we
are inspecting generic i_size_read() and if spanned by
offset + count which is received from generic layer we set
eof. It looks like all this can/should be done in generic
layer and not at LD. Where does NFS and files-LD do it?
It looks like it can be promoted.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |   16 +++++++---------
 fs/nfs/objlayout/objlayout.h |    1 -
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 1d06f8e..1300736 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -287,17 +287,14 @@ static void _rpc_read_complete(struct work_struct *work)
 void
 objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
 {
-	int eof = state->eof;
-	struct nfs_read_data *rdata;
+	struct nfs_read_data *rdata = state->rpcdata;
 
 	state->status = status;
-	dprintk("%s: Begin status=%zd eof=%d\n", __func__, status, eof);
-	rdata = state->rpcdata;
+	dprintk("%s: Begin status=%zd eof=%d\n", __func__,
+		status, rdata->res.eof);
 	rdata->task.tk_status = status;
-	if (status >= 0) {
+	if (status >= 0)
 		rdata->res.count = status;
-		rdata->res.eof = eof;
-	}
 	objlayout_iodone(state);
 	/* must not use state after this point */
 
@@ -330,11 +327,14 @@ enum pnfs_try_status
 			status = 0;
 			rdata->res.count = 0;
 			rdata->res.eof = 1;
+			/*FIXME: do we need to call pnfs_ld_read_done() */
 			goto out;
 		}
 		count = eof - offset;
 	}
 
+	rdata->res.eof = (offset + count) >= eof;
+
 	state = objlayout_alloc_io_state(NFS_I(rdata->inode)->layout,
 					 rdata->args.pages, rdata->args.pgbase,
 					 offset, count,
@@ -345,8 +345,6 @@ enum pnfs_try_status
 		goto out;
 	}
 
-	state->eof = state->offset + state->count >= eof;
-
 	status = objio_read_pagelist(state);
  out:
 	dprintk("%s: Return status %Zd\n", __func__, status);
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index a8244c8..ffb884c 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -86,7 +86,6 @@ struct objlayout_io_state {
 
 	void *rpcdata;
 	int status;             /* res */
-	int eof;                /* res */
 	int committed;          /* res */
 
 	/* Error reporting (layout_return) */
-- 
1.7.6.4

