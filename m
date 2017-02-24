Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33890 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdBXTCz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Feb 2017 14:02:55 -0500
Received: by mail-qt0-f178.google.com with SMTP id n21so24280444qta.1
        for <linux-nfs@vger.kernel.org>; Fri, 24 Feb 2017 11:02:55 -0800 (PST)
Message-ID: <1487962413.3314.6.camel@redhat.com>
Subject: Re: [PATCH v2 0/4] nfs/nfsd/sunrpc: enforce NFSv4 transport
 requirements
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tom Talpey <tom@talpey.com>, jgunthorpe@obsidianresearch.com
Date: Fri, 24 Feb 2017 13:53:33 -0500
In-Reply-To: <E56294C8-2F67-4279-A266-3C1E3B18F80C@oracle.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
         <20170224182525.10390-1-jlayton@redhat.com>
         <E56294C8-2F67-4279-A266-3C1E3B18F80C@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-02-24 at 10:38 -0800, Chuck Lever wrote:
> > On Feb 24, 2017, at 10:25 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > v2: comment clarifications, and commit log cleanup. No functional changes.
> > 
> > RFC5661 says:
> > 
> >   NFSv4.1 works over Remote Direct Memory Access (RDMA) and non-RDMA-
> >   based transports with the following attributes:
> > 
> > 
> >   o  The transport supports reliable delivery of data, which NFSv4.1
> >      requires but neither NFSv4.1 nor RPC has facilities for ensuring
> >      [34].
> > 
> >   o  The transport delivers data in the order it was sent.  Ordered
> >      delivery simplifies detection of transmit errors, and simplifies
> >      the sending of arbitrary sized requests and responses via the
> >      record marking protocol [3].
> > 
> > ...and then some hand-wavy stuff about congestion control. RFC7530
> > doesn't mention needing reliable and ordered delivery, but it does need
> > congestion control.
> > 
> > In practical terms, that means we should be excluding NFSv4 from UDP
> > transports. The NFS server has never enforced this requirement,
> > however, so a user could issue NFSv4 calls against the server via UDP.
> 
> RPC-over-RDMA Version One requires the use of RDMA Reliable
> Connections, which is a layer above the link layer that
> provides reliable, in-order delivery using connection
> semantics. This meets all stated transport requirements in
> RFC 5661.
> 
> The language of RFC 5661 says that UDP by itself must not be
> used for NFSv4. IMO the use of Reliable Connections with
> RPC-over-RDMA makes this a non-issue for NFSv4, even for RoCE
> v2.
> 
> rfc5667bis-06 was submitted this morning to address this.
> 

Thanks, I may plagiarize you and update the comment in rdma_create_xprt
if that's ok:

+       /*
+        * RPC-over-RDMA Version One requires the use of RDMA Reliable
+        * Connections, which is a layer above the link layer that provides
+        * reliable, in-order delivery using connection semantics.
+        */

I won't bother to re-post just for that though.

> > This patchset adds a small bit of infrastructure to the sunrpc layer to
> > enforce this requirement, and has the nfs and nfsd layers set the
> > appropriate flags for it on their server-side transports. It also has
> > the rpcbind client skip registering the protocol version on a UDP port
> > when that flag is set.
> > 
> > Lightly tested by hand, but it's fairly straightforward.
> > 
> > Jeff Layton (4):
> >  sunrpc: turn bitfield flags in svc_version into bools
> >  sunrpc: flag transports as having both reliable and ordered delivery,
> >    and congestion control
> >  nfs/nfsd/sunrpc: enforce transport requirements for NFSv4
> >  sunrpc: don't register UDP port with rpcbind when version needs
> >    congestion control
> > 
> > fs/nfs/callback_xdr.c                    |  6 ++++--
> > fs/nfsd/nfs2acl.c                        |  1 -
> > fs/nfsd/nfs3acl.c                        |  1 -
> > fs/nfsd/nfs4proc.c                       | 13 +++++++------
> > include/linux/sunrpc/svc.h               | 12 ++++++++----
> > include/linux/sunrpc/svc_xprt.h          |  1 +
> > net/sunrpc/svc.c                         | 23 ++++++++++++++++++++++-
> > net/sunrpc/svcsock.c                     |  1 +
> > net/sunrpc/xprtrdma/svc_rdma_transport.c |  8 ++++++++
> > 9 files changed, 51 insertions(+), 15 deletions(-)
> > 
> > -- 
> > 2.9.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 

-- 
Jeff Layton <jlayton@redhat.com>
