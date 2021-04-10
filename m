Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0898AC433ED
	for <linux-nfs@archiver.kernel.org>; Sat, 10 Apr 2021 18:51:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BC8E961104
	for <linux-nfs@archiver.kernel.org>; Sat, 10 Apr 2021 18:51:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234831AbhDJSwE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 10 Apr 2021 14:52:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:41732 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234768AbhDJSwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 10 Apr 2021 14:52:04 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 225AE61104;
        Sat, 10 Apr 2021 18:51:49 +0000 (UTC)
Subject: [PATCH v1 0/4] minor xprtrdma tracepoint fixes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Sat, 10 Apr 2021 14:51:47 -0400
Message-ID: <161808067409.21449.15778528150201556096.stgit@manet.1015granger.net>
User-Agent: StGit/0.23-29-ga622f1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

---

Chuck Lever (4):
      xprtrdma: Add tracepoints showing FastReg WRs and remote invalidation
      xprtrdma: Add an rpcrdma_mr_completion_class
      xprtrdma: Don't display r_xprt memory addresses in tracepoints
      xprtrdma: Remove the RPC/RDMA QP event handler


 include/trace/events/rpcrdma.h | 131 ++++++++++++++++-----------------
 net/sunrpc/xprtrdma/verbs.c    |  18 -----
 2 files changed, 63 insertions(+), 86 deletions(-)

--
Chuck Lever

