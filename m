Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36602 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbcDVAwN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2016 20:52:13 -0400
Received: by mail-qk0-f180.google.com with SMTP id x7so33030704qkd.3
        for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2016 17:52:13 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/7] nfs: don't call nfs4_ff_layout_prepare_ds from ff_layout_get_ds_cred
Date: Thu, 21 Apr 2016 20:51:57 -0400
Message-Id: <1461286320-24601-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
References: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All the callers already call that function before calling into here,
so it ends up being a no-op anyway.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index add0e5a70bd6..a0dbf94d15ae 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -433,16 +433,12 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
 		      struct rpc_cred *mdscred)
 {
 	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
-	struct rpc_cred *cred = ERR_PTR(-EINVAL);
-
-	if (!nfs4_ff_layout_prepare_ds(lseg, ds_idx, true))
-		goto out;
+	struct rpc_cred *cred;
 
 	if (mirror && mirror->cred)
 		cred = mirror->cred;
 	else
 		cred = mdscred;
-out:
 	return cred;
 }
 
-- 
2.5.5

