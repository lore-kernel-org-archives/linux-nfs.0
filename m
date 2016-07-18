Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265AbcGROl7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2016 10:41:59 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] nfs: don't create zero-length requests
Date: Mon, 18 Jul 2016 10:41:57 -0400
Message-Id: <9a3042bc347cd708966dbba03b14302b4819c1d1.1468852483.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS doesn't expect requests with wb_bytes set to zero and may make
unexpected decisions about how to handle that request at the page IO layer.
Skip request creation if we won't have any wb_bytes in the request.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/write.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e1c74d3db64d..649fa5e26050 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1289,6 +1289,9 @@ int nfs_updatepage(struct file *file, struct page *page,
 	dprintk("NFS:       nfs_updatepage(%pD2 %d@%lld)\n",
 		file, count, (long long)(page_file_offset(page) + offset));
 
+	if (!count)
+		goto out;
+
 	if (nfs_can_extend_write(file, page, inode)) {
 		count = max(count + offset, nfs_page_length(page));
 		offset = 0;
@@ -1299,7 +1302,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		nfs_set_pageerror(page);
 	else
 		__set_page_dirty_nobuffers(page);
-
+out:
 	dprintk("NFS:       nfs_updatepage returns %d (isize %lld)\n",
 			status, (long long)i_size_read(inode));
 	return status;
-- 
2.5.5

