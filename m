Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28276C10F14
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:36:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EB918217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:36:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GVIwA1x7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726986AbfDPNgy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:36:54 -0400
Received: from mail-it1-f176.google.com ([209.85.166.176]:55400 "EHLO
        mail-it1-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726837AbfDPNgy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:36:54 -0400
Received: by mail-it1-f176.google.com with SMTP id y134so32969353itc.5;
        Tue, 16 Apr 2019 06:36:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=HnC8HLzsRT7Iq3r2qW/65G02CcEm5QLXnufgxfLTHiw=;
        b=GVIwA1x7shhu7Ds3beLOYVBr0QL8SpCmTxa0Ec/NYDpEKR20v0MrK4T6YGUunidI1a
         +m04fpPhMNhHeb3dHHPEudXc9MdCi/S7XMLMisFHBbz2TN/c7pTABESQ+c7p2n4RCyx2
         UFLh0sfMa5GlU5DW+a+uYR2y2vLkAYVA+TIrmFkrHrLOORcszX1geTqb2feBqs5bO/j3
         RCvqNdLE8xGAdSA7+fLYKCnt76J/JPB5F88usRkR8CboEgF5Fz4GOtsolfrz3VZ7Rtz+
         fJ3sLpQ5h2VpNDmwGHmvKU22d7gpPu6Os87OZ7EebUurDzzcIRpZtUFBFquZnuSjNYPz
         tVsg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=HnC8HLzsRT7Iq3r2qW/65G02CcEm5QLXnufgxfLTHiw=;
        b=JdFKozHVIiFcee/wIagHXQaQkpFOyKzbFSsUKheVbvwgjAhMyD0fYtNh+elVJ5O6CZ
         p6xlWBEL2NJZXYwzFWwrzVKHXgwYB2K5eHBccVAhNmukRUXazK/+ifVIZlkD7T6+fKX4
         RY/6fpuFWM/35EOKAZveisvL9NmuoR3mQwefmlD+n5pWCBuhz5wnQmWFsm4BnhtLHpqo
         k3x18iGfHCC6ah9CwDdPGzEXEdMkyyip5wh7+c9YaR7xt2r3QVPgDLIBkRkTF2Ay7+lL
         PVchufnCtvIcuqhqNzvSoTlKGk/BrmvIy6mm1yIszfSSDqFitZhdOieMVUGaiqsw4H8U
         3DNQ==
X-Gm-Message-State: APjAAAWy3ZMlSEP8lIuhqgaLYhuaoDXOQFFY8sKu4+5NLOVLUPwyqIdf
        /NlpBeo8hD9hL0XVdi26JNdTdCKk
X-Google-Smtp-Source: APXvYqwP9z6LLHCbRWrddsERc8rtckpAezpmjpwlalLAnlFVXuAclnV3NwLxcGzd2cD2mmJUQ+MlJg==
X-Received: by 2002:a02:1d03:: with SMTP id 3mr56583976jaj.73.1555421813375;
        Tue, 16 Apr 2019 06:36:53 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id f8sm9631381itc.27.2019.04.16.06.36.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:36:52 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDao5l021196;
        Tue, 16 Apr 2019 13:36:50 GMT
Subject: [PATCH v2 00/21] Proposed NFS/RDMA patches for v5.2
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:36:50 -0400
Message-ID: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a series of minor clean-ups, bug fixes, and performance
optimizations.

See also:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-for-5.2


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
      xprtrdma: Increase maximum number of backchannel request
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
 net/sunrpc/xprtrdma/xprt_rdma.h   |  120 ++++++-------
 9 files changed, 411 insertions(+), 481 deletions(-)

--
Chuck Lever
