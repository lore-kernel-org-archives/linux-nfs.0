Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f182.google.com ([209.85.128.182]:57131 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756704Ab3CYMAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2013 08:00:03 -0400
Received: by mail-ve0-f182.google.com with SMTP id m1so506483ves.13
        for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 05:00:01 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: ycnian@gmail.com
Subject: [PATCH] nfs: allow the v4.1 callback thread to freeze
Date: Mon, 25 Mar 2013 07:59:57 -0400
Message-Id: <1364212797-26097-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The v4.1 callback thread has set_freezable() at the top, but it doesn't
ever try to freeze within the loop. Have it call try_to_freeze() at the
top of the loop. If a freeze event occurs, recheck kthread_should_stop()
after thawing.

Reported-by: Yanchuan Nian <ycnian@gmail.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 5088b57..cff089a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -125,6 +125,9 @@ nfs41_callback_svc(void *vrqstp)
 	set_freezable();
 
 	while (!kthread_should_stop()) {
+		if (try_to_freeze())
+			continue;
+
 		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
 		spin_lock_bh(&serv->sv_cb_lock);
 		if (!list_empty(&serv->sv_cb_list)) {
-- 
1.7.11.7

