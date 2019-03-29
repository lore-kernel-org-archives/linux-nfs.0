Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE1F1C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:01:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 763BF2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:01:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p4IWJ5JU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730220AbfC2WB6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:01:58 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:42033 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730137AbfC2WB6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:01:58 -0400
Received: by mail-io1-f66.google.com with SMTP id c4so2977509ioh.9
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:01:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=dPA/uMKkT+Dt8NUk8ayNFLADkFmDjfvxqU7iyB/MaX0=;
        b=p4IWJ5JU7MKByTmr8OihxvmFw37lq85Oksn2fPWBTjDBXw8FRjH0stz8puHnHexhE8
         D47Ph0NsgMWdcuZ3vfx4ZfjyaJ+1aCBbo5lwCzFfSoH67tWsdSNZcwyizX7NzKHr5xDa
         s3lASVUxQke3zmNfanjoPlXYM7slzcC8gvhed78HfLp1PDoNU8V+hoggayYNU8aF7dEm
         bmGz933WOispAIAxTLqAGAC3A5bPiAipXpaMlyWGGRCC+sF7VXqToPOwvSvYpLekNSTn
         a78WowNrWvxT0FfXqpYZmvPHmL6LLmg/BngimLbt0XlBtX5peJaAo998NYAPbIwJ9wfd
         gCHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=dPA/uMKkT+Dt8NUk8ayNFLADkFmDjfvxqU7iyB/MaX0=;
        b=G4np+A16zS8/VvNa7zstUPhMp0Rp2zf69I0FL7ycdXbQqpnXC0u9q3DlS6+oSvclNr
         Vu+YC0lW4cB4W6o/EXPmSdf+nxmI2yhgxJbn0gRI2T6pdBMbVxaiqL3XqbkW2xsfLAjD
         /TBFKs6nSrLf5mbwRYm7vjZ4s2cDs9FpQ7XHkJ1b/uXKW/xT6homWRy9bLbWsi8gloeV
         MLbkKNIlUcMWIjyPVbHGWfUpTQ5vAL+krB+cjlALDDdyewfdqxCMj0ZAR+uwSuaS1lAN
         7kbj+oPdV/VxRtWdztvCME3Vbb06GzTyZZnlqqIy4kiyWyciyFNV4K2NlJr7xDA8MAxp
         AEew==
X-Gm-Message-State: APjAAAWAYvbCYtcSkF7q43q+nDEVN3gejp2tlO+lVrl+reomN6KxcnTk
        n9dxGd/6vOSrbkvcszSWVkKq20Q=
X-Google-Smtp-Source: APXvYqw2xVM8E/BI7uw6tbOMNrzQd/bI+m4cG/rmhIe/FWsNEHWzUyg4T1LkppJNFt1BTDzwwxqmnw==
X-Received: by 2002:a5e:df06:: with SMTP id f6mr3060226ioq.199.1553896916662;
        Fri, 29 Mar 2019 15:01:56 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.01.55
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:01:55 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
Date:   Fri, 29 Mar 2019 17:59:20 -0400
Message-Id: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
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


*** BLURB HERE ***

Trond Myklebust (28):
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
 34 files changed, 631 insertions(+), 341 deletions(-)

-- 
2.20.1

