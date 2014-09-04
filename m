Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:58245 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbaIDMjX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:23 -0400
Received: by mail-qc0-f180.google.com with SMTP id c9so10451335qcz.11
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 16/17] locks: set fl_owner for leases to filp instead of current->files
Date: Thu,  4 Sep 2014 08:38:42 -0400
Message-Id: <1409834323-7171-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Like flock locks, leases are owned by the file description. Now that the
i_have_this_lease check in __break_lease is gone, we don't actually use
the fl_owner for leases for anything. So, it's now safe to set this more
appropriately to the same value as the fl_file.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/locks.c b/fs/locks.c
index 5a97e7c4e7f2..735b8d3fa78c 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -465,7 +465,7 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
 	if (assign_type(fl, type) != 0)
 		return -EINVAL;
 
-	fl->fl_owner = current->files;
+	fl->fl_owner = filp;
 	fl->fl_pid = current->tgid;
 
 	fl->fl_file = filp;
-- 
1.9.3

