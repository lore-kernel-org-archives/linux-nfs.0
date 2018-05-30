Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:44516 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753651AbeE3SGV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:21 -0400
Received: by mail-io0-f175.google.com with SMTP id y2-v6so17395761iob.11
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:20 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:19 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/19] pnfs: Add layout driver flag PNFS_LAYOUTGET_ON_OPEN
Date: Wed, 30 May 2018 14:05:38 -0400
Message-Id: <20180530180553.38769-5-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-4-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Driver can set flag to allow LAYOUTGET to be sent with OPEN.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 1 +
 fs/nfs/pnfs.h                          | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c75ad982bcfc..3ae038d9c292 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2347,6 +2347,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.id			= LAYOUT_FLEX_FILES,
 	.name			= "LAYOUT_FLEX_FILES",
 	.owner			= THIS_MODULE,
+	.flags			= PNFS_LAYOUTGET_ON_OPEN,
 	.set_layoutdriver	= ff_layout_set_layoutdriver,
 	.alloc_layout_hdr	= ff_layout_alloc_layout_hdr,
 	.free_layout_hdr	= ff_layout_free_layout_hdr,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index daf6cbf5c15f..f71a55f11b97 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -110,6 +110,7 @@ enum layoutdriver_policy_flags {
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
 	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
 	PNFS_READ_WHOLE_PAGE		= 1 << 2,
+	PNFS_LAYOUTGET_ON_OPEN		= 1 << 3,
 };
 
 struct nfs4_deviceid_node;
-- 
2.17.0

