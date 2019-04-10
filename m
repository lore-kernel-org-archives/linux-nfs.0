Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DCE2C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1740C2075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X3Lgk1gx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726093AbfDJUGe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:06:34 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:53849 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726014AbfDJUGe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:06:34 -0400
Received: by mail-it1-f196.google.com with SMTP id y204so5650374itf.3;
        Wed, 10 Apr 2019 13:06:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=OxCps9zsrElThrABQq+/26TdY0x6Lcb2YhUJ+AMzJag=;
        b=X3Lgk1gxqFmu6GwDP7GxAjycuzmeMmgyJmnSAjo1H2ug7sQOWAnMM/ZSH6n7qr168m
         Z26i55AfJYVJznxiHHcL9rrhBV3XmYTHyw7WAlrm7mEPffhoHsNQFUdJ6Cfo1R6msMa3
         NIC07lDhJO6Kx+YFwF87eLq1bI81JTOCkilVCqqoJCurpwQv+2cddFpnewbbf0wgbcLr
         tB0nPCUJVPfsp/SZBt+V/fqde485GEqDFXnjKpOr3hsYaWWv8Kq0Dr3zYfmoaGOXbe0K
         J7k+C4KjggFjAxyrMQJkjqFTJzXdmMCj+/zD1suLDaIlhFrjeAWiYJWdnF9yCKWFW062
         h+Eg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=OxCps9zsrElThrABQq+/26TdY0x6Lcb2YhUJ+AMzJag=;
        b=oVWCdsCiJGO7z+YGJSy1qwOvfF1Fr5Hn8ZWncMc/XpINeqW3K6fwEBnEfEdXXfCbKZ
         yX+ILub1ONEXaVWDUA2pgcMwk8prbU1zKL4hAKQ3NSIuTzU8PLgmtQhMf3JgfR3B6IwI
         iaxtNqUZWbrdyVXGB5i9+uLt/lvDutvqj5f7MbBRRmmgEZHLI2fSEPFRBE0iVsaxvDHN
         l3r0Bx7q2lBs4VLGQWaEYwhnHdkMfec3fn/aIfsj7GdZVMqK7UTEHX8KAmOqFOPiKjH5
         DwLyTLY7I16am1M0y0U+ghLfodVsjzzTGNa6WnVqs2zwpIDxn40dW18FZpeseUiLvzPV
         mUwQ==
X-Gm-Message-State: APjAAAVrKyViR8W708p9TmvhJn6Nysc8tjnZa+WcHI3FoaLwlEb7zTkW
        qDGtk8P8U43XxE015e3A5e/ZbRsR
X-Google-Smtp-Source: APXvYqyfY3HCZ1+eNYQn6WmZSwQUDgoLJO0rKoM/mu2dHqMLEej99BmRthbxXCDZpL4juuK8HQxO3A==
X-Received: by 2002:a05:660c:10:: with SMTP id q16mr4849538itj.149.1554926793175;
        Wed, 10 Apr 2019 13:06:33 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b82sm1647916itd.12.2019.04.10.13.06.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:06:32 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK6Vc9004503;
        Wed, 10 Apr 2019 20:06:31 GMT
Subject: [PATCH v1 00/19] Proposed NFS/RDMA patches for v5.2
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:06:31 -0400
Message-ID: <20190410200446.11522.21145.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

For review, this is a series of minor clean-ups, bug fixes, and
performance optimizations.

See also:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-for-5.2

---

Chuck Lever (19):
      SUNRPC: Avoid digging into the ATOMIC pool
      xprtrdma: Fix an frwr_map recovery nit
      xprtrdma: Defer completion only when local invalidation is needed
      xprtrdma: Clean up rpcrdma_create_req()
      xprtrdma: Clean up rpcrdma_create_rep() and rpcrdma_destroy_rep()
      xprtrdma: rpcrdma_regbuf alignment
      xprtrdma: Allocate req's regbufs at xprt create time
      xprtrdma: De-duplicate "allocate new, free old regbuf"
      xprtrdma: Clean up regbuf helpers
      xprtrdma: Backchannel can use GFP_KERNEL allocations
      xprtrdma: Increase maximum number of backchannel request
      xprtrdma: Trace marshaling failures
      xprtrdma: Clean up sendctx functions
      xprtrdma: More Send completion batching
      xprtrdma: Eliminate rpcrdma_ia::ri_device
      SUNRPC: Update comments based on recent changes
      xprtrdma: Remove rpcrdma_create_data_internal::rsize and wsize
      xprtrdma: Aggregate the inline settings in struct rpcrdma_ep
      xprtrdma: Eliminate struct rpcrdma_create_data_internal


 include/trace/events/rpcrdma.h    |   27 +++
 net/sunrpc/socklib.c              |    2 
 net/sunrpc/xprt.c                 |    4 
 net/sunrpc/xprtrdma/backchannel.c |  120 +++++---------
 net/sunrpc/xprtrdma/frwr_ops.c    |   40 ++---
 net/sunrpc/xprtrdma/rpc_rdma.c    |  146 +++++++++--------
 net/sunrpc/xprtrdma/transport.c   |  103 ++----------
 net/sunrpc/xprtrdma/verbs.c       |  327 +++++++++++++++++++++----------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |  114 ++++++-------
 9 files changed, 430 insertions(+), 453 deletions(-)

--
Chuck Lever
