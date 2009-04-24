From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Close page_mkwrite() races
Date: Fri, 24 Apr 2009 17:32:22 -0400
Message-ID: <1241315252.15825.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62762 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323AbZECBtE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 May 2009 21:49:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Follow up to Nick Piggin's patches to ensure that nfs_vm_page_mkwrite
returns with the page lock held, and sets the VM_FAULT_LOCKED flag.

See http://bugzilla.kernel.org/show_bug.cgi?id=12913

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5a97bcf..ec7e27d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -517,10 +517,10 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	ret = nfs_updatepage(filp, page, 0, pagelen);
 out_unlock:
+	if (!ret)
+		return VM_FAULT_LOCKED;
 	unlock_page(page);
-	if (ret)
-		ret = VM_FAULT_SIGBUS;
-	return ret;
+	return VM_FAULT_SIGBUS;
 }
 
 static struct vm_operations_struct nfs_file_vm_ops = {
-- 
1.6.0.6
