Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2BD1C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:38:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8312D21773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:38:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="T7s7hu27"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730395AbfDXNiw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:38:52 -0400
Received: from mail-io1-f45.google.com ([209.85.166.45]:40490 "EHLO
        mail-io1-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727112AbfDXNiw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:38:52 -0400
Received: by mail-io1-f45.google.com with SMTP id i21so15273495iol.7;
        Wed, 24 Apr 2019 06:38:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=utN4WxIEvO24mCvREYV0vv7qaJXpazfk8zcX6VoLsrs=;
        b=T7s7hu27iqS2/8Yy7EkNTkFPNDF5w32XbM/FfaA8mbH6KsD7EJHuLrYvk/MZBd7tW+
         NZSHDk42wRSxGKE742upSeMKYTxLJ51Yf0oLFTGuZUj21BgTOjXx31Np2Hvv3VcUf28I
         si2xMjF4r/HONMprmzuKnPM34I5K3d50vC4eolz/K4UOGd11u0+Zpzg8kBPJnW8s929a
         OgTSnQS6V1y5Uxtxy8iwwbN88ZzarM/vP7x0g1jCkuCokoU4ZyM772wCWw00l/ffCuJU
         NLH880dabyZ2kVQvzjABI8PpG/xj1fyVPGneFz7LhdGALjUQsrXYbwaVBx6PnqQP4EbJ
         G7dQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=utN4WxIEvO24mCvREYV0vv7qaJXpazfk8zcX6VoLsrs=;
        b=AVBzDMQULpcHk1iDOQS82XmQ1AE+y+nAs7v4jXPtt7d0o4HnCgQ2weKUQ5aoLDHX4u
         +r5cQilr0FuTAMzZbYoWp6yo12RPiVcwR8K9kdJeooXqnaZ9MC1bLxISs0G66i0z3zNN
         wVvLhTRfpeSPEtgM99zO1caWOF4e8SE0SGiLDMa0ppysC+s2LiR06MqKaHdc/Q7DqxvS
         ADza2vrOw7u2GILhBkn4DDcOFo2td0xA4cccTwtOqY50oDa/AeJjK1eXJejZ0apkrK7X
         r+hT8v7uewy7RfEuexKjs1PZQBCvpKeeob+z5NrRvTodIIYd7CHvudJx8seRwQP+TlL1
         ssfQ==
X-Gm-Message-State: APjAAAX/T5oWPZExvj+Ina+mVFGLsN1VKo2r9ULz/plMo26Mh553XfJd
        enlpI8pPpOmXuBTOj8YRwtg=
X-Google-Smtp-Source: APXvYqyDnwQDZnMpbE/RE6WPmHc8l4KHHiHVwWED1hHuUbFqMmbaFgaOjslRoEryoUVgL/ExXtUwAA==
X-Received: by 2002:a6b:410e:: with SMTP id n14mr18791519ioa.141.1556113131444;
        Wed, 24 Apr 2019 06:38:51 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c13sm3004984ioi.28.2019.04.24.06.38.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:38:50 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODcnYx011268;
        Wed, 24 Apr 2019 13:38:49 GMT
Subject: [PATCH v3 00/21] NFS/RDMA patches for v5.2
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:38:49 -0400
Message-ID: <20190424133516.5077.67283.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Anna-

This is a series of minor clean-ups, bug fixes, and performance
optimizations. This series is ready for you to merge. See also:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-for-5.2


Changes since v2:
- Rebased on v5.1-rc6 to pick up another fix
- Addressed some nits in the patch descriptions


Changes since v1:
- Rebased on v5.1-rc5, which contains a couple of critical fixes.
- Fixed the build issue that Anna pointed out.
- Dropped the "Defer completion" patch. Something better is in the
 works.
- Added a few more clean-ups.
- Passes my standard set of automated tests

---

Chuck Lever (21):
      SUNRPC: Avoid digging into the ATOMIC pool
      xprtrdma: Fix an frwr_map recovery nit
      xprtrdma: Clean up rpcrdma_create_req()
      xprtrdma: Clean up rpcrdma_create_rep() and rpcrdma_destroy_rep()
      xprtrdma: rpcrdma_regbuf alignment
      xprtrdma: Allocate req's regbufs at xprt create time
      xprtrdma: De-duplicate "allocate new, free old regbuf"
      xprtrdma: Clean up regbuf helpers
      xprtrdma: Backchannel can use GFP_KERNEL allocations
      xprtrdma: Increase maximum number of backchannel requests
      xprtrdma: Trace marshaling failures
      xprtrdma: Clean up sendctx functions
      xprtrdma: More Send completion batching
      xprtrdma: Eliminate rpcrdma_ia::ri_device
      SUNRPC: Update comments based on recent changes
      xprtrdma: Remove rpcrdma_create_data_internal::rsize and wsize
      xprtrdma: Aggregate the inline settings in struct rpcrdma_ep
      xprtrdma: Eliminate struct rpcrdma_create_data_internal
      xprtrdma: Remove pr_err() call sites from completion handlers
      xprtrdma: Update comments that reference ib_drain_qp
      xprtrdma: Remove stale comment


 include/trace/events/rpcrdma.h    |   27 +++
 net/sunrpc/socklib.c              |    2 
 net/sunrpc/xprt.c                 |    4 
 net/sunrpc/xprtrdma/backchannel.c |  120 +++++--------
 net/sunrpc/xprtrdma/frwr_ops.c    |   63 +++----
 net/sunrpc/xprtrdma/rpc_rdma.c    |  115 ++++++-------
 net/sunrpc/xprtrdma/transport.c   |  103 ++---------
 net/sunrpc/xprtrdma/verbs.c       |  338 ++++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |  121 ++++++-------
 9 files changed, 411 insertions(+), 482 deletions(-)

--
Chuck Lever
