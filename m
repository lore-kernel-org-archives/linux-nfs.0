Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB0F3C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B06242184E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aDYSHrjT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727530AbfC1U4I (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:08 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:52643 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727182AbfC1U4I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:08 -0400
Received: by mail-it1-f196.google.com with SMTP id g17so470052ita.2
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ttCKUm0K0mJUnyym+Nx3C5IJyRODOkatSCyxBmB888Y=;
        b=aDYSHrjTtutMkI6pjqR2TGrn1KO6eWEdtpMXePcmdR/coI58scH+Ufa2Rx0kUADZq1
         peOhaVczU6xCF2q5L0B2/2s5N31AG6iZM4AFzFfgt4MLCGNjoXU2lK5EV5Pu0qWqrtbJ
         wPiXjRRtIXw2mpPvpQQ08Bp/MFvQUmV3DW1w2FMNbEg3hbnk5pd0Xz/WfAiBzlgs26gU
         /m5tVZlO8i64Y/aNdOtcFOBbpUGe0zM+d0z3uqcrDWtIa4tbjSn+LAVCKub2F3rmtTYt
         DXZuhY2Wc5rnp/tzvxjbZWIgXKWP554oNqWxSGp4H/2pYE8iy451YndlKF9vWgURWmw0
         jKhQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ttCKUm0K0mJUnyym+Nx3C5IJyRODOkatSCyxBmB888Y=;
        b=UCl1OP79QI31uINkiU+8honxNW5PoYnfSQF1jpPRTuHit4YMmetOus7e64AS+L+A1O
         K/CuRtKI/X6ucz6WdN2UhdCoVc25FmHxJ1vccTl5oOlH/SJ0zu2zXFYYk7tZKVhNsBj1
         K0WgQrIDcVNYq3BF4FJD3M6yyq9IoYf++WoP56eaXOHJDxSA/Q19MoJtDnrKRzKrsW/0
         YOpceon0SzfXHh34tT3EwenYBQnfuZL+zRtuP2PePnP82bYqJuLCf2p0ozj3XP5na2u/
         Id+cwcEDSlo4MbRsPDs+fYl7Yoex25JZUWY/GEr3zXnmF9QerDpJsBpON+Ok9XsIdQ5m
         3jdg==
X-Gm-Message-State: APjAAAWfwPbZfCx0zlwL+U9R6crtej2vj7kO6HT2PpV63e3ML57f7ndi
        D0c2NhDhs8voQU4fZ+YCQQo2Km8=
X-Google-Smtp-Source: APXvYqwa41lGV7pP/F7L9zMMuCbIS2P7zy+t0iakFyjHQMIPO1L29Vbgh9MT7TMHmXoAhD1We0ja6A==
X-Received: by 2002:a02:3787:: with SMTP id r129mr34201623jar.27.1553806566905;
        Thu, 28 Mar 2019 13:56:06 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:05 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 00/25] Fix up soft mounts for NFSv4.x
Date:   Thu, 28 Mar 2019 16:52:14 -0400
Message-Id: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patchset aims to make soft mounts a viable option for NFSv4 clients
by minimising the risk of false positive timeouts, while allowing for
faster failover of reads and writes once a timeout is actually observed.

The patches rely on the NFS server correctly implementing the contract
specified in RFC7530 section 3.1.1 with respect to not dropping requests
while the transport connection is up. When this is the case, the client
can safely assume that if the request has not received a reply after
transmitting a RPC request, it is not because the request was dropped,
but rather is due to congestion, or slow processing on the server.
IOW: as long as the connection remains up, there is no need for requests
to time out.

The patches break down roughly as follows:
- A set of patches to clean up the RPC engine timeouts, and ensure they
  are accurate.
- A set of patches to change the 'soft' mount semantics for NFSv4.x.
- A set of patches to add a new 'softerr' mount option that works like
  soft, but explicitly signals timeouts using the ETIMEDOUT error code
  rather than using EIO. This allows applications to tune their
  behaviour (e.g. by failing over to a different server) if a timeout
  occurs.
- A set of patches to change the NFS error reporting so that it matches
  that of local filesystems w.r.t. guarantees that filesystem errors are
  seen once and once only.
- A patch to ensure the safe interruption of NFS4ERR_DELAYed operations
- A patch to ensure that pNFS operations can be forced to break out
  of layout error cycles after a certain number of retries.
- A few cleanups...

Trond Myklebust (25):
  SUNRPC: Fix up task signalling
  SUNRPC: Refactor rpc_restart_call/rpc_restart_call_prepare
  SUNRPC: Refactor xprt_request_wait_receive()
  SUNRPC: Refactor rpc_sleep_on()
  SUNRPC: Remove unused argument 'action' from rpc_sleep_on_priority()
  SUNRPC: Add function rpc_sleep_on_timeout()
  SUNRPC: Fix up tracking of timeouts
  SUNRPC: Ensure that the transport layer respect major timeouts
  SUNRPC: Add tracking of RPC level errors
  SUNRPC: Make "no retrans timeout" soft tasks behave like softconn for
    timeouts
  SUNRPC: Start the first major timeout calculation at task creation
  SUNRPC: Add the 'softerr' rpc_client flag
  NFS: Consider ETIMEDOUT to be a fatal error
  NFS: Move internal constants out of uapi/linux/nfs_mount.h
  NFS: Add a mount option "softerr" to allow clients to see ETIMEDOUT
    errors
  NFS: Don't interrupt file writeout due to fatal errors
  NFS: Don't call generic_error_remove_page() while holding locks
  NFS: Don't inadvertently clear writeback errors
  NFS: Replace custom error reporting mechanism with generic one
  NFS: Fix up NFS I/O subrequest creation
  NFS: Remove unused argument from nfs_create_request()
  pNFS: Add tracking to limit the number of pNFS retries
  NFS: Allow signal interruption of NFS4ERR_DELAYed operations
  NFS: Add a helper to return a pointer to the open context of a struct
    nfs_page
  NFS: Remove redundant open context from nfs_page

 fs/lockd/clntproc.c                        |   4 +-
 fs/nfs/client.c                            |   2 +
 fs/nfs/direct.c                            |  11 +-
 fs/nfs/file.c                              |  31 +---
 fs/nfs/filelayout/filelayout.c             |   4 +-
 fs/nfs/flexfilelayout/flexfilelayout.c     |  14 +-
 fs/nfs/internal.h                          |   7 +-
 fs/nfs/nfs4_fs.h                           |   1 +
 fs/nfs/nfs4file.c                          |   2 +-
 fs/nfs/nfs4proc.c                          | 159 +++++++++++++++------
 fs/nfs/pagelist.c                          | 122 +++++++++-------
 fs/nfs/pnfs.c                              |   4 +-
 fs/nfs/pnfs.h                              |   4 +-
 fs/nfs/read.c                              |   6 +-
 fs/nfs/super.c                             |  15 +-
 fs/nfs/write.c                             |  67 +++++----
 fs/nfsd/nfs4callback.c                     |   4 +-
 include/linux/nfs_fs.h                     |   1 -
 include/linux/nfs_fs_sb.h                  |  10 ++
 include/linux/nfs_page.h                   |  12 +-
 include/linux/sunrpc/clnt.h                |   2 +
 include/linux/sunrpc/sched.h               |  19 ++-
 include/linux/sunrpc/xprt.h                |   6 +-
 include/trace/events/sunrpc.h              |   8 +-
 include/uapi/linux/nfs_mount.h             |   9 --
 net/sunrpc/auth_gss/auth_gss.c             |   5 +-
 net/sunrpc/clnt.c                          | 105 ++++++++------
 net/sunrpc/debugfs.c                       |   2 +-
 net/sunrpc/rpcb_clnt.c                     |   3 +-
 net/sunrpc/sched.c                         | 152 +++++++++++++++-----
 net/sunrpc/xprt.c                          | 146 ++++++++++++-------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   2 +-
 net/sunrpc/xprtrdma/transport.c            |   2 +-
 net/sunrpc/xprtsock.c                      |   9 +-
 34 files changed, 619 insertions(+), 331 deletions(-)

-- 
2.20.1

