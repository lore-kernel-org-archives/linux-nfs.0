Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:54238 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753733AbeE3SGa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:30 -0400
Received: by mail-it0-f66.google.com with SMTP id n64-v6so24272569itb.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:30 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.28
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:28 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/19] NFSv4/pnfs: Ensure pnfs_parse_lgopen() won't try to parse uninitialised data
Date: Wed, 30 May 2018 14:05:49 -0400
Message-Id: <20180530180553.38769-16-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-15-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We need to ensure that pnfs_parse_lgopen() doesn't try to parse a
struct nfs4_layoutget_res that was not filled by a successful call
to decode_layoutget(). This can happen if we performed a cached open,
or if either the OP_ACCESS or OP_GETATTR operations preceding the
OP_LAYOUTGET in the compound returned an error.

By initialising the 'status' field to NFS4ERR_DELAY, we ensure that
pnfs_parse_lgopen() won't try to interpret the structure.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 037e6b9b047b..3da4f404c2fa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -956,7 +956,8 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
 	lgp->res.layoutp = &lgp->args.layout;
 
-
+	/* Don't confuse uninitialised result and success */
+	lgp->res.status = -NFS4ERR_DELAY;
 
 	lgp->args.minlength = PAGE_SIZE;
 	if (lgp->args.minlength > range->length)
-- 
2.17.0

