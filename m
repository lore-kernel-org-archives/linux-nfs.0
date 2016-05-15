Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33375 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbcEOBG4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2016 21:06:56 -0400
Received: by mail-qk0-f195.google.com with SMTP id q184so11339606qkf.0
        for <linux-nfs@vger.kernel.org>; Sat, 14 May 2016 18:06:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 04/13] pnfs: don't merge new ff lsegs with ones that have LAYOUTRETURN bit set
Date: Sat, 14 May 2016 21:06:33 -0400
Message-Id: <1463274402-17746-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise, we'll end up returning layouts that we've just received if
the client issues a new LAYOUTGET prior to the LAYOUTRETURN.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f58cd2a14d5e..127a65fa639a 100644
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

