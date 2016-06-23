Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35346 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbcFWUBh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 16:01:37 -0400
Received: by mail-it0-f68.google.com with SMTP id g127so12803659ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jun 2016 13:01:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 17/17] NFS nfs_vm_page_mkwrite: Don't freeze me, Bro...
Date: Thu, 23 Jun 2016 16:00:49 -0400
Message-Id: <1466712049-5326-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466712049-5326-16-git-send-email-trond.myklebust@primarydata.com>
References: <1466712049-5326-1-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-2-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-3-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-4-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-5-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-6-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-7-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-8-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-9-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-10-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-11-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-12-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-13-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-14-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-15-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-16-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prevent filesystem freezes while handling the write page fault.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 0e9b4a068f13..039d58790629 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -569,6 +569,8 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		filp, filp->f_mapping->host->i_ino,
 		(long long)page_offset(page));
 
+	sb_start_pagefault(inode->i_sb);
+
 	/* make sure the cache has finished storing the page */
 	nfs_fscache_wait_on_page_write(NFS_I(inode), page);
 
@@ -595,6 +597,7 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 out_unlock:
 	unlock_page(page);
 out:
+	sb_end_pagefault(inode->i_sb);
 	return ret;
 }
 
-- 
2.7.4

