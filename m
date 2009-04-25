From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Sat, 25 Apr 2009 10:57:08 -0400
Message-ID: <1240671428.6112.1.camel@heimdal.trondhjem.org>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu>
	 <20090412235010.c8e3475b.akpm@linux-foundation.org>
	 <1239650202.16771.15.camel@heimdal.trondhjem.org>
	 <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com>
	 <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com>
	 <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Rince <rincebrain@gmail.com>, Nick Piggin <npiggin@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50662 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbZDYO5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 25 Apr 2009 10:57:20 -0400
In-Reply-To: <5da0588e0904240226j3454941y5f58c17a32a9a23d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-04-24 at 05:26 -0400, Rince wrote:
> Applied try 3 of Nick Piggin's patch to 2.6.30-rc3 (cleanly, no less!)
> 
> Doesn't appear to have helped at all - I received my favorite BUG ON
> write.c:252 just like always, within 24 hours of booting the kernel,
> even.

Can you apply the following incremental patch on top of Nick's. This
appears to suffice to close the race on my setup.

Cheers
  Trond
---------------------------------------------------------------------
>From f0258852dcb43c748854d2ee550c9c270bb25f21 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 24 Apr 2009 17:32:22 -0400
Subject: [PATCH] NFS: Close page_mkwrite() races

Follow up to Nick Piggin's patches to ensure that nfs_vm_page_mkwrite
returns with the page lock held, and sets the VM_FAULT_LOCKED flag.

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



