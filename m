Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895AbYLWXXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:38 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7E021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:37 -0800 (PST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/69] nfs: remove redundant tests on reading new pages
To: linux-nfs@vger.kernel.org
Date: Tue, 23 Dec 2008 18:02:04 -0500
Message-ID: <20081223230204.13743.38381.stgit@heimdal.trondhjem.org>
In-Reply-To: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Wu Fengguang <fengguang.wu@intel.com>

aops->readpages() and its NFS helper readpage_async_filler() will only
be called to do readahead I/O for newly allocated pages. So it's not
necessary to test for the always 0 dirty/uptodate page flags.

The removal of nfs_wb_page() call also fixes a readahead bug: the NFS
readahead has been synchronous since 2.6.23, because that call will
clear PG_readahead, which is the reminder for asynchronous readahead.

More background: the PG_readahead page flag is shared with PG_reclaim,
one for read path and the other for write path. clear_page_dirty_for_io()
unconditionally clears PG_readahead to prevent possible readahead residuals,
assuming itself to be always called in the write path. However, NFS is one
and the only exception in that it _always_ calls clear_page_dirty_for_io()
in the read path, i.e. for readpages()/readpage().

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/read.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)


diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 40d1798..f856004 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -533,12 +533,6 @@ readpage_async_filler(void *data, struct page *page)
 	unsigned int len;
 	int error;
 
-	error = nfs_wb_page(inode, page);
-	if (error)
-		goto out_unlock;
-	if (PageUptodate(page))
-		goto out_unlock;
-
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);

