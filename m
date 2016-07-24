Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36783 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcGXVbo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:44 -0400
Received: by mail-it0-f68.google.com with SMTP id j124so6500615ith.3
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 10/14] pNFS: Clear the layout metadata if the server changed the layout stateid
Date: Sun, 24 Jul 2016 17:30:55 -0400
Message-Id: <1469395859-83194-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-10-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-8-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-9-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server changed the layout stateid's "other" field, then
we should treat the old layout as being completely gone. In that
case, we want to clear the metadata such as scheduled layoutreturns.

Do this by calling pnfs_mark_layout_stateid_invalid().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1374fcd40484..e16997da157f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1785,7 +1785,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		 * inode invalid, and don't bother validating the stateid
 		 * sequence number.
 		 */
-		pnfs_mark_matching_lsegs_invalid(lo, &free_me, NULL, 0);
+		pnfs_mark_layout_stateid_invalid(lo, &free_me);
 
 		nfs4_stateid_copy(&lo->plh_stateid, &res->stateid);
 		lo->plh_barrier = be32_to_cpu(res->stateid.seqid);
-- 
2.7.4

