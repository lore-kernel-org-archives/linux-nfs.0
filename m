Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55D2AC10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1222A20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OQ3Y34Pf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726362AbfDGSBX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:23 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:42044 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726335AbfDGSBW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:22 -0400
Received: by mail-io1-f68.google.com with SMTP id c4so9064707ioh.9
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=e05vGaiTtED9qIyjrvvqpioEUqwW4hkk4DuJhV/x+Hw=;
        b=OQ3Y34PfGyzZyzUeUNQ3oGUqPiQmORBS5BLkI0evnOegymto6puj3Y0NWqEvCOUJCc
         ROYYSdJBW4YX6PwFMaWxT7veyYjCh1R6+N13nTxbCZ9xVS6aXQVx6eJUqeAsU8j5yBM3
         C6K8oqoskttHjM2iEDx07jjcj3vYX8FjFcwSnXoL52QOyEo8BqFvl8e0CM9PPkW521hJ
         21wKBSZDsWXmdScN2djRxbO9I8Yq5mv4gWjW2+gxKROl/FYBSpLCub6gHT1TZx4FbQA0
         wBlFGHGvZZdqTgFnqhfd6R6M1yD55i6QgBLSiC7IR+d+Yd3z06ivTUJzyDH9jBbRjZRx
         G/iQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=e05vGaiTtED9qIyjrvvqpioEUqwW4hkk4DuJhV/x+Hw=;
        b=pjkDNP/Uav56nhNS5TgeIiGlBQT4EuBtFFKYqZZSFgL+SNANqE1POsBQ1bYMvfcOoA
         UtcLkQw+1tOROriLSa4fGdvoRfZd+J+A8cR5It4vLlIEnvFswyMO9ShYf7blEdiDO0B9
         XNAxUUczkcZW6mrvwKwkvOThc+C/ygnTyPihisQg6Cjha3lPPt73Tmpxp0x09ZOSp6q/
         Z3ie5hKzqKRDPmEgBWepA01+KzNc2ZiOdNFcZRC4F2l9VRgurLvuw2ACZ5ymH7f3SCDv
         HQwbO1/HiIeMjlRS8sbtIdzcldpI1uY58YvSc/xwr2dJdWMCKFMwVccttGqWxlMIAAH5
         9CLA==
X-Gm-Message-State: APjAAAVlAW2PXyXMWmmFeTA80xKdTN+e88Z4qRUTz3dPrPFkWjt/d0Da
        NorIiGH/fAJDm2UAeeBSGw==
X-Google-Smtp-Source: APXvYqw9bFEmSNd/W5an7oe1qzMRvJX+o+l+MGpqkzIb1t3PIWOz/B23ACvKmm/2nua9394tYBOwDA==
X-Received: by 2002:a5d:8248:: with SMTP id n8mr10809513ioo.125.1554660081226;
        Sun, 07 Apr 2019 11:01:21 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:19 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 00/29] Fix up soft mounts for NFSv4.x
Date:   Sun,  7 Apr 2019 13:58:43 -0400
Message-Id: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
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

-------
Changes since v1:
- Change NFSv4 soft timeout condition to prevent all requests from
  timing out when the connection is still up, instead of just the
  ones that have been sent.
- RPC queue timer cleanups
- Ratelimit the "server not responding" messages
Changes since v2:
- Fix potential NULL dereference issues pointed out by Dan Carpenter
- Ensure lock contexts keeps a reference to the open context


Trond Myklebust (29):
  SUNRPC: Fix up task signalling
  SUNRPC: Refactor rpc_restart_call/rpc_restart_call_prepare
  SUNRPC: Refactor xprt_request_wait_receive()
  SUNRPC: Refactor rpc_sleep_on()
  SUNRPC: Remove unused argument 'action' from rpc_sleep_on_priority()
  SUNRPC: Add function rpc_sleep_on_timeout()
  SUNRPC: Fix up tracking of timeouts
  SUNRPC: Simplify queue timeouts using timer_reduce()
  SUNRPC: Declare RPC timers as TIMER_DEFERRABLE
  SUNRPC: Ensure that the transport layer respect major timeouts
  SUNRPC: Add tracking of RPC level errors
  SUNRPC: Make "no retrans timeout" soft tasks behave like softconn for
    timeouts
  SUNRPC: Start the first major timeout calculation at task creation
  SUNRPC: Ensure to ratelimit the "server not responding" syslog
    messages
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
  NFS: Ensure that all nfs lock contexts have a valid open context
  NFS: Add a helper to return a pointer to the open context of a struct
    nfs_page
  NFS: Remove redundant open context from nfs_page

 fs/lockd/clntproc.c                        |   4 +-
 fs/nfs/client.c                            |   2 +
 fs/nfs/direct.c                            |  11 +-
 fs/nfs/file.c                              |  31 +---
 fs/nfs/filelayout/filelayout.c             |   4 +-
 fs/nfs/flexfilelayout/flexfilelayout.c     |  14 +-
 fs/nfs/inode.c                             |  13 +-
 fs/nfs/internal.h                          |   7 +-
 fs/nfs/nfs4_fs.h                           |   1 +
 fs/nfs/nfs4file.c                          |   2 +-
 fs/nfs/nfs4proc.c                          | 159 +++++++++++++++------
 fs/nfs/pagelist.c                          | 123 +++++++++-------
 fs/nfs/pnfs.c                              |   4 +-
 fs/nfs/pnfs.h                              |   4 +-
 fs/nfs/read.c                              |   6 +-
 fs/nfs/super.c                             |  15 +-
 fs/nfs/write.c                             |  70 +++++----
 fs/nfsd/nfs4callback.c                     |   4 +-
 include/linux/nfs_fs.h                     |   1 -
 include/linux/nfs_fs_sb.h                  |  10 ++
 include/linux/nfs_page.h                   |  12 +-
 include/linux/sunrpc/clnt.h                |   2 +
 include/linux/sunrpc/sched.h               |  20 ++-
 include/linux/sunrpc/xprt.h                |   6 +-
 include/trace/events/sunrpc.h              |   8 +-
 include/uapi/linux/nfs_mount.h             |   9 --
 net/sunrpc/auth_gss/auth_gss.c             |   5 +-
 net/sunrpc/clnt.c                          | 116 +++++++++------
 net/sunrpc/debugfs.c                       |   2 +-
 net/sunrpc/rpcb_clnt.c                     |   3 +-
 net/sunrpc/sched.c                         | 158 +++++++++++++++-----
 net/sunrpc/xprt.c                          | 150 ++++++++++++-------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   2 +-
 net/sunrpc/xprtrdma/transport.c            |   2 +-
 net/sunrpc/xprtsock.c                      |   9 +-
 35 files changed, 643 insertions(+), 346 deletions(-)

-- 
2.20.1

