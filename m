Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4ADCC433DB
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Mar 2021 14:32:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 786BA64F4D
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Mar 2021 14:32:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229736AbhCSObe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Mar 2021 10:31:34 -0400
Received: from mail.kernel.org ([198.145.29.99]:35362 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229941AbhCSObM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Mar 2021 10:31:12 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 20A0164F18;
        Fri, 19 Mar 2021 14:31:12 +0000 (UTC)
Subject: [PATCH v1 0/6] svcrdma Receive batch-posting, take 2
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Fri, 19 Mar 2021 10:31:11 -0400
Message-ID: <161616413550.173092.13403865110684484953.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi-

I found the problem with the original (now reverted) commit to
batch-post Receives. I've taken some time to split the change
into smaller pieces and update a few documenting comments.


---

Chuck Lever (6):
      svcrdma: RPCDBG_FACILITY is no longer used
      svcrdma: Provide an explanatory comment in CMA event handler
      svcrdma: Remove stale comment for svc_rdma_wc_receive()
      svcrdma: Add a batch Receive posting mechanism
      svcrdma: Use svc_rdma_refresh_recvs() in wc_receive
      svcrdma: Maintain a Receive water mark


 include/linux/sunrpc/svc_rdma.h          |  2 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  | 91 +++++++++++++-----------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  8 ++-
 3 files changed, 60 insertions(+), 41 deletions(-)

--
Chuck Lever

