Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7D86C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 21:53:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BD5C8206BB
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 21:53:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726090AbfAIVxs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 16:53:48 -0500
Received: from mx1.redhat.com ([209.132.183.28]:44637 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725775AbfAIVxr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Jan 2019 16:53:47 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 72FBF7AE9A;
        Wed,  9 Jan 2019 21:53:46 +0000 (UTC)
Received: from bcodding.csb (ovpn-112-57.rdu2.redhat.com [10.10.112.57])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 033FF608C7;
        Wed,  9 Jan 2019 21:53:46 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id 53A7C10C30F3; Wed,  9 Jan 2019 16:53:45 -0500 (EST)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Dave Wysochanski <dwysocha@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>
Subject: [RFC for-stable PATCH] SUNRPC: Always drop the XPRT_LOCK on XPRT_CLOSE_WAIT
Date:   Wed,  9 Jan 2019 16:53:45 -0500
Message-Id: <f3dda1a55b9a5d5a7416925358379608cc3a431e.1547069858.git.bcodding@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 09 Jan 2019 21:53:46 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello, I'd like this patch to land in stable but I'd like to give everyone
here a chance to NAK or add a SOB before I send it, since it doesn't have an
exact mainline copy.  Thanks for any review, and really thanks to Dave and
Trond for doing all the actual work.

8<----------------------------------------------------------------------

This patch is only appropriate for stable kernels v4.16 - v4.19

Since commit 9b30889c548a ("SUNRPC: Ensure we always close the socket after
a connection shuts down"), and until commit c544577daddb ("SUNRPC: Clean up
transport write space handling"), it is possible for the NFS client to spin
in the following tight loop:

269.964083: rpc_task_run_action: task:43@0 flags=5a81 state=0005 status=0 action=call_bind [sunrpc]
269.964083: rpc_task_run_action: task:43@0 flags=5a81 state=0005 status=0 action=call_connect [sunrpc]
269.964083: rpc_task_run_action: task:43@0 flags=5a81 state=0005 status=0 action=call_transmit [sunrpc]
269.964085: xprt_transmit: peer=[10.0.1.82]:2049 xid=0x761d3f77 status=-32
269.964085: rpc_task_run_action: task:43@0 flags=5a81 state=0005 status=-32 action=call_transmit_status [sunrpc]
269.964085: rpc_task_run_action: task:43@0 flags=5a81 state=0005 status=-32 action=call_status [sunrpc]
269.964085: rpc_call_status: task:43@0 status=-32

The issue is that the path through call_transmit_status does not release
the XPRT_LOCK when the transmit result is -EPIPE, so the socket cannot be
properly shut down.

The below commit fixed things up in mainline by unconditionally calling
xprt_end_transmit() which releases the XPRT_LOCK after every pass through
call_transmit.  However, the entirety of this commit is not appropriate for
stable kernels because its original inclusion was part of a series that
modifies the sunrpc code to use a different queueing model.  As a result,
there are machinations within this patch that are not needed for a stable
fix and will not make sense without a larger backport of the mainline
series.

In this patch, we take the slightly modified bit of the mainline patch
below, which is to release the XPRT_LOCK on transmission error should we
detect that the transport is waiting to close.

commit c544577daddb618c7dd5fa7fb98d6a41782f020e
Author: Trond Myklebust <trond.myklebust@hammerspace.com>
Date:   Mon Sep 3 23:39:27 2018 -0400

    SUNRPC: Clean up transport write space handling

    Treat socket write space handling in the same way we now treat transport
    congestion: by denying the XPRT_LOCK until the transport signals that it
    has free buffer space.

    Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>

The original discussion of the problem is here:

    https://lore.kernel.org/linux-nfs/20181212135157.4489-1-dwysocha@redhat.com/T/#t

This passes my usual cthon and xfstests on NFS as applied on v4.19 mainline.

Reported-by: Dave Wysochanski <dwysocha@redhat.com>
Suggested-by: Trond Myklebust <trondmy@hammerspace.com>
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 include/linux/sunrpc/xprt.h | 5 +++++
 net/sunrpc/clnt.c           | 6 ++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 336fd1a19cca..f30bf500888d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -443,6 +443,11 @@ static inline int xprt_test_and_set_connecting(struct rpc_xprt *xprt)
 	return test_and_set_bit(XPRT_CONNECTING, &xprt->state);
 }
 
+static inline int xprt_close_wait(struct rpc_xprt *xprt)
+{
+	return test_bit(XPRT_CLOSE_WAIT, &xprt->state);
+}
+
 static inline void xprt_set_bound(struct rpc_xprt *xprt)
 {
 	test_and_set_bit(XPRT_BOUND, &xprt->state);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8ea2f5fadd96..1fc812ba9871 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1992,13 +1992,15 @@ call_transmit(struct rpc_task *task)
 static void
 call_transmit_status(struct rpc_task *task)
 {
+	struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
 	task->tk_action = call_status;
 
 	/*
 	 * Common case: success.  Force the compiler to put this
-	 * test first.
+	 * test first.  Or, if any error and xprt_close_wait,
+	 * release the xprt lock so the socket can close.
 	 */
-	if (task->tk_status == 0) {
+	if (task->tk_status == 0 || xprt_close_wait(xprt)) {
 		xprt_end_transmit(task);
 		rpc_task_force_reencode(task);
 		return;
-- 
2.14.3

