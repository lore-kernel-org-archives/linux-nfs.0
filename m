Return-Path: <SRS0=xBSR=SD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D898BC43381
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 16:54:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9CFA7208E4
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 16:54:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="ZELCsbDy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728698AbfDAQy0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Apr 2019 12:54:26 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:44638 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728007AbfDAQyZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2019 12:54:25 -0400
Received: by mail-vs1-f67.google.com with SMTP id j184so5935585vsd.11
        for <linux-nfs@vger.kernel.org>; Mon, 01 Apr 2019 09:54:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=e7OhMzXoUZtLODvR4yRiSE5AR12gHeGWcJA8HAEwYGo=;
        b=ZELCsbDydm45azcJmdNnnOz0x2dbqr+FQ6jMVC0/s3sKTf3JZn04OkAgzfKeLUddW0
         jpZzTHHsl3FLayFkh7Wy7nP9Sy0J4vX2gUD7uYBViG3Zr5qs1/IfpxDmP1fdyQZuwv61
         4oSQVNwmA6ZlYC5yshvWyfdTYzHqacZviq2pMxCrxkbprwkq5iiOvj/q2nq2uJnEzzWo
         GTbyjodMbymE3yGz6B3nmOtJmgndZIsnchB6FxOMd+qztKa43/f9HlVlO9ckCE/z9DET
         Uu2IsLVWtO4G3BmGEBDIKWX16u76/+5rklGzH6sw8l8+Nq/ktafu4nxHdsTdOSKBCelI
         qqiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=e7OhMzXoUZtLODvR4yRiSE5AR12gHeGWcJA8HAEwYGo=;
        b=UXcfQvPDhrZGxOGrPaLBf0Spv+rb7fD7Hbj4ASL1ecWUmTf6zypTc6oEhZNjwKkzMv
         7IEcPgKqs19g+rmVVycPLGuhpYnBFNzmjHmPndw2w34MdK2ibX7pgVzuBkILr2mQ1jV+
         OIB02PXfRhGfgtK0D3aaY/f0uKhZpyg5buB5MF4jE19y6c7s9Z6al9SGeoVwBhmb5V/H
         6PriwE94k88SmqEIBWoDuggnBe0IW0jcuJkBRBw3ETG/OLv9x/23DPQ7CkF7F6+3+Xr9
         MhdEbiNNsS5CAK596s9SVWwZglK06daYKL7EfVcmGby3ZKPsX9EBCxXzbkZarLzI1Ksh
         Elww==
X-Gm-Message-State: APjAAAUhMD6UBKaJjw6SVgWl5lXsNUIncqYsBDZXxv1QE/SzKcPgLzIF
        R78piPDO/yBEJ676RoHQt8L/QyJsj9Ff3N7P8ok=
X-Google-Smtp-Source: APXvYqwsVG3GG/4HD1iauoUYnoxmdMyBdXUat6x3s/R5LfHuR5EPTjNpyu9gjHqOH9ZkbXoO0xLGfEMRAsnSBZddqfo=
X-Received: by 2002:a67:db09:: with SMTP id z9mr22314856vsj.127.1554137664505;
 Mon, 01 Apr 2019 09:54:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
In-Reply-To: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 1 Apr 2019 12:54:13 -0400
Message-ID: <CAN-5tyHGWp1o7v4bYCsEFxRJpBhH9Qg9ieGZYDjBVdmtua9KPA@mail.gmail.com>
Subject: Re: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 29, 2019 at 6:02 PM Trond Myklebust <trondmy@gmail.com> wrote:
>
> This patchset aims to make soft mounts a viable option for NFSv4 clients
> by minimising the risk of false positive timeouts, while allowing for
> faster failover of reads and writes once a timeout is actually observed.
>
> The patches rely on the NFS server correctly implementing the contract
> specified in RFC7530 section 3.1.1 with respect to not dropping requests
> while the transport connection is up. When this is the case, the client
> can safely assume that if the request has not received a reply after
> transmitting a RPC request, it is not because the request was dropped,
> but rather is due to congestion, or slow processing on the server.
> IOW: as long as the connection remains up, there is no need for requests
> to time out.
>
> The patches break down roughly as follows:
> - A set of patches to clean up the RPC engine timeouts, and ensure they
>   are accurate.
> - A set of patches to change the 'soft' mount semantics for NFSv4.x.
> - A set of patches to add a new 'softerr' mount option that works like
>   soft, but explicitly signals timeouts using the ETIMEDOUT error code
>   rather than using EIO. This allows applications to tune their
>   behaviour (e.g. by failing over to a different server) if a timeout
>   occurs.

I'm just curious why would an application be aware of a different
server to connect to and an NFS layer would not be? I'm also curious
wouldn't it break application that typically expect to get an EIO
errors? Do all system calls allow to return ETIMEDOUT error?

> - A set of patches to change the NFS error reporting so that it matches
>   that of local filesystems w.r.t. guarantees that filesystem errors are
>   seen once and once only.
> - A patch to ensure the safe interruption of NFS4ERR_DELAYed operations
> - A patch to ensure that pNFS operations can be forced to break out
>   of layout error cycles after a certain number of retries.
> - A few cleanups...
>
> -------
> Changes since v1:
> - Change NFSv4 soft timeout condition to prevent all requests from
>   timing out when the connection is still up, instead of just the
>   ones that have been sent.
> - RPC queue timer cleanups
> - Ratelimit the "server not responding" messages
>
>
> *** BLURB HERE ***
>
> Trond Myklebust (28):
>   SUNRPC: Fix up task signalling
>   SUNRPC: Refactor rpc_restart_call/rpc_restart_call_prepare
>   SUNRPC: Refactor xprt_request_wait_receive()
>   SUNRPC: Refactor rpc_sleep_on()
>   SUNRPC: Remove unused argument 'action' from rpc_sleep_on_priority()
>   SUNRPC: Add function rpc_sleep_on_timeout()
>   SUNRPC: Fix up tracking of timeouts
>   SUNRPC: Simplify queue timeouts using timer_reduce()
>   SUNRPC: Declare RPC timers as TIMER_DEFERRABLE
>   SUNRPC: Ensure that the transport layer respect major timeouts
>   SUNRPC: Add tracking of RPC level errors
>   SUNRPC: Make "no retrans timeout" soft tasks behave like softconn for
>     timeouts
>   SUNRPC: Start the first major timeout calculation at task creation
>   SUNRPC: Ensure to ratelimit the "server not responding" syslog
>     messages
>   SUNRPC: Add the 'softerr' rpc_client flag
>   NFS: Consider ETIMEDOUT to be a fatal error
>   NFS: Move internal constants out of uapi/linux/nfs_mount.h
>   NFS: Add a mount option "softerr" to allow clients to see ETIMEDOUT
>     errors
>   NFS: Don't interrupt file writeout due to fatal errors
>   NFS: Don't call generic_error_remove_page() while holding locks
>   NFS: Don't inadvertently clear writeback errors
>   NFS: Replace custom error reporting mechanism with generic one
>   NFS: Fix up NFS I/O subrequest creation
>   NFS: Remove unused argument from nfs_create_request()
>   pNFS: Add tracking to limit the number of pNFS retries
>   NFS: Allow signal interruption of NFS4ERR_DELAYed operations
>   NFS: Add a helper to return a pointer to the open context of a struct
>     nfs_page
>   NFS: Remove redundant open context from nfs_page
>
>  fs/lockd/clntproc.c                        |   4 +-
>  fs/nfs/client.c                            |   2 +
>  fs/nfs/direct.c                            |  11 +-
>  fs/nfs/file.c                              |  31 +---
>  fs/nfs/filelayout/filelayout.c             |   4 +-
>  fs/nfs/flexfilelayout/flexfilelayout.c     |  14 +-
>  fs/nfs/internal.h                          |   7 +-
>  fs/nfs/nfs4_fs.h                           |   1 +
>  fs/nfs/nfs4file.c                          |   2 +-
>  fs/nfs/nfs4proc.c                          | 159 +++++++++++++++------
>  fs/nfs/pagelist.c                          | 122 +++++++++-------
>  fs/nfs/pnfs.c                              |   4 +-
>  fs/nfs/pnfs.h                              |   4 +-
>  fs/nfs/read.c                              |   6 +-
>  fs/nfs/super.c                             |  15 +-
>  fs/nfs/write.c                             |  67 +++++----
>  fs/nfsd/nfs4callback.c                     |   4 +-
>  include/linux/nfs_fs.h                     |   1 -
>  include/linux/nfs_fs_sb.h                  |  10 ++
>  include/linux/nfs_page.h                   |  12 +-
>  include/linux/sunrpc/clnt.h                |   2 +
>  include/linux/sunrpc/sched.h               |  20 ++-
>  include/linux/sunrpc/xprt.h                |   6 +-
>  include/trace/events/sunrpc.h              |   8 +-
>  include/uapi/linux/nfs_mount.h             |   9 --
>  net/sunrpc/auth_gss/auth_gss.c             |   5 +-
>  net/sunrpc/clnt.c                          | 116 +++++++++------
>  net/sunrpc/debugfs.c                       |   2 +-
>  net/sunrpc/rpcb_clnt.c                     |   3 +-
>  net/sunrpc/sched.c                         | 158 +++++++++++++++-----
>  net/sunrpc/xprt.c                          | 150 ++++++++++++-------
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   2 +-
>  net/sunrpc/xprtrdma/transport.c            |   2 +-
>  net/sunrpc/xprtsock.c                      |   9 +-
>  34 files changed, 631 insertions(+), 341 deletions(-)
>
> --
> 2.20.1
>
