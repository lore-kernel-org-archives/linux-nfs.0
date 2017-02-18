Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34583 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdBRAuV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2017 19:50:21 -0500
Received: by mail-it0-f65.google.com with SMTP id r141so5172266ita.1
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2017 16:50:21 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Revert "NFSv4.1: Handle NFS4ERR_BADSESSION/NFS4ERR_DEADSESSION replies to OP_SEQUENCE"
Date: Fri, 17 Feb 2017 19:50:18 -0500
Message-Id: <20170218005018.65046-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 2cf10cdd486c362f983abdce00dc1127e8ab8c59.

The patch has been seen to cause excessive looping.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 944e447893af..23019edfd3f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -815,10 +815,6 @@ static int nfs41_sequence_process(struct rpc_task *task,
 	case -NFS4ERR_SEQ_FALSE_RETRY:
 		++slot->seq_nr;
 		goto retry_nowait;
-	case -NFS4ERR_DEADSESSION:
-	case -NFS4ERR_BADSESSION:
-		nfs4_schedule_session_recovery(session, res->sr_status);
-		goto retry_nowait;
 	default:
 		/* Just update the slot sequence no. */
 		slot->seq_done = 1;
-- 
2.9.3

