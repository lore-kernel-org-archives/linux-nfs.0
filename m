Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36375 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751614AbdBWR1c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 12:27:32 -0500
Received: by mail-qk0-f194.google.com with SMTP id r90so5630930qki.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2017 09:27:31 -0800 (PST)
Message-ID: <1487870253.3448.4.camel@poochiereds.net>
Subject: Re: [PATCH 0/4] nfs/nfsd/sunrpc: enforce requirement for congestion
 control protocols in NFSv4
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org
Date: Thu, 23 Feb 2017 12:17:33 -0500
In-Reply-To: <20170223170337.10686-1-jlayton@redhat.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-02-23 at 12:03 -0500, Jeff Layton wrote:
> RFC5661 says:
> 
>    Where an NFSv4.1 implementation supports operation over the IP
>    network protocol, any transport used between NFS and IP MUST be among
>    the IETF-approved congestion control transport protocols.
> 
> ...and RFC7530 has similar verbiage. The NFS server has never enforced
> this requirement, however, so a user could issue NFSv4 calls against
> the server via UDP.
> 
> This patchset adds a small bit of infrastructure to the sunrpc layer
> to enforce this requirement, and has the nfs and nfsd layers set the
> appropriate flags for it. It also has knfsd skip registering a UDP
> port for NFSv4, using the same flags.
> 
> Lightly tested by hand, but it's fairly straightforward.
> 
> Jeff Layton (4):
>   sunrpc: flag transports as using IETF approved congestion control
>     protocols
>   sunrpc: turn bitfield flags in svc_version into bools
>   nfs/nfsd/sunrpc: enforce congestion control protocol requirement for
>     NFSv4
>   sunrpc: don't register UDP port with rpcbind when version needs
>     congestion control
> 
>  fs/nfs/callback_xdr.c                    |  6 ++++--
>  fs/nfsd/nfs2acl.c                        |  1 -
>  fs/nfsd/nfs3acl.c                        |  1 -
>  fs/nfsd/nfs4proc.c                       | 13 +++++++------
>  include/linux/sunrpc/svc.h               | 12 ++++++++----
>  include/linux/sunrpc/svc_xprt.h          |  1 +
>  net/sunrpc/svc.c                         | 22 +++++++++++++++++++++-
>  net/sunrpc/svcsock.c                     |  1 +
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |  2 ++
>  9 files changed, 44 insertions(+), 15 deletions(-)
> 

I probably should have sent this as an RFC first. I'm not 100% clear on
whether PROG_MISMATCH is the right return code there.

Also, there is still a small wart after this patchset. The high/low
program versions reported look a little odd:

    $ rpcinfo -T udp knfsdsrv nfs 4
    rpcinfo: RPC: Program/version mismatch; low version = 3, high version = 4
    program 100003 version 4 is not available

We could try to fix this and report different values depending on the
socket type, but I'm not sure I really care. AFAIK, this is just
informative anyway, and it's not _technically_ wrong. The server does
support version 4, just not the UDP socket where we sent the RPC ping.

Thoughts?
-- 
Jeff Layton <jlayton@poochiereds.net>
