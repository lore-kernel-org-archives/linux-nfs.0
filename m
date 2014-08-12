Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:65250 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbaHLOsU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 10:48:20 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so9658162qgd.33
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 07:48:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] locks: don't call locks_release_private from locks_copy_lock
Date: Tue, 12 Aug 2014 10:48:09 -0400
Message-Id: <1407854893-2698-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All callers of locks_copy_lock pass in a brand new file_lock struct, so
there's no need to calls locks_release_private on it. Replace that with
a warning that fires in the event that we receive a target lock that
doesn't look like it's properly initialized.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/locks.c b/fs/locks.c
index 356667a434c1..2c2d4f5022a7 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -285,7 +285,8 @@ EXPORT_SYMBOL(__locks_copy_lock);
 
 void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
 {
-	locks_release_private(new);
+	/* "new" must be a freshly-initialized lock */
+	WARN_ON_ONCE(new->fl_ops);
 
 	__locks_copy_lock(new, fl);
 	new->fl_file = fl->fl_file;
-- 
1.9.3

