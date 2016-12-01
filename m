Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34580 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758182AbcLAWT1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:27 -0500
Received: by mail-io0-f194.google.com with SMTP id r94so3916650ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:27 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/26] pNFS: Don't clear the layout stateid if a layout return is outstanding
Date: Thu,  1 Dec 2016 17:18:58 -0500
Message-Id: <20161201221922.15657-3-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-2-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we no longer hold any layout segments, we're normally expected to
consider the layout stateid to be invalid. However we cannot assume this
if we're about to, or in the process of sending a layoutreturn.

Fixes: 334a8f37115b ("pNFS: Don't forget the layout stateid if...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v4.8+
---
 fs/nfs/pnfs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 206d560c74f4..09bbb07d0494 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -411,7 +411,9 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	atomic_dec(&lo->plh_refcount);
-	if (list_empty(&lo->plh_segs)) {
+	if (list_empty(&lo->plh_segs) &&
+	    !test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags) &&
+	    !test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags)) {
 		if (atomic_read(&lo->plh_outstanding) == 0)
 			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-- 
2.9.3

