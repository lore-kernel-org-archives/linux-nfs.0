Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64176C636C9
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 14:52:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4A7D661002
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 14:52:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231935AbhGSOLf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Jul 2021 10:11:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:40730 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S241305AbhGSOI2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jul 2021 10:08:28 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 17DA46113A;
        Mon, 19 Jul 2021 14:48:23 +0000 (UTC)
Subject: [PATCH v2 4/6] SUNRPC: Update trace flags
From:   Chuck Lever <chuck.lever@oracle.com>
To:     trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 19 Jul 2021 10:48:22 -0400
Message-ID: <162670610236.468132.18371432195810384247.stgit@manet.1015granger.net>
In-Reply-To: <162670594361.468132.16222376053830760696.stgit@manet.1015granger.net>
References: <162670594361.468132.16222376053830760696.stgit@manet.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Recent patches added RPC_TASK_MOVEABLE, XPRT_OFFLINE, and
XPRT_REMOVE. Update the tracepoint display macros to display these
flags properly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ea6340129b1b..b13130903a50 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -299,6 +299,7 @@ TRACE_EVENT(rpc_request,
 	__print_flags(flags, "|",					\
 		{ RPC_TASK_ASYNC, "ASYNC" },				\
 		{ RPC_TASK_SWAPPER, "SWAPPER" },			\
+		{ RPC_TASK_MOVEABLE, "MOVEABLE" },			\
 		{ RPC_TASK_NULLCREDS, "NULLCREDS" },			\
 		{ RPC_CALL_MAJORSEEN, "MAJORSEEN" },			\
 		{ RPC_TASK_ROOTCREDS, "ROOTCREDS" },			\
@@ -931,6 +932,8 @@ TRACE_EVENT(rpc_socket_nospace,
 		{ (1UL << XPRT_BOUND),		"BOUND"},		\
 		{ (1UL << XPRT_BINDING),	"BINDING"},		\
 		{ (1UL << XPRT_CLOSING),	"CLOSING"},		\
+		{ (1UL << XPRT_OFFLINE),	"OFFLINE"},		\
+		{ (1UL << XPRT_REMOVE),		"REMOVE"},		\
 		{ (1UL << XPRT_CONGESTED),	"CONGESTED"},		\
 		{ (1UL << XPRT_CWND_WAIT),	"CWND_WAIT"},		\
 		{ (1UL << XPRT_WRITE_SPACE),	"WRITE_SPACE"})


