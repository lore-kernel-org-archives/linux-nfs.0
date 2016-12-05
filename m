Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33314 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcLEAyR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2016 19:54:17 -0500
Received: by mail-io0-f195.google.com with SMTP id j92so19401981ioi.0
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2016 16:54:17 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1: Handle NFS4ERR_BADSESSION/NFS4ERR_DEADSESSION replies to OP_SEQUENCE
Date: Sun,  4 Dec 2016 19:40:22 -0500
Message-Id: <20161205004023.40957-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the case where SEQUENCE receives a NFS4ERR_BADSESSION or
NFS4ERR_DEADSESSION error, we just want to report the session as needing
recovery, and then we want to retry the operation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f992281c9b29..4fd0e2b7b08e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -816,6 +816,10 @@ static int nfs41_sequence_process(struct rpc_task *task,
 	case -NFS4ERR_SEQ_FALSE_RETRY:
 		++slot->seq_nr;
 		goto retry_nowait;
+	case -NFS4ERR_DEADSESSION:
+	case -NFS4ERR_BADSESSION:
+		nfs4_schedule_session_recovery(session, res->sr_status);
+		goto retry_nowait;
 	default:
 		/* Just update the slot sequence no. */
 		slot->seq_done = 1;
-- 
2.9.3

