Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35640 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932470AbcGFWbE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:31:04 -0400
Received: by mail-it0-f66.google.com with SMTP id g4so900880ith.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:31:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 28/28] NFS nfs_vm_page_mkwrite: Don't freeze me, Bro...
Date: Wed,  6 Jul 2016 18:30:05 -0400
Message-Id: <1467844205-76852-29-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-28-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-26-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-27-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-28-git-send-email-trond.myklebust@primarydata.com>
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

