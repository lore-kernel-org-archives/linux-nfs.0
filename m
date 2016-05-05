Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34851 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556AbcEESY4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 14:24:56 -0400
Received: by mail-qg0-f47.google.com with SMTP id f74so44400623qge.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2016 11:24:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: hch@lst.de, Anna.Schumaker@netapp.com
Subject: [RFC PATCH 1/6] nfs: don't merge new ff lsegs with ones that have LAYOUTRETURN bit set
Date: Thu,  5 May 2016 14:24:43 -0400
Message-Id: <1462472688-5663-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
References: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise, we'll end up returning layouts that we've just received if
the client issues a new LAYOUTGET prior to the LAYOUTRETURN.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 61b27d99df18..0ee2613b8aa6 100644
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

