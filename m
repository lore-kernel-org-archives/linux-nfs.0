Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08923C4320A
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Aug 2021 18:44:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E3DF560F55
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Aug 2021 18:44:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231262AbhHBSoW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Aug 2021 14:44:22 -0400
Received: from mail.kernel.org ([198.145.29.99]:58350 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229677AbhHBSoW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Aug 2021 14:44:22 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 7584D60EC0;
        Mon,  2 Aug 2021 18:44:12 +0000 (UTC)
Subject: [PATCH v1 0/5] NFS/RDMA client fixes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 02 Aug 2021 14:44:11 -0400
Message-ID: <162792979429.3902.11831790821518477892.stgit@manet.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi-

Not sure I've posted these yet. I've been working on some error
injection features and while testing them, I found a few bugs in
the NFS/RDMA client.

---

Chuck Lever (5):
      xprtrdma: Disconnect after an ib_post_send() immediate error
      xprtrdma: Put rpcrdma_reps before waking the tear-down completion
      xprtrdma: Add xprtrdma_post_recvs_err() tracepoint
      xprtrdma: Add an xprtrdma_post_send_err tracepoint
      xprtrdma: Eliminate rpcrdma_post_sends()


 include/trace/events/rpcrdma.h    | 74 ++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/backchannel.c |  2 +-
 net/sunrpc/xprtrdma/frwr_ops.c    | 14 +++++-
 net/sunrpc/xprtrdma/transport.c   |  2 +-
 net/sunrpc/xprtrdma/verbs.c       | 28 +++---------
 net/sunrpc/xprtrdma/xprt_rdma.h   |  2 +-
 6 files changed, 90 insertions(+), 32 deletions(-)

--
Chuck Lever

