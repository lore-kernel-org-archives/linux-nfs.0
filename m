Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92485C32789
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 18:35:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 663BF20862
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 18:35:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 663BF20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388302AbeKGEBp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 23:01:45 -0500
Received: from mx1.redhat.com ([209.132.183.28]:39760 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387848AbeKGEBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Nov 2018 23:01:44 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0EFEF7F6BB;
        Tue,  6 Nov 2018 18:35:12 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-123-119.rdu2.redhat.com [10.10.123.119])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E08C2608E7;
        Tue,  6 Nov 2018 18:35:11 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 6A666207A5; Tue,  6 Nov 2018 13:35:11 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RFC 1/4] nfsd: fix a warning in __cld_pipe_upcall()
Date:   Tue,  6 Nov 2018 13:35:08 -0500
Message-Id: <20181106183511.17836-2-smayhew@redhat.com>
In-Reply-To: <20181106183511.17836-1-smayhew@redhat.com>
References: <20181106183511.17836-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 06 Nov 2018 18:35:12 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

__cld_pipe_upcall() emits a "do not call blocking ops when
!TASK_RUNNING" warning due to the dput() call in rpc_queue_upcall().
Fix it by using a completion instead of hand coding the wait.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4recover.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 9c247fa1e959..5188f9f70c78 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -662,7 +662,7 @@ struct cld_net {
 struct cld_upcall {
 	struct list_head	 cu_list;
 	struct cld_net		*cu_net;
-	struct task_struct	*cu_task;
+	struct completion	 cu_done;
 	struct cld_msg		 cu_msg;
 };
 
@@ -671,23 +671,18 @@ __cld_pipe_upcall(struct rpc_pipe *pipe, struct cld_msg *cmsg)
 {
 	int ret;
 	struct rpc_pipe_msg msg;
+	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall, cu_msg);
 
 	memset(&msg, 0, sizeof(msg));
 	msg.data = cmsg;
 	msg.len = sizeof(*cmsg);
 
-	/*
-	 * Set task state before we queue the upcall. That prevents
-	 * wake_up_process in the downcall from racing with schedule.
-	 */
-	set_current_state(TASK_UNINTERRUPTIBLE);
 	ret = rpc_queue_upcall(pipe, &msg);
 	if (ret < 0) {
-		set_current_state(TASK_RUNNING);
 		goto out;
 	}
 
-	schedule();
+	wait_for_completion(&cup->cu_done);
 
 	if (msg.errno < 0)
 		ret = msg.errno;
@@ -754,7 +749,7 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
 		return -EFAULT;
 
-	wake_up_process(cup->cu_task);
+	complete(&cup->cu_done);
 	return mlen;
 }
 
@@ -769,7 +764,7 @@ cld_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	if (msg->errno >= 0)
 		return;
 
-	wake_up_process(cup->cu_task);
+	complete(&cup->cu_done);
 }
 
 static const struct rpc_pipe_ops cld_upcall_ops = {
@@ -900,7 +895,7 @@ alloc_cld_upcall(struct cld_net *cn)
 			goto restart_search;
 		}
 	}
-	new->cu_task = current;
+	init_completion(&new->cu_done);
 	new->cu_msg.cm_vers = CLD_UPCALL_VERSION;
 	put_unaligned(cn->cn_xid++, &new->cu_msg.cm_xid);
 	new->cu_net = cn;
-- 
2.17.1

