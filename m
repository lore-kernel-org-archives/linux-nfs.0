Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42246 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751277AbdBXV0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 16:26:39 -0500
Date: Fri, 24 Feb 2017 16:25:16 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com, tom@talpey.com,
        jgunthorpe@obsidianresearch.com
Subject: Re: [PATCH v2 0/4] nfs/nfsd/sunrpc: enforce NFSv4 transport
 requirements
Message-ID: <20170224212516.GH26378@fieldses.org>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170224182525.10390-1-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170224182525.10390-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The one other minor thing we could do is skip adding the UDP listener
entirely in the v4-only case.  I think that's a job for rpc.nfsd?

--b.

On Fri, Feb 24, 2017 at 01:25:21PM -0500, Jeff Layton wrote:
> v2: comment clarifications, and commit log cleanup. No functional changes.
> 
> RFC5661 says:
> 
>    NFSv4.1 works over Remote Direct Memory Access (RDMA) and non-RDMA-
>    based transports with the following attributes:
> 
> 
>    o  The transport supports reliable delivery of data, which NFSv4.1
>       requires but neither NFSv4.1 nor RPC has facilities for ensuring
>       [34].
> 
>    o  The transport delivers data in the order it was sent.  Ordered
>       delivery simplifies detection of transmit errors, and simplifies
>       the sending of arbitrary sized requests and responses via the
>       record marking protocol [3].
> 
> ...and then some hand-wavy stuff about congestion control. RFC7530
> doesn't mention needing reliable and ordered delivery, but it does need
> congestion control.
> 
> In practical terms, that means we should be excluding NFSv4 from UDP
> transports. The NFS server has never enforced this requirement,
> however, so a user could issue NFSv4 calls against the server via UDP.
> 
> This patchset adds a small bit of infrastructure to the sunrpc layer to
> enforce this requirement, and has the nfs and nfsd layers set the
> appropriate flags for it on their server-side transports. It also has
> the rpcbind client skip registering the protocol version on a UDP port
> when that flag is set.
> 
> Lightly tested by hand, but it's fairly straightforward.
> 
> Jeff Layton (4):
>   sunrpc: turn bitfield flags in svc_version into bools
>   sunrpc: flag transports as having both reliable and ordered delivery,
>     and congestion control
>   nfs/nfsd/sunrpc: enforce transport requirements for NFSv4
>   sunrpc: don't register UDP port with rpcbind when version needs
>     congestion control
> 
>  fs/nfs/callback_xdr.c                    |  6 ++++--
>  fs/nfsd/nfs2acl.c                        |  1 -
>  fs/nfsd/nfs3acl.c                        |  1 -
>  fs/nfsd/nfs4proc.c                       | 13 +++++++------
>  include/linux/sunrpc/svc.h               | 12 ++++++++----
>  include/linux/sunrpc/svc_xprt.h          |  1 +
>  net/sunrpc/svc.c                         | 23 ++++++++++++++++++++++-
>  net/sunrpc/svcsock.c                     |  1 +
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |  8 ++++++++
>  9 files changed, 51 insertions(+), 15 deletions(-)
> 
> -- 
> 2.9.3
