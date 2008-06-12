From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/37] NFS: nfs_updatepage(): don't mark page as dirty if
	an error occurred
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.95417.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754763AbYFLTd7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:33:59 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJXv7Y001506
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:33:58 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c2dd219..dc62bc5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -736,12 +736,13 @@ int nfs_updatepage(struct file *file, struct page *page,
 	}
 
 	status = nfs_writepage_setup(ctx, page, offset, count);
-	__set_page_dirty_nobuffers(page);
+	if (status < 0)
+		nfs_set_pageerror(page);
+	else
+		__set_page_dirty_nobuffers(page);
 
         dprintk("NFS:      nfs_updatepage returns %d (isize %Ld)\n",
 			status, (long long)i_size_read(inode));
-	if (status < 0)
-		nfs_set_pageerror(page);
 	return status;
 }
 

