Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33475 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753482AbeFIXOi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jun 2018 19:14:38 -0400
Received: by mail-io0-f193.google.com with SMTP id d185-v6so19915281ioe.0
        for <linux-nfs@vger.kernel.org>; Sat, 09 Jun 2018 16:14:38 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-36-175-81.alma.mi.frontiernet.net. [50.36.175.81])
        by smtp.gmail.com with ESMTPSA id r200-v6sm2559173ita.24.2018.06.09.16.14.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Jun 2018 16:14:36 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix the client behaviour on NFS4ERR_SEQ_FALSE_RETRY
Date: Sat,  9 Jun 2018 19:14:11 -0400
Message-Id: <20180609231411.21456-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server returns NFS4ERR_SEQ_FALSE_RETRY or NFS4ERR_RETRY_UNCACHED_REP,
then it thinks we're trying to replay an existing request. If so, then
let's just bump the sequence ID and retry the operation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c5c5d6c9af25..ed45090e4df6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -775,6 +775,13 @@ static int nfs41_sequence_process(struct rpc_task *task,
 			slot->slot_nr,
 			slot->seq_nr);
 		goto out_retry;
+	case -NFS4ERR_RETRY_UNCACHED_REP:
+	case -NFS4ERR_SEQ_FALSE_RETRY:
+		/*
+		 * The server thinks we tried to replay a request.
+		 * Retry the call after bumping the sequence ID.
+		 */
+		goto retry_new_seq;
 	case -NFS4ERR_BADSLOT:
 		/*
 		 * The slot id we used was probably retired. Try again
@@ -799,10 +806,6 @@ static int nfs41_sequence_process(struct rpc_task *task,
 			goto retry_nowait;
 		}
 		goto session_recover;
-	case -NFS4ERR_SEQ_FALSE_RETRY:
-		if (interrupted)
-			goto retry_new_seq;
-		goto session_recover;
 	default:
 		/* Just update the slot sequence no. */
 		slot->seq_done = 1;
-- 
2.17.1

