Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52501 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753593Ab2EDSJh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 May 2012 14:09:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>, Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 1/2] NFS: Fix O_DIRECT compile warnings
Date: Fri,  4 May 2012 14:09:18 -0400
Message-Id: <1336154959-10705-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the following compile warnings:
fs/nfs/direct.c: In function 'nfs_direct_read_schedule_segment':
fs/nfs/direct.c:325:11: warning: comparison of distinct pointer types
lacks a cast [enabled by default]
fs/nfs/direct.c:325:11: warning: comparison of distinct pointer types
lacks a cast [enabled by default]
fs/nfs/direct.c:325:11: warning: comparison of distinct pointer types
lacks a cast [enabled by default]
fs/nfs/direct.c:352:27: warning: comparison of distinct pointer types
lacks a cast [enabled by default]
fs/nfs/direct.c: In function 'nfs_direct_write_schedule_segment':
fs/nfs/direct.c:622:11: warning: comparison of distinct pointer types
lacks a cast [enabled by default]
fs/nfs/direct.c:622:11: warning: comparison of distinct pointer types
lacks a cast [enabled by default]
fs/nfs/direct.c:622:11: warning: comparison of distinct pointer types
lacks a cast [enabled by default]
fs/nfs/direct.c:650:27: warning: comparison of distinct pointer types
lacks a cast [enabled by default]

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
---
 fs/nfs/direct.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index aab3016..dca9c81 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -322,7 +322,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 		int i;
 
 		pgbase = user_addr & ~PAGE_MASK;
-		bytes = min(max(rsize, PAGE_SIZE), count);
+		bytes = min(max_t(size_t, rsize, PAGE_SIZE), count);
 
 		result = -ENOMEM;
 		npages = nfs_page_array_len(pgbase, bytes);
@@ -349,7 +349,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 
 		for (i = 0; i < npages; i++) {
 			struct nfs_page *req;
-			unsigned int req_len = min(bytes, PAGE_SIZE - pgbase);
+			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 			/* XXX do we need to do the eof zeroing found in async_filler? */
 			req = nfs_create_request(dreq->ctx, dreq->inode,
 						 pagevec[i],
@@ -619,7 +619,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 		int i;
 
 		pgbase = user_addr & ~PAGE_MASK;
-		bytes = min(max(wsize, PAGE_SIZE), count);
+		bytes = min(max_t(size_t, wsize, PAGE_SIZE), count);
 
 		result = -ENOMEM;
 		npages = nfs_page_array_len(pgbase, bytes);
@@ -647,7 +647,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 
 		for (i = 0; i < npages; i++) {
 			struct nfs_page *req;
-			unsigned int req_len = min(bytes, PAGE_SIZE - pgbase);
+			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 
 			req = nfs_create_request(dreq->ctx, dreq->inode,
 						 pagevec[i],
-- 
1.7.7.6

