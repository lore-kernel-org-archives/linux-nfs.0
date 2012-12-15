Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:35177 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404Ab2LOWck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2012 17:32:40 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Don't use SetPageError in the NFS writeback code
Date: Sat, 15 Dec 2012 17:32:33 -0500
Message-Id: <1355610755-27787-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The writeback code is already capable of passing errors back to user space
by means of the open_context->error. In the case of ENOSPC, Neil Brown
is reporting seeing 2 errors being returned.

Neil writes:

"e.g. if /mnt2/ if an nfs mounted filesystem that has no space then

strace dd if=/dev/zero conv=fsync >> /mnt2/afile count=1

reported Input/output error and the relevant parts of the strace output are:

write(1, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 512) = 512
fsync(1)                                = -1 EIO (Input/output error)
close(1)                                = -1 ENOSPC (No space left on device)"

Neil then shows that the duplication of error messages appears to be due to
the use of the PageError() mechanism, which causes filemap_fdatawait_range
to return the extra EIO. The regression was introduced by
commit 7b281ee026552f10862b617a2a51acf49c829554 (NFS: fsync() must exit
with an error if page writeback failed).

Fix this by removing the call to SetPageError(), and just relying on
open_context->error reporting the ENOSPC back to fsync().

Reported-by: Neil Brown <neilb@suse.de>
Tested-by: Neil Brown <neilb@suse.de>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org [3.6+]
---
 fs/nfs/write.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f608ca6..5209916 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -202,7 +202,6 @@ out:
 /* A writeback failed: mark the page as bad, and invalidate the page cache */
 static void nfs_set_pageerror(struct page *page)
 {
-	SetPageError(page);
 	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
 }
 
-- 
1.7.11.7

