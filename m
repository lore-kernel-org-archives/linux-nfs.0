Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35446 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489AbbINNqF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 09:46:05 -0400
Received: by ykdu9 with SMTP id u9so153506446ykd.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 06:46:05 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] fs: export flush_delayed_fput
Date: Mon, 14 Sep 2015 09:45:55 -0400
Message-Id: <1442238355-8203-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and clean up the comments over it a bit.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 1ad2e3fd2064..2b145b513274 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -246,19 +246,19 @@ static void ____fput(struct callback_head *work)
 static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
 
 /*
- * If kernel thread really needs to have the final fput() it has done
- * to complete, call this.  The only user right now is the boot - we
- * *do* need to make sure our writes to binaries on initramfs has
- * not left us with opened struct file waiting for __fput() - execve()
- * won't work without that.  Please, don't add more callers without
- * very good reasons; in particular, never call that with locks
- * held and never call that from a thread that might need to do
- * some work on any kind of umount.
+ * If kernel thread or task that has used fput_queue really needs to have the
+ * final fput() it has done to complete, call this. The only user right now is
+ * the boot - we *do* need to make sure our writes to binaries on initramfs has
+ * not left us with opened struct file waiting for __fput() - execve() won't
+ * work without that.  Please, don't add more callers without very good
+ * reasons; in particular, never call that with locks held and never call that
+ * from a thread that might need to do some work on any kind of umount.
  */
 void flush_delayed_fput(void)
 {
 	flush_delayed_work(&delayed_fput_work);
 }
+EXPORT_SYMBOL(flush_delayed_fput);
 
 /**
  * fput - put a struct file reference
-- 
2.4.3

