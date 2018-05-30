Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34262 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753698AbeE3SGe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:34 -0400
Received: by mail-io0-f193.google.com with SMTP id e15-v6so14319684iog.1
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:33 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.32
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:32 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 19/19] pnfs: Don't release the sequence slot until we've processed layoutget on open
Date: Wed, 30 May 2018 14:05:53 -0400
Message-Id: <20180530180553.38769-20-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-19-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
 <20180530180553.38769-9-trond.myklebust@hammerspace.com>
 <20180530180553.38769-10-trond.myklebust@hammerspace.com>
 <20180530180553.38769-11-trond.myklebust@hammerspace.com>
 <20180530180553.38769-12-trond.myklebust@hammerspace.com>
 <20180530180553.38769-13-trond.myklebust@hammerspace.com>
 <20180530180553.38769-14-trond.myklebust@hammerspace.com>
 <20180530180553.38769-15-trond.myklebust@hammerspace.com>
 <20180530180553.38769-16-trond.myklebust@hammerspace.com>
 <20180530180553.38769-17-trond.myklebust@hammerspace.com>
 <20180530180553.38769-18-trond.myklebust@hammerspace.com>
 <20180530180553.38769-19-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server recalls the layout that was just handed out, we risk hitting
a race as described in RFC5661 Section 2.10.6.3 unless we ensure that we
release the sequence slot after processing the LAYOUTGET operation that
was sent as part of the OPEN compound.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 53f93c3993c8..e664e0c82700 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2804,7 +2804,7 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	if (ret != 0)
 		goto out;
 
-	state = nfs4_opendata_to_nfs4_state(opendata);
+	state = _nfs4_opendata_to_nfs4_state(opendata);
 	ret = PTR_ERR(state);
 	if (IS_ERR(state))
 		goto out;
@@ -2843,6 +2843,7 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	}
 
 out:
+	nfs4_sequence_free_slot(&opendata->o_res.seq_res);
 	return ret;
 }
 
-- 
2.17.0

