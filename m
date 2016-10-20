Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755389AbcJTQVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 12:21:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: hch@lst.de, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix error handling for clients that fail to return the layout
Date: Thu, 20 Oct 2016 12:21:34 -0400
Message-Id: <1476980494-2984-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when the client continually returns NFS4ERR_DELAY on a
CB_LAYOUTRECALL, we'll give up trying to retransmit after two lease
periods, but leave the layout in place.

What we really need to do here is fence the client in this case. Have it
fall through to that code in that case instead of into the
NFS4ERR_NOMATCHING_LAYOUT case.

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4layouts.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 42aace4fc4c8..596205d939a1 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -686,10 +686,6 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 			return 0;
 		}
 		/* Fallthrough */
-	case -NFS4ERR_NOMATCHING_LAYOUT:
-		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
-		task->tk_status = 0;
-		return 1;
 	default:
 		/*
 		 * Unknown error or non-responding client, we'll need to fence.
@@ -702,6 +698,10 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		else
 			nfsd4_cb_layout_fail(ls);
 		return -1;
+	case -NFS4ERR_NOMATCHING_LAYOUT:
+		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
+		task->tk_status = 0;
+		return 1;
 	}
 }
 
-- 
2.7.4

