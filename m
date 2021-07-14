Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6B6DC11F68
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Jul 2021 15:50:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9FEDF61374
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Jul 2021 15:50:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239748AbhGNPxK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Jul 2021 11:53:10 -0400
Received: from mail.kernel.org ([198.145.29.99]:41088 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S239674AbhGNPxK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jul 2021 11:53:10 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 5D18A6128D
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jul 2021 15:50:18 +0000 (UTC)
Subject: [PATCH RFC 1/4] NFS: Unset RPC_TASK_NO_RETRANS_TIMEOUT for async
 lease renewal
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 14 Jul 2021 11:50:17 -0400
Message-ID: <162627781762.1294.17862468684529354297.stgit@manet.1015granger.net>
In-Reply-To: <162627611661.1294.9189768423517916152.stgit@manet.1015granger.net>
References: <162627611661.1294.9189768423517916152.stgit@manet.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In some rare failure modes, the server is actually reading the
transport, but then just dropping the requests on the floor.
TCP_USER_TIMEOUT cannot detect that case.

Prevent such a stuck server from pinning client resources
indefinitely by ensuring that async lease renewal requests can time
out even if the connection is still operational.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1214bb6b7ee..346217f6a00b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5612,6 +5612,12 @@ struct nfs4_renewdata {
  * nfs4_proc_async_renew(): This is not one of the nfs_rpc_ops; it is a special
  * standalone procedure for queueing an asynchronous RENEW.
  */
+static void nfs4_renew_prepare(struct rpc_task *task, void *calldata)
+{
+	task->tk_flags &= ~RPC_TASK_NO_RETRANS_TIMEOUT;
+	rpc_call_start(task);
+}
+
 static void nfs4_renew_release(void *calldata)
 {
 	struct nfs4_renewdata *data = calldata;
@@ -5650,6 +5656,7 @@ static void nfs4_renew_done(struct rpc_task *task, void *calldata)
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
+	.rpc_call_prepare = nfs4_renew_prepare,
 	.rpc_call_done = nfs4_renew_done,
 	.rpc_release = nfs4_renew_release,
 };
@@ -9219,6 +9226,8 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 	struct nfs4_sequence_args *args;
 	struct nfs4_sequence_res *res;
 
+	task->tk_flags &= ~RPC_TASK_NO_RETRANS_TIMEOUT;
+
 	args = task->tk_msg.rpc_argp;
 	res = task->tk_msg.rpc_resp;
 


