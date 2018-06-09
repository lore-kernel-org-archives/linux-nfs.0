Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:39192 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753447AbeFIRBs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jun 2018 13:01:48 -0400
Received: by mail-io0-f194.google.com with SMTP id f1-v6so19340790ioh.6
        for <linux-nfs@vger.kernel.org>; Sat, 09 Jun 2018 10:01:48 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-36-175-81.alma.mi.frontiernet.net. [50.36.175.81])
        by smtp.gmail.com with ESMTPSA id 142-v6sm10675309ion.21.2018.06.09.10.01.46
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Jun 2018 10:01:46 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Revert commit 5f83d86cf531d ("NFSv4.x: Fix wraparound issues..")
Date: Sat,  9 Jun 2018 13:01:22 -0400
Message-Id: <20180609170123.6062-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The correct behaviour for NFSv4 sequence IDs is to wrap around
to the value 0 after 0xffffffff.
See https://tools.ietf.org/html/rfc5661#section-2.10.6.1

Fixes: 5f83d86cf531d ("NFSv4.x: Fix wraparound issues when validing...")
Cc: stable@vger.kernel.org # 4.6+
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 3a49bb19ef07..ee81031cab29 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -428,11 +428,8 @@ validate_seqid(const struct nfs4_slot_table *tbl, const struct nfs4_slot *slot,
 		return htonl(NFS4ERR_SEQ_FALSE_RETRY);
 	}
 
-	/* Wraparound */
-	if (unlikely(slot->seq_nr == 0xFFFFFFFFU)) {
-		if (args->csa_sequenceid == 1)
-			return htonl(NFS4_OK);
-	} else if (likely(args->csa_sequenceid == slot->seq_nr + 1))
+	/* Note: wraparound relies on seq_nr being of type u32 */
+	if (likely(args->csa_sequenceid == slot->seq_nr + 1))
 		return htonl(NFS4_OK);
 
 	/* Misordered request */
-- 
2.17.1

