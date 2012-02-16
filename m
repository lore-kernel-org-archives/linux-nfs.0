Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34589 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004Ab2BPNqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 08:46:55 -0500
From: Jan Kara <jack@suse.cz>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>,
        Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 10/11] nfs: Push file_update_time() into nfs_vm_page_mkwrite()
Date: Thu, 16 Feb 2012 14:46:18 +0100
Message-Id: <1329399979-3647-11-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-1-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/file.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c43a452..2407922 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -525,6 +525,9 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	/* make sure the cache has finished storing the page */
 	nfs_fscache_wait_on_page_write(NFS_I(dentry->d_inode), page);
 
+	/* Update file times before taking page lock */
+	file_update_time(filp);
+
 	lock_page(page);
 	mapping = page->mapping;
 	if (mapping != dentry->d_inode->i_mapping)
-- 
1.7.1

