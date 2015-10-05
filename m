Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34159 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbbJELCy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 07:02:54 -0400
Received: by qgez77 with SMTP id z77so146014123qge.1
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 04:02:53 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v5 05/20] fs: export flush_delayed_fput
Date: Mon,  5 Oct 2015 07:02:27 -0400
Message-Id: <1444042962-6947-6-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and clean up the comments over it a bit. The nfsd code will need to
be able to call back into this.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 95361d2b8a08..899c19687cfa 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -246,20 +246,24 @@ static void ____fput(struct callback_head *work)
 
 static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
 
-/*
- * If kernel thread really needs to have the final fput() it has done
- * to complete, call this.  The only user right now is the boot - we
- * *do* need to make sure our writes to binaries on initramfs has
- * not left us with opened struct file waiting for __fput() - execve()
- * won't work without that.  Please, don't add more callers without
- * very good reasons; in particular, never call that with locks
- * held and never call that from a thread that might need to do
- * some work on any kind of umount.
+/**
+ * flush_delayed_fput - ensure that all delayed_fput work is complete
+ *
+ * If kernel thread or task that has used fput_queue really needs to have the
+ * final fput() it has done to complete, call this. One of the main users is
+ * the boot - we *do* need to make sure our writes to binaries on initramfs has
+ * not left us with opened struct file waiting for __fput() - execve() won't
+ * work without that.
+ *
+ * Please, don't add more callers without very good reasons; in particular,
+ * never call that with locks held and never from a thread that might need to
+ * do some work on any kind of umount.
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

