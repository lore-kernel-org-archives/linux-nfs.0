Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33579 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbbIBWe4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2015 18:34:56 -0400
Received: by pacex6 with SMTP id ex6so19674300pac.0
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2015 15:34:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1/flexfiles: Clean up ff_layout_write_done_cb/ff_layout_commit_done_cb
Date: Wed,  2 Sep 2015 15:34:53 -0700
Message-Id: <1441233293-10911-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1441233293-10911-1-git-send-email-trond.myklebust@primarydata.com>
References: <1441233293-10911-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3f073a7de870..fbc5a56de875 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1342,14 +1342,12 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
+		pnfs_set_retry_layoutget(hdr->lseg->pls_layout);
+		ff_layout_reset_write(hdr, true);
+		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
-		if (err == -NFS4ERR_RESET_TO_PNFS) {
-			pnfs_set_retry_layoutget(hdr->lseg->pls_layout);
-			ff_layout_reset_write(hdr, true);
-		} else {
-			pnfs_clear_retry_layoutget(hdr->lseg->pls_layout);
-			ff_layout_reset_write(hdr, false);
-		}
+		pnfs_clear_retry_layoutget(hdr->lseg->pls_layout);
+		ff_layout_reset_write(hdr, false);
 		return task->tk_status;
 	case -EAGAIN:
 		rpc_restart_call_prepare(task);
@@ -1384,11 +1382,11 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
+		pnfs_set_retry_layoutget(data->lseg->pls_layout);
+		pnfs_generic_prepare_to_resend_writes(data);
+		return -EAGAIN;
 	case -NFS4ERR_RESET_TO_MDS:
-		if (err == -NFS4ERR_RESET_TO_PNFS)
-			pnfs_set_retry_layoutget(data->lseg->pls_layout);
-		else
-			pnfs_clear_retry_layoutget(data->lseg->pls_layout);
+		pnfs_clear_retry_layoutget(data->lseg->pls_layout);
 		pnfs_generic_prepare_to_resend_writes(data);
 		return -EAGAIN;
 	case -EAGAIN:
-- 
2.4.3

