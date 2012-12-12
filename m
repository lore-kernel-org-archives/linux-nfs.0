Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:50716 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314Ab2LLRgj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2012 12:36:39 -0500
Received: by mail-qa0-f53.google.com with SMTP id a19so1356915qad.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2012 09:36:38 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, iisaman@netapp.com
Subject: [PATCH] nfs: fix page dirtying in NFS DIO read codepath
Date: Wed, 12 Dec 2012 12:36:31 -0500
Message-Id: <1355333791-4814-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS DIO code will dirty pages that catch read responses in order to
handle the case where someone is doing DIO reads into an mmapped buffer.
The existing code doesn't really do the right thing though since it
doesn't take into account the case where we might be attempting to read
past the EOF.

Fix the logic in that code to only dirty pages that ended up receiving
data from the read. Note too that it really doesn't matter if
NFS_IOHDR_ERROR is set or not. All that matters is if the page was
altered by the read.

Cc: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/direct.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 594f4e7..0bd7a55 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -266,13 +266,8 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
 
-		if (!PageCompound(page)) {
-			if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
-				if (bytes < hdr->good_bytes)
-					set_page_dirty(page);
-			} else
-				set_page_dirty(page);
-		}
+		if (!PageCompound(page) && bytes < hdr->good_bytes)
+			set_page_dirty(page);
 		bytes += req->wb_bytes;
 		nfs_list_remove_request(req);
 		nfs_direct_readpage_release(req);
-- 
1.7.11.7

