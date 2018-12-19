Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AA45C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F2A96217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AxKz74Uo"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727155AbeLSP6M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:12 -0500
Received: from mail-it1-f177.google.com ([209.85.166.177]:34736 "EHLO
        mail-it1-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726652AbeLSP6L (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:11 -0500
Received: by mail-it1-f177.google.com with SMTP id x124so11329570itd.1;
        Wed, 19 Dec 2018 07:58:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=wJealIq9KkWdMRFA0VygUZbkvs6z7LEei1J2Z6PA3TE=;
        b=AxKz74Uo6Qb8lF4EHNlUwOb5Q6txEMBp00z/lfpE/6uexYJ1FrH4e+9Ubfm6u1swH3
         8sSWrzCexHX493/19JlWbWo13brHq3GbQCgnD5m+FpllSDdgo73C+R/Ec1fpB1hDxJ7t
         DFhNdoPkaEPgmKz+/9Hp9zJ2YT5vCY1Qdo88IDj0nk4CkUZ8/aYxuqaFz66GAF4iz8yX
         e2AUrjCzRwBSOY15aWbqY0Iw5RHeadPx3+7a5BQXkpjlx3Wu6cHTtUhK4as+IFrxtLMz
         Gg5x2PiX8jMrV3CynXSzzeKjCeV/FfNbaUc1kLasws+6qsuBx602zNtLvlhiSoh1/5C8
         Lexg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=wJealIq9KkWdMRFA0VygUZbkvs6z7LEei1J2Z6PA3TE=;
        b=UDb09/2ZAGU1nolJjoEp5sVmYwGK4vMRuy/VZcu/cKjs3OmzUnuB3zPl4RpnV1eGsm
         nuWYcXqdQyZuI2Qpt381AxfATFnpgjq7H5/YzDrfWkcShcqFxdm8mh5imWD8SKBx+5gG
         Ny1OUzfVPkei8f3gXkl8bztI25D7vtCMQeUfY9I1Cn0L5Qtu8EHlIq5TQI7nM3Ya954e
         c7LvhLAhM3QzYszYtCUUbA/OP0bDwh9diCatXRh6y6Gst0O7n1EsPpUi3KXNoLbLsRMn
         3uqnVUi8VQGmw0SRXJwFi7UkfBmNC4KiYCpRuAiQaWvuytEr6gjBhpIlP4i1Rxm+CS/s
         ZQ+w==
X-Gm-Message-State: AA+aEWbPjfK0SelpHJAQVvbnfWQ6LiUZH3GR1DRxQTTPa6eZDeunt+BJ
        zdbfg0/OvQut9o9hN9bLcec=
X-Google-Smtp-Source: AFSGD/UWqi8Pu3MIg2NQdwQ5/PvxEDI3vmSf6GqGnIkbSwHUpJTyEI9ylnL2XFU5CMep+whmet/vpQ==
X-Received: by 2002:a24:db02:: with SMTP id c2mr7396654itg.137.1545235090207;
        Wed, 19 Dec 2018 07:58:10 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l26sm6034885ioh.31.2018.12.19.07.58.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:09 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFw8C1025756;
        Wed, 19 Dec 2018 15:58:08 GMT
Subject: [PATCH v5 00/30] NFS/RDMA client for next (4.21)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:08 -0500
Message-ID: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Anna-

This series seems ready to be merged into linux-next.

There have been several regressions related to the ->send_request
changes merged into v4.20. As a result, this series contains fixes
and clean-ups that resulted from testing and close code audit while
working on those regressions.

The soft IRQ warnings and DMAR faults that I observed with krb5
flavors on NFS/RDMA are now resolved by fixes included at the top
of this series. There is still an abnormal number of disconnects
with WRITE-intensive workloads on Kerberos, but recovery now
appears to be transparent to applications.

Trond posted a few more patches to address regressions in the
generic disconnect logic. I expect these will appear in v4.20-rc
or will otherwise be merged before my RDMA series, so I've rebased
my patches onto his fixes.


Changes since v4:
- Rebased on v4.20-rc7 plus Trond's latest disconnect fixes
- Fixed a mid-series compiler error


Change since v3:
- Rebased on v4.20-rc7
- Added patches that fix disconnect hangs and crashes
- Reordered series so that critical fixes are easy to backport
- Dropped patch removing deprecated encryption types
- Added patch to replace indirect memory registration calls
- Patch to detect leaked rpcrdma_reps is no longer needed
- Patch to fix rxe REG_WR was accepted by Jason, dropped here


Changes since v2:
- Rebased on v4.20-rc6 to pick up recent fixes
- Patches related to "xprtrdma: Dynamically allocate rpcrdma_reqs"
 have been dropped
- A number of revisions of documenting comments have been added
- Several new trace points are introduced


Changes since v1:
- Rebased on v4.20-rc4
- Series includes the full set, not just the RDMA-related fixes
- "Plant XID..." has been improved, based on testing with rxe
- The required rxe driver fix is included for convenience
- "Fix ri_max_segs..." replaces a bogus one-line fix in v1
- The patch description for "Remove support for FMR" was updated

---

Chuck Lever (30):
      xprtrdma: Yet another double DMA-unmap
      xprtrdma: Ensure MRs are DMA-unmapped when posting LOCAL_INV fails
      xprtrdma: Refactor Receive accounting
      xprtrdma: Replace rpcrdma_receive_wq with a per-xprt workqueue
      xprtrdma: No qp_event disconnect
      xprtrdma: Don't wake pending tasks until disconnect is done
      xprtrdma: Fix ri_max_segs and the result of ro_maxpages
      xprtrdma: Reduce max_frwr_depth
      xprtrdma: Remove support for FMR memory registration
      xprtrdma: Remove rpcrdma_memreg_ops
      xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
      NFS: Make "port=" mount option optional for RDMA mounts
      xprtrdma: Recognize XDRBUF_SPARSE_PAGES
      xprtrdma: Remove request_module from backchannel
      xprtrdma: Expose transport header errors
      xprtrdma: Simplify locking that protects the rl_allreqs list
      xprtrdma: Cull dprintk() call sites
      xprtrdma: Remove unused fields from rpcrdma_ia
      xprtrdma: Clean up of xprtrdma chunk trace points
      xprtrdma: Relocate the xprtrdma_mr_map trace points
      xprtrdma: Add trace points for calls to transport switch methods
      xprtrdma: Trace mapping, alloc, and dereg failures
      NFS: Fix NFSv4 symbolic trace point output
      SUNRPC: Simplify defining common RPC trace events
      SUNRPC: Fix some kernel doc complaints
      xprtrdma: Update comments in frwr_op_send
      xprtrdma: Replace outdated comment for rpcrdma_ep_post
      xprtrdma: Add documenting comment for rpcrdma_buffer_destroy
      xprtrdma: Clarify comments in rpcrdma_ia_remove
      xprtrdma: Don't leak freed MRs


 fs/nfs/nfs4trace.h                         |  456 +++++++++++++++++++---------
 fs/nfs/super.c                             |   10 -
 include/trace/events/rpcrdma.h             |  190 ++++++++++--
 include/trace/events/sunrpc.h              |  172 ++++-------
 net/sunrpc/auth_gss/gss_mech_switch.c      |    2 
 net/sunrpc/backchannel_rqst.c              |    2 
 net/sunrpc/xprtmultipath.c                 |    4 
 net/sunrpc/xprtrdma/Makefile               |    3 
 net/sunrpc/xprtrdma/backchannel.c          |   39 +-
 net/sunrpc/xprtrdma/fmr_ops.c              |  337 ---------------------
 net/sunrpc/xprtrdma/frwr_ops.c             |  209 ++++++++-----
 net/sunrpc/xprtrdma/rpc_rdma.c             |   74 ++---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    8 
 net/sunrpc/xprtrdma/transport.c            |   91 ++----
 net/sunrpc/xprtrdma/verbs.c                |  269 +++++++----------
 net/sunrpc/xprtrdma/xprt_rdma.h            |   80 +----
 net/sunrpc/xprtsock.c                      |    2 
 17 files changed, 914 insertions(+), 1034 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/fmr_ops.c

--
Chuck Lever
