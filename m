Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754536Ab0LADrq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 22:47:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Ensure we use the correct cookie in nfs_readdir_xdr_filler
Date: Tue, 30 Nov 2010 22:47:12 -0500
Message-Id: <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
References: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We need to use the cookie from the previous array entry, not the
actual cookie that we are searching for.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f0a384e..4a78d2b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -178,6 +178,7 @@ typedef struct {
 	struct page	*page;
 	unsigned long	page_index;
 	u64		*dir_cookie;
+	u64		last_cookie;
 	loff_t		current_index;
 	decode_dirent_t	decode;
 
@@ -344,6 +345,8 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 	else
 		status = nfs_readdir_search_for_cookie(array, desc);
 
+	if (status == -EAGAIN)
+		desc->last_cookie = array->last_cookie;
 	nfs_readdir_release_array(desc->page);
 out:
 	return status;
@@ -563,7 +566,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	unsigned int array_size = ARRAY_SIZE(pages);
 
 	entry.prev_cookie = 0;
-	entry.cookie = *desc->dir_cookie;
+	entry.cookie = desc->last_cookie;
 	entry.eof = 0;
 	entry.fh = nfs_alloc_fhandle();
 	entry.fattr = nfs_alloc_fattr();
@@ -672,8 +675,10 @@ int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 {
 	int res;
 
-	if (desc->page_index == 0)
+	if (desc->page_index == 0) {
 		desc->current_index = 0;
+		desc->last_cookie = 0;
+	}
 	while (1) {
 		res = find_cache_page(desc);
 		if (res != -EAGAIN)
-- 
1.7.3.2

