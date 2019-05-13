Return-Path: <SRS0=+BBy=TN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA8B1C04AB1
	for <linux-nfs@archiver.kernel.org>; Mon, 13 May 2019 06:58:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 91EEA20B7C
	for <linux-nfs@archiver.kernel.org>; Mon, 13 May 2019 06:58:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727371AbfEMG6Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 13 May 2019 02:58:25 -0400
Received: from out30-44.freemail.mail.aliyun.com ([115.124.30.44]:56220 "EHLO
        out30-44.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726330AbfEMG6Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2019 02:58:25 -0400
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=wuyihao@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TRZgi0K_1557730702;
Received: from ali-186590dcce93-2.local(mailfrom:wuyihao@linux.alibaba.com fp:SMTPD_---0TRZgi0K_1557730702)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 13 May 2019 14:58:22 +0800
Subject: [PATCH v2 2/2] NFSv4.1: Fix bug only first CB_NOTIFY_LOCK is handled
From:   Yihao Wu <wuyihao@linux.alibaba.com>
To:     linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Joseph Qi <joseph.qi@linux.alibaba.com>, caspar@linux.alibaba.com
References: <346806ac-2018-b780-4939-87f29648017c@linux.alibaba.com>
Message-ID: <42effbf4-80c1-43e9-b228-2f96152c13d9@linux.alibaba.com>
Date:   Mon, 13 May 2019 14:58:22 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <346806ac-2018-b780-4939-87f29648017c@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When a waiter is waked by CB_NOTIFY_LOCK, it will retry
nfs4_proc_setlk(). The waiter may fail to nfs4_proc_setlk() and sleep
again. However, the waiter is already removed from clp->cl_lock_waitq
when handling CB_NOTIFY_LOCK in nfs4_wake_lock_waiter(). So any
subsequent CB_NOTIFY_LOCK won't wake this waiter anymore. We should
put the waiter back to clp->cl_lock_waitq before retrying.

Cc: stable@vger.kernel.org #4.9+
Signed-off-by: Yihao Wu <wuyihao@linux.alibaba.com>
---
 fs/nfs/nfs4proc.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f9ed6b5..218c086 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6988,20 +6988,22 @@ struct nfs4_lock_waiter {
 	init_wait(&wait);
 	wait.private = &waiter;
 	wait.func = nfs4_wake_lock_waiter;
-	add_wait_queue(q, &wait);
 
 	while(!signalled()) {
+		add_wait_queue(q, &wait);
 		status = nfs4_proc_setlk(state, cmd, request);
-		if ((status != -EAGAIN) || IS_SETLK(cmd))
+		if ((status != -EAGAIN) || IS_SETLK(cmd)) {
+			finish_wait(q, &wait);
 			break;
+		}
 
 		status = -ERESTARTSYS;
 		freezer_do_not_count();
 		wait_woken(&wait, TASK_INTERRUPTIBLE, NFS4_LOCK_MAXTIMEOUT);
 		freezer_count();
+		finish_wait(q, &wait);
 	}
 
-	finish_wait(q, &wait);
 	return status;
 }
 #else /* !CONFIG_NFS_V4_1 */
-- 
1.8.3.1

