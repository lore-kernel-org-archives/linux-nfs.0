Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35045 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbaIDMjY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:24 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so9630745qgd.23
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:23 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 17/17] locks: clean up comments over fl_owner_t definition
Date: Thu,  4 Sep 2014 08:38:43 -0400
Message-Id: <1409834323-7171-18-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The contents of an fl_owner_t have morphed a bit over the years, fix up
the comments to account for the changes.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/fs.h | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index ed4e1897099c..a51be79b7dc3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -852,11 +852,19 @@ static inline struct file *get_file(struct file *f)
 #define FILE_LOCK_DEFERRED 1
 
 /*
- * The POSIX file lock owner is determined by
- * the "struct files_struct" in the thread group
- * (or NULL for no owner - BSD locks).
+ * A generic "file lock owner" value. This is set differently for different
+ * types of locks.
  *
- * Lockd stuffs a "host" pointer into this.
+ * The POSIX file lock owner is determined by the "struct files_struct" in the
+ * thread group.
+ *
+ * Flock (BSD) locks, OFD locks and leases set the fl_owner to the
+ * file description pointer.
+ *
+ * lockd stuffs a "host" pointer into this
+ *
+ * nfsd stuffs a * nfs4_file pointer into this for leases, and a lockowner
+ * pointer into it for v4 locks.
  */
 typedef void *fl_owner_t;
 
-- 
1.9.3

