Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A58F0C5519F
	for <linux-nfs@archiver.kernel.org>; Sun, 22 Nov 2020 20:52:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 42F3020782
	for <linux-nfs@archiver.kernel.org>; Sun, 22 Nov 2020 20:52:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TSYm/Mh+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727388AbgKVUwe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 22 Nov 2020 15:52:34 -0500
Received: from mail.kernel.org ([198.145.29.99]:57492 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727297AbgKVUwe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Nov 2020 15:52:34 -0500
Received: from leira.hammer.space (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6F81F20782
        for <linux-nfs@vger.kernel.org>; Sun, 22 Nov 2020 20:52:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1606078353;
        bh=fl7fx4B4q/PcLte/X7qXWEto4b9HwWMTUWpiU25fejM=;
        h=From:To:Subject:Date:From;
        b=TSYm/Mh+KuewTTFnRejBIe+u/1QZpiy6x3io1reSdkIRRAE1i51sNmlPrlci1SVvl
         rlZJqcZA2y8OimeS0WFTTE0/QaE3BcMqxQX5mVQoTSvcpmT9EEAJTsn5Xd1bszWZNZ
         lfY6fFQPSILYc0l93TCQB3aYCIou0/KyRb75jJVc=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/8] Fix various issues in the SUNRPC xdr code
Date:   Sun, 22 Nov 2020 15:52:21 -0500
Message-Id: <20201122205229.3826-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

When looking at the issues raised by Tigran's testing of the NFS client
updates, I noticed a couple of things in the generic SUNRPC xdr code
that want to be fixed. This patch series replaces an earlier series that
attempted to just fix the XDR padding in the NFS code.

This series fixes up a number of issues w.r.t. bounds checking in the
xdr_stream code. It corrects the behaviour of xdr_read_pages() for the
case where the XDR object size is larger than the buffer page array
length and simplifies the code.

Trond Myklebust (8):
  NFSv4: Fix the alignment of page data in the getdeviceinfo reply
  SUNRPC: Fix up typo in xdr_init_decode()
  SUNRPC: Clean up helpers xdr_set_iov() and xdr_set_page_base()
  SUNRPC: Fix up xdr_read_pages() to take arbitrary object lengths
  SUNRPC: Don't truncate tail in xdr_inline_pages()
  SUNRPC: Fix up xdr_set_page()
  SUNRPC: Fix open coded xdr_stream_remaining()
  NFSv4: Fix open coded xdr_stream_remaining()

 fs/nfs/nfs4xdr.c |  16 +++++---
 net/sunrpc/xdr.c | 101 +++++++++++++++++++++--------------------------
 2 files changed, 56 insertions(+), 61 deletions(-)

-- 
2.28.0

