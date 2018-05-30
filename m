Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44843 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932129AbeE3SGc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:32 -0400
Received: by mail-io0-f194.google.com with SMTP id y2-v6so17396425iob.11
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:32 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.30
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:30 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/19] pNFS: Don't send LAYOUTGET on OPEN for read, if we already have cached data
Date: Wed, 30 May 2018 14:05:51 -0400
Message-Id: <20180530180553.38769-18-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-17-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

If we're only opening the file for reading, and the file is empty and/or
we already have cached data, then heuristically optimise away the
LAYOUTGET.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8c6ce63f5ed0..5fc4d84d9326 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1996,6 +1996,11 @@ static void _lgopen_prepare_attached(struct nfs4_opendata *data,
 	struct nfs4_layoutget *lgp;
 	struct pnfs_layout_hdr *lo;
 
+	/* Heuristic: don't send layoutget if we have cached data */
+	if (rng.iomode == IOMODE_READ &&
+	   (i_size_read(ino) == 0 || ino->i_mapping->nrpages != 0))
+		return;
+
 	lo = _pnfs_grab_empty_layout(ino, ctx);
 	if (!lo)
 		return;
-- 
2.17.0

