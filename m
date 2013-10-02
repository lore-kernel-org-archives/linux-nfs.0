Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49072 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422Ab3JBO3B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 10:29:01 -0400
From: Jan Kara <jack@suse.cz>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 14/26] nfs: Convert direct IO to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:55 +0200
Message-Id: <1380724087-13927-15-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/direct.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 91ff089d3412..1aaf4aa2b3d7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -337,10 +337,8 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 		if (!pagevec)
 			break;
 		if (uio) {
-			down_read(&current->mm->mmap_sem);
-			result = get_user_pages(current, current->mm, user_addr,
-					npages, 1, 0, pagevec, NULL);
-			up_read(&current->mm->mmap_sem);
+			result = get_user_pages_fast(user_addr, npages, 1,
+						     pagevec);
 			if (result < 0)
 				break;
 		} else {
@@ -658,10 +656,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 			break;
 
 		if (uio) {
-			down_read(&current->mm->mmap_sem);
-			result = get_user_pages(current, current->mm, user_addr,
-						npages, 0, 0, pagevec, NULL);
-			up_read(&current->mm->mmap_sem);
+			result = get_user_pages_fast(user_addr, npages, 0,
+						     pagevec);
 			if (result < 0)
 				break;
 		} else {
-- 
1.8.1.4

