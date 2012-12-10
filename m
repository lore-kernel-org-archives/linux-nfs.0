Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:47788 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691Ab2LJOZ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2012 09:25:57 -0500
Received: by mail-qa0-f53.google.com with SMTP id a19so1486481qad.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2012 06:25:56 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: jiali@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: don't extend writes to cover entire page if pagecache is invalid
Date: Mon, 10 Dec 2012 09:25:48 -0500
Message-Id: <1355149548-4225-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jian reported that the following sequence would leave "testfile" with
corrupt data:

    # mount localhost:/export /mnt/nfs/ -o vers=3
    # echo abc > /mnt/nfs/testfile; echo def >> /export/testfile; echo ghi >> /mnt/nfs/testfile
    # cat -v /export/testfile
    abc
    ^@^@^@^@ghi

While there's no locking involved here, the operations are serialized,
so CTO should prevent corruption.

The first write to the file is fine and writes 4 bytes. The file is then
extended on the server. When it's reopened a GETATTR is issued and the
size change is noticed. This causes NFS_INO_INVALID_DATA to be set on
the file. Because the file is opened for write only,
nfs_want_read_modify_write() returns 0 to nfs_write_begin().
nfs_updatepage then calls nfs_write_pageuptodate() to see if it should
extend the nfs_page to cover the whole page. NFS_INO_INVALID_DATA is
still set on the file at that point, but that flag is ignored and
nfs_pageuptodate erroneously extends the write to cover the whole page,
with the write done on the server side filled in with zeroes.

This patch just has that function check for NFS_INO_INVALID_DATA in
addition to NFS_INO_REVAL_PAGECACHE. This fixes the bug, but looking
over the code, I wonder if we might have a similar bug in
nfs_revalidate_size(). The difference between those two flags is very
subtle, so it seems like we ought to be checking for
NFS_INO_INVALID_DATA in most of the places that we look for
NFS_INO_REVAL_PAGECACHE.

I believe this is regression introduced by commit 8d197a568. The code
did check for NFS_INO_INVALID_DATA prior to that patch.

Original bug report is here:

    https://bugzilla.redhat.com/show_bug.cgi?id=885743

Cc: <stable@vger.kernel.org> # 3.5+
Reported-by: Jian Li <jiali@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9347ab7..83aec9b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -884,7 +884,7 @@ static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
 {
 	if (nfs_have_delegated_attributes(inode))
 		goto out;
-	if (NFS_I(inode)->cache_validity & NFS_INO_REVAL_PAGECACHE)
+	if (NFS_I(inode)->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
 		return false;
 out:
 	return PageUptodate(page) != 0;
-- 
1.7.11.7

