Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:45077 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753447AbeFIRBt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jun 2018 13:01:49 -0400
Received: by mail-io0-f196.google.com with SMTP id l25-v6so19312582ioh.12
        for <linux-nfs@vger.kernel.org>; Sat, 09 Jun 2018 10:01:49 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-36-175-81.alma.mi.frontiernet.net. [50.36.175.81])
        by smtp.gmail.com with ESMTPSA id 142-v6sm10675309ion.21.2018.06.09.10.01.47
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Jun 2018 10:01:48 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Fix a typo in nfs41_sequence_process
Date: Sat,  9 Jun 2018 13:01:23 -0400
Message-Id: <20180609170123.6062-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180609170123.6062-1-trond.myklebust@hammerspace.com>
References: <20180609170123.6062-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to compare the slot_id to the highest slot number advertised by the
server.

Fixes: 3be0f80b5fe9c ("NFSv4.1: Fix up replays of interrupted requests")
Cc: stable@vger.kernel.org # 4.15+
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e39f59b5e6d2..c5c5d6c9af25 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -780,7 +780,7 @@ static int nfs41_sequence_process(struct rpc_task *task,
 		 * The slot id we used was probably retired. Try again
 		 * using a different slot id.
 		 */
-		if (slot->seq_nr < slot->table->target_highest_slotid)
+		if (slot->slot_nr < slot->table->target_highest_slotid)
 			goto session_recover;
 		goto retry_nowait;
 	case -NFS4ERR_SEQ_MISORDERED:
-- 
2.17.1

