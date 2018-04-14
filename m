Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f68.google.com ([209.85.160.68]:34246 "EHLO
        mail-pl0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751590AbeDNTmu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Apr 2018 15:42:50 -0400
Received: by mail-pl0-f68.google.com with SMTP id z12-v6so408100plo.1
        for <linux-nfs@vger.kernel.org>; Sat, 14 Apr 2018 12:42:50 -0700 (PDT)
Date: Sun, 15 Apr 2018 01:14:42 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, willy@infradead.org
Subject: [PATCH] fs: nfs: Adding new return type vm_fault_t
Message-ID: <20180414194442.GA20044@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use new return type vm_fault_t for page_mkwrite
handler.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/nfs/file.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 81cca49..29553fd 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -532,13 +532,13 @@ static void nfs_swap_deactivate(struct file *file)
  * writable, implying that someone is about to modify the page through a
  * shared-writable mapping
  */
-static int nfs_vm_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t nfs_vm_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct file *filp = vmf->vma->vm_file;
 	struct inode *inode = file_inode(filp);
 	unsigned pagelen;
-	int ret = VM_FAULT_NOPAGE;
+	vm_fault_t ret = VM_FAULT_NOPAGE;
 	struct address_space *mapping;

 	dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%pD2(%lu), offset %lld)\n",
--
1.9.1

