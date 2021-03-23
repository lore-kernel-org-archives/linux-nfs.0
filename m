Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 215E5C433DB
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Mar 2021 20:37:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D8117619CE
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Mar 2021 20:37:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233416AbhCWUhO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Mar 2021 16:37:14 -0400
Received: from mail.kernel.org ([198.145.29.99]:49080 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233375AbhCWUhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Mar 2021 16:37:03 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 455E161574;
        Tue, 23 Mar 2021 20:37:03 +0000 (UTC)
Subject: [PATCH 1 0/4] Move post-send page release into svc_sendto
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Tue, 23 Mar 2021 16:37:02 -0400
Message-ID: <161653161669.1499.11923816743962834540.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'm trying to move work out of the completion handlers, because these
are a convenient but limited resource due to their single-threaded
nature.

As a first step I've moved the code that DMA unmaps each
svc_rdma_send_ctxt and returns it to the free list to the tail of
svc_rdma_sendto().

---

Chuck Lever (4):
      svcrdma: Add a "deferred close" helper
      svcrdma: Normalize Send page handling
      svcrdma: Remove unused sc_pages field
      svcrdma: Retain the page backing rq_res.head[0].iov_base


 include/linux/sunrpc/svc_rdma.h            |  4 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  8 ++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 57 ++++++++--------------
 3 files changed, 29 insertions(+), 40 deletions(-)

--
Chuck Lever

