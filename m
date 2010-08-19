Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16286 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab0HSOP1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 10:15:27 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o7JEFQbM029499
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 19 Aug 2010 10:15:26 -0400
Received: from barsoom.rdu.redhat.com (barsoom.rdu.redhat.com [10.11.228.36])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o7JEFQHO029789
	for <linux-nfs@vger.kernel.org>; Thu, 19 Aug 2010 10:15:26 -0400
Date: Thu, 19 Aug 2010 10:15:25 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100819101525.076831ad@barsoom.rdu.redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm looking at backporting some upstream changes to earlier kernels,
and ran across something I don't quite understand...

In nfs_commit_unstable_pages, we set the flags to FLUSH_SYNC. We then
zero out the flags if wbc->nonblocking or wbc->for_background is set.

Shouldn't we also clear it out if wbc->sync_mode == WB_SYNC_NONE ?
WB_SYNC_NONE means "don't wait on anything", so shouldn't that include
not waiting on the COMMIT to complete?

For discussion purposes, here's a patch that shows what I'm talking
about (completely untested):

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 874972d..2fca906 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1440,7 +1440,8 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 	    nfsi->ncommit <= (nfsi->npages >> 1))
 		goto out_mark_dirty;
 
-	if (wbc->nonblocking || wbc->for_background)
+	if (wbc->nonblocking || wbc->for_background ||
+	    wbc->sync_mode == WB_SYNC_NONE)
 		flags = 0;
 	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0) {

-- 
Jeff Layton <jlayton@redhat.com>
