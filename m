Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36801 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbcEKKVZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2016 06:21:25 -0400
Received: by mail-qk0-f193.google.com with SMTP id l68so2731032qkf.3
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2016 03:21:25 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/9] pnfs: don't merge new ff lsegs with ones that have LAYOUTRETURN bit set
Date: Wed, 11 May 2016 06:21:06 -0400
Message-Id: <1462962074-6989-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
References: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise, we'll end up returning layouts that we've just received if
the client issues a new LAYOUTGET prior to the LAYOUTRETURN.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 60d690dbc947..08cd5f856321 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -298,6 +298,8 @@ ff_lseg_merge(struct pnfs_layout_segment *new,
 {
 	u64 new_end, old_end;
 
+	if (test_bit(NFS_LSEG_LAYOUTRETURN, &old->pls_flags))
+		return false;
 	if (new->pls_range.iomode != old->pls_range.iomode)
 		return false;
 	old_end = pnfs_calc_offset_end(old->pls_range.offset,
@@ -318,8 +320,6 @@ ff_lseg_merge(struct pnfs_layout_segment *new,
 			new_end);
 	if (test_bit(NFS_LSEG_ROC, &old->pls_flags))
 		set_bit(NFS_LSEG_ROC, &new->pls_flags);
-	if (test_bit(NFS_LSEG_LAYOUTRETURN, &old->pls_flags))
-		set_bit(NFS_LSEG_LAYOUTRETURN, &new->pls_flags);
 	return true;
 }
 
-- 
2.5.5

