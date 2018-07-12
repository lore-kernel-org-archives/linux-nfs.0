Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44791 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726444AbeGLSgD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jul 2018 14:36:03 -0400
Received: by mail-io0-f193.google.com with SMTP id q19-v6so29080629ioh.11
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jul 2018 11:25:20 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id u15-v6sm9730818iog.62.2018.07.12.11.25.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 11:25:18 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix a potential layoutget/layoutrecall deadlock
Date: Thu, 12 Jul 2018 14:24:55 -0400
Message-Id: <20180712182456.8701-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client is sending a layoutget, but the server issues a callback
to recall what it thinks may be an outstanding layout, then we may find
an uninitialised layout attached to the inode due to the layoutget.
In that case, it is appropriate to return NFS4ERR_NOMATCHING_LAYOUT
rather than NFS4ERR_DELAY, as the latter can end up deadlocking.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43ba390bb653..be8e0d2196a5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -215,9 +215,9 @@ static u32 pnfs_check_callback_stateid(struct pnfs_layout_hdr *lo,
 {
 	u32 oldseq, newseq;
 
-	/* Is the stateid still not initialised? */
+	/* Is the stateid not initialised? */
 	if (!pnfs_layout_is_valid(lo))
-		return NFS4ERR_DELAY;
+		return NFS4ERR_NOMATCHING_LAYOUT;
 
 	/* Mismatched stateid? */
 	if (!nfs4_stateid_match_other(&lo->plh_stateid, new))
-- 
2.17.1

