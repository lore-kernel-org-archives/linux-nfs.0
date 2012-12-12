Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:60609 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256Ab2LLQiz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2012 11:38:55 -0500
Received: by mail-qa0-f53.google.com with SMTP id a19so1224517qad.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2012 08:38:53 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, iisaman@netapp.com, eguan@redhat.com
Subject: [PATCH] nfs: don't zero out the rest of the page if we hit the EOF on a DIO READ
Date: Wed, 12 Dec 2012 11:38:44 -0500
Message-Id: <1355330324-3233-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eryu provided a test program that would segfault when attempting to read
past the EOF on file that was opened O_DIRECT. The buffer given to the
read() call was on the stack, and when he attempted to read past it it
would scribble over the rest of the stack page.

If we hit the end of the file on a DIO READ request, then we don't want
to zero out the rest of the buffer. These aren't pagecache pages after
all, and there's no guarantee that the buffers that were passed in
represent entire pages.

Cc: <stable@vger.kernel.org> # v3.5+
Cc: Fred Isaman <iisaman@netapp.com>
Reported-by: Eryu Guan <eguan@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/direct.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index cae26cb..594f4e7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -266,14 +266,6 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
 
-		if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
-			if (bytes > hdr->good_bytes)
-				zero_user(page, 0, PAGE_SIZE);
-			else if (hdr->good_bytes - bytes < PAGE_SIZE)
-				zero_user_segment(page,
-					hdr->good_bytes & ~PAGE_MASK,
-					PAGE_SIZE);
-		}
 		if (!PageCompound(page)) {
 			if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
 				if (bytes < hdr->good_bytes)
-- 
1.7.11.7

