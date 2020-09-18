Return-Path: <SRS0=ChQF=C3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BE7BC43464
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Sep 2020 03:11:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4855120678
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Sep 2020 03:11:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600398677;
	bh=94AT0YPweooXiO7gK1/oiuOCZdrXc0s4UM0WFbWcmvc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=SZBCEaUAz/e5MiM8cqhBvMyXki+4ZkKzvOrs8zwpZulgyNni952SKxZskdRBng1Ie
	 H4gkQb+1td2Uw3GLHnK9EWYjL77br7E4omqaC/201hBPZyP8pdDlbe9GnVz4E8qPkL
	 sousbIKoJUbmZjmzT0+cu933N6jEuxe7Ha8AfTgY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726731AbgIRCCa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Sep 2020 22:02:30 -0400
Received: from mail.kernel.org ([198.145.29.99]:47700 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726748AbgIRCCa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Sep 2020 22:02:30 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1CF2723600;
        Fri, 18 Sep 2020 02:02:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600394543;
        bh=94AT0YPweooXiO7gK1/oiuOCZdrXc0s4UM0WFbWcmvc=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=iS1Rxbc0CCY58xmRtYS5WrRfn0czB2PtDlF1nafb+/CDWODLtrsp6NhXS/0UkJVLR
         rvVlzbU6IKFBfOxDrMgnnjdRJmqea2erbCi2TErmGZa0cexetY2nTWnoESx0PcX2mE
         dgLPk3WAqIW1zWyFHPUj+AlWNMbkslPANvvorrXg=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 5.4 061/330] SUNRPC: Capture completion of all RPC tasks
Date:   Thu, 17 Sep 2020 21:56:41 -0400
Message-Id: <20200918020110.2063155-61-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200918020110.2063155-1-sashal@kernel.org>
References: <20200918020110.2063155-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit a264abad51d8ecb7954a2f6d9f1885b38daffc74 ]

RPC tasks on the backchannel never invoke xprt_complete_rqst(), so
there is no way to report their tk_status at completion. Also, any
RPC task that exits via rpc_exit_task() before it is replied to will
also disappear without a trace.

Introduce a trace point that is symmetrical with rpc_task_begin that
captures the termination status of each RPC task.

Sample trace output for callback requests initiated on the server:
   kworker/u8:12-448   [003]   127.025240: rpc_task_end:         task:50@3 flags=ASYNC|DYNAMIC|SOFT|SOFTCONN|SENT runstate=RUNNING|ACTIVE status=0 action=rpc_exit_task
   kworker/u8:12-448   [002]   127.567310: rpc_task_end:         task:51@3 flags=ASYNC|DYNAMIC|SOFT|SOFTCONN|SENT runstate=RUNNING|ACTIVE status=0 action=rpc_exit_task
   kworker/u8:12-448   [001]   130.506817: rpc_task_end:         task:52@3 flags=ASYNC|DYNAMIC|SOFT|SOFTCONN|SENT runstate=RUNNING|ACTIVE status=0 action=rpc_exit_task

Odd, though, that I never see trace_rpc_task_complete, either in the
forward or backchannel. Should it be removed?

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/trace/events/sunrpc.h | 1 +
 net/sunrpc/sched.c            | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ffa3c51dbb1a0..28df77a948e56 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -165,6 +165,7 @@ DECLARE_EVENT_CLASS(rpc_task_running,
 DEFINE_RPC_RUNNING_EVENT(begin);
 DEFINE_RPC_RUNNING_EVENT(run_action);
 DEFINE_RPC_RUNNING_EVENT(complete);
+DEFINE_RPC_RUNNING_EVENT(end);
 
 DECLARE_EVENT_CLASS(rpc_task_queued,
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 987c4b1f0b174..9c79548c68474 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -824,6 +824,7 @@ rpc_reset_task_statistics(struct rpc_task *task)
  */
 void rpc_exit_task(struct rpc_task *task)
 {
+	trace_rpc_task_end(task, task->tk_action);
 	task->tk_action = NULL;
 	if (task->tk_ops->rpc_count_stats)
 		task->tk_ops->rpc_count_stats(task, task->tk_calldata);
-- 
2.25.1

