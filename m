From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] NFS: nfs_write_end clean up
Date: Thu, 20 Dec 2007 14:55:04 -0500
Message-ID: <20071220195504.3280.83759.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:46491 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbXLTTzM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 14:55:12 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: commit 4899f9c8 added nfs_write_end(), which introduces a
conditional expression that returns an unsigned integer in one arm and
a signed integer in the other.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index b3bb89f..6ec5fbf 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -349,7 +349,9 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	unlock_page(page);
 	page_cache_release(page);
 
-	return status < 0 ? status : copied;
+	if (status < 0)
+		return status;
+	return copied;
 }
 
 static void nfs_invalidate_page(struct page *page, unsigned long offset)

