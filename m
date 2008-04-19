From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/33] NFS: Fix nfs_wb_page() to always exit with an error
	or a clean page
Date: Sat, 19 Apr 2008 16:40:48 -0400
Message-ID: <20080419204048.14124.46594.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35900 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756748AbYDSUub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:31 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoV0B002639
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:31 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is possible for nfs_wb_page() to sometimes exit with 0 return value, yet
the page is left in a dirty state.
For instance in the case where the server rebooted, and the COMMIT request
failed, then all the previously "clean" pages which were cached by the
server, but were not guaranteed to have been writted out to disk,
have to be redirtied and resent to the server.
The fix is to have nfs_wb_page_priority() check that the page is clean
before it exits...

This fixes a condition that triggers the BUG_ON(PagePrivate(page)) in
nfs_create_request() when we're in the nfs_readpage() path.

Also eliminate a redundant BUG_ON(!PageLocked(page)) while we're at it. It
turns out that clear_page_dirty_for_io() has the exact same test.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ce40cad..997b42a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1493,18 +1493,19 @@ static int nfs_wb_page_priority(struct inode *inode, struct page *page,
 	};
 	int ret;
 
-	BUG_ON(!PageLocked(page));
-	if (clear_page_dirty_for_io(page)) {
-		ret = nfs_writepage_locked(page, &wbc);
+	do {
+		if (clear_page_dirty_for_io(page)) {
+			ret = nfs_writepage_locked(page, &wbc);
+			if (ret < 0)
+				goto out_error;
+		} else if (!PagePrivate(page))
+			break;
+		ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
 		if (ret < 0)
-			goto out;
-	}
-	if (!PagePrivate(page))
-		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
-	if (ret >= 0)
-		return 0;
-out:
+			goto out_error;
+	} while (PagePrivate(page));
+	return 0;
+out_error:
 	__mark_inode_dirty(inode, I_DIRTY_PAGES);
 	return ret;
 }

