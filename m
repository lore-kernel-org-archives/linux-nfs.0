Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0E53C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 701492133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EgTLy9RW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387890AbeLQQjZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:39:25 -0500
Received: from mail-it1-f173.google.com ([209.85.166.173]:34825 "EHLO
        mail-it1-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387737AbeLQQjZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:39:25 -0500
Received: by mail-it1-f173.google.com with SMTP id p197so20932884itp.0;
        Mon, 17 Dec 2018 08:39:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=E4vk4tTMM8QViNKBSgkGgtptZiNRCd3cXgAwRC85RHI=;
        b=EgTLy9RWvWR9WsKkJ4cvrpVW+bvvEpxNQgWC3+rMeJnIjFBX9eVP+AUsSwMy4/JfO2
         FwCIsZBO6XQhp3lXnbUCl33xr0CZhFUrTELhKHwYojvt7Ps4ZynVJKnkupqIgpqz7Zo7
         XB+BnpjMWpKGw3M2q1+ymbJ69O+ns4WxzG1MbKCvLnn31AAl0JDgoZMwf/lvRL8mLXu7
         l0tKsodX/TRTZasSCYVd0tvPzLKDTI2fnwZic98cDDAGBa7gbwwilyuVchwchx7pVyyF
         snXOEG/ZXTGjHGRzW+3xMXajeddH280nt+NOCbz6o9Pq+fTzgJR+nNANcTWVQNdVKzQx
         mUSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=E4vk4tTMM8QViNKBSgkGgtptZiNRCd3cXgAwRC85RHI=;
        b=uec9jnJw5qAC0rrWPa5qOJmiag31Pl1SvB+aT9bsVFxkQWfencB1Rod3DswnjGYqow
         xRzIyuejoYNTtjW7r6o8mzmJNar1Y+mOsAkPaMaM29ZiD5UXlGp35h9vQNWahEg4V/wX
         jt/2WUbRewIXwOzK/Yg+d9wG0W3En+JDb6jdHtbBg5hsLumphc22jFhSXlXdRq6euSsG
         ZpdVm4pb14ZpH4S+k1m9MvV9hd9u3eYmHf8l1SJPrwn8v2CCHXsyHsc9pyvrnEDGWqjq
         rnDuyJIhyyhuzh3FutwtnkHczzXuyLPoKHk7HsF0BJSy/2sCZLH4CUUefDFcMzHCcrgL
         yW5Q==
X-Gm-Message-State: AA+aEWZFZY9w3SOZ+fxmS2KjVgRBiLiaPIN/swG7xaNq7LPlSQBEL9qX
        VH7IanVIHTKQJhao92u0z3F/sN09
X-Google-Smtp-Source: AFSGD/UIw6lX105vbzW+zt99l2tS8IElQJ2X/4IurGWbCrE83qrV0kuf3ajvj7OfTWsI27kH6zGLSg==
X-Received: by 2002:a02:13c6:: with SMTP id 189mr12676147jaz.117.1545064763769;
        Mon, 17 Dec 2018 08:39:23 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v4sm11408437itv.20.2018.12.17.08.39.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:22 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGdLbU018569;
        Mon, 17 Dec 2018 16:39:21 GMT
Subject: [PATCH v4 00/30] NFS/RDMA client for next
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:39:21 -0500
Message-ID: <20181217162406.24133.27356.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'd like to see this series merged into next.

There have been several regressions related to the ->send_request
changes merged into v4.20. As a result, this series contains fixes
and clean-ups that resulted from testing and close code audit while
working on those regressions.

The soft IRQ warnings and DMAR faults that I observed with krb5
flavors on NFS/RDMA are now resolved by fixes included at the top
of this series. There is still an abnormal number of disconnects
with WRITE-intensive workloads on Kerberos, but recovery now
appears to be transparent to applications.

The patch removing deprecated Kerberos encryption types has been
dropped because there are still users who need this support. I will
look into simple ways to ensure these enctypes are working properly
and find more gentle deprecation schemes for a later merge window.


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
 include/linux/sunrpc/xprt.h                |    1 
 include/trace/events/rpcrdma.h             |  190 ++++++++++--
 include/trace/events/sunrpc.h              |  172 ++++-------
 net/sunrpc/auth_gss/gss_mech_switch.c      |    2 
 net/sunrpc/backchannel_rqst.c              |    2 
 net/sunrpc/xprt.c                          |   19 +
 net/sunrpc/xprtmultipath.c                 |    4 
 net/sunrpc/xprtrdma/Makefile               |    3 
 net/sunrpc/xprtrdma/backchannel.c          |   39 +-
 net/sunrpc/xprtrdma/fmr_ops.c              |  337 ---------------------
 net/sunrpc/xprtrdma/frwr_ops.c             |  209 ++++++++-----
 net/sunrpc/xprtrdma/rpc_rdma.c             |   74 ++---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    8 
 net/sunrpc/xprtrdma/transport.c            |   90 ++----
 net/sunrpc/xprtrdma/verbs.c                |  273 +++++++----------
 net/sunrpc/xprtrdma/xprt_rdma.h            |   79 +----
 net/sunrpc/xprtsock.c                      |    2 
 19 files changed, 935 insertions(+), 1035 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/fmr_ops.c

--
Chuck Lever
