Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35646 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbJELCv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 07:02:51 -0400
Received: by qkap81 with SMTP id p81so66922973qka.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 04:02:50 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v5 02/20] fs: have flush_delayed_fput flush the workqueue job
Date: Mon,  5 Oct 2015 07:02:24 -0400
Message-Id: <1444042962-6947-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think there's a potential race in flush_delayed_fput. A kthread does
an fput() and that file gets added to the list and the delayed work is
scheduled. More than 1 jiffy passes, and the workqueue thread picks up
the work and starts running it. Then the kthread calls
flush_delayed_work.  It sees that the list is empty and returns
immediately, even though the __fput for its file may not have run yet.

Close this by making flush_delayed_fput use flush_delayed_work instead,
which should immediately schedule the work to run if it's not already,
and block until the workqueue job completes.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index ad17e05ebf95..52cc6803c07a 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -244,6 +244,8 @@ static void ____fput(struct callback_head *work)
 	__fput(container_of(work, struct file, f_u.fu_rcuhead));
 }
 
+static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
+
 /*
  * If kernel thread really needs to have the final fput() it has done
  * to complete, call this.  The only user right now is the boot - we
@@ -256,11 +258,9 @@ static void ____fput(struct callback_head *work)
  */
 void flush_delayed_fput(void)
 {
-	delayed_fput(NULL);
+	flush_delayed_work(&delayed_fput_work);
 }
 
-static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
-
 void fput(struct file *file)
 {
 	if (atomic_long_dec_and_test(&file->f_count)) {
-- 
2.4.3

