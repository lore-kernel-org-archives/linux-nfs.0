Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42286 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751291AbdBXVvm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 16:51:42 -0500
Date: Fri, 24 Feb 2017 16:44:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com, tom@talpey.com,
        jgunthorpe@obsidianresearch.com
Subject: Re: [PATCH v2 0/4] nfs/nfsd/sunrpc: enforce NFSv4 transport
 requirements
Message-ID: <20170224214442.GI26378@fieldses.org>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170224182525.10390-1-jlayton@redhat.com>
 <20170224212516.GH26378@fieldses.org>
 <1487972064.3314.8.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1487972064.3314.8.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 24, 2017 at 04:34:24PM -0500, Jeff Layton wrote:
> On Fri, 2017-02-24 at 16:25 -0500, J. Bruce Fields wrote:
> > The one other minor thing we could do is skip adding the UDP listener
> > entirely in the v4-only case.  I think that's a job for rpc.nfsd?
> > 
> > --b.
> > 
> 
> Yeah I think we'd need to fix that in rpc.nfsd.
> 
> Maybe it's time to just start doing having it do TCP-only by default
> anyway? Make it so you have to explicitly enable UDP listeners if you
> want them? Does anyone seriously run NFS over UDP these days for
> anything other than interop testing? :)

I thought I remembered somebody floating this on linux-nfs a couple
years ago and finding there were still a couple vocal users.  Or maybe
that was NFSv2.  I can't find the thread now.

I'm pretty conservative about anything that might break people's ancient
but working setups on upgrade, but maybe it's time.

Just switching the default to off in nfs-utils first would be the way to
go, I think, then if that goes well we could think about phasing out
kernel support.

--b.

> 
> 
> > On Fri, Feb 24, 2017 at 01:25:21PM -0500, Jeff Layton wrote:
> > > v2: comment clarifications, and commit log cleanup. No functional changes.
> > > 
> > > RFC5661 says:
> > > 
> > >    NFSv4.1 works over Remote Direct Memory Access (RDMA) and non-RDMA-
> > >    based transports with the following attributes:
> > > 
> > > 
> > >    o  The transport supports reliable delivery of data, which NFSv4.1
> > >       requires but neither NFSv4.1 nor RPC has facilities for ensuring
> > >       [34].
> > > 
> > >    o  The transport delivers data in the order it was sent.  Ordered
> > >       delivery simplifies detection of transmit errors, and simplifies
> > >       the sending of arbitrary sized requests and responses via the
> > >       record marking protocol [3].
> > > 
> > > ...and then some hand-wavy stuff about congestion control. RFC7530
> > > doesn't mention needing reliable and ordered delivery, but it does need
> > > congestion control.
> > > 
> > > In practical terms, that means we should be excluding NFSv4 from UDP
> > > transports. The NFS server has never enforced this requirement,
> > > however, so a user could issue NFSv4 calls against the server via UDP.
> > > 
> > > This patchset adds a small bit of infrastructure to the sunrpc layer to
> > > enforce this requirement, and has the nfs and nfsd layers set the
> > > appropriate flags for it on their server-side transports. It also has
> > > the rpcbind client skip registering the protocol version on a UDP port
> > > when that flag is set.
> > > 
> > > Lightly tested by hand, but it's fairly straightforward.
> > > 
> > > Jeff Layton (4):
> > >   sunrpc: turn bitfield flags in svc_version into bools
> > >   sunrpc: flag transports as having both reliable and ordered delivery,
> > >     and congestion control
> > >   nfs/nfsd/sunrpc: enforce transport requirements for NFSv4
> > >   sunrpc: don't register UDP port with rpcbind when version needs
> > >     congestion control
> > > 
> > >  fs/nfs/callback_xdr.c                    |  6 ++++--
> > >  fs/nfsd/nfs2acl.c                        |  1 -
> > >  fs/nfsd/nfs3acl.c                        |  1 -
> > >  fs/nfsd/nfs4proc.c                       | 13 +++++++------
> > >  include/linux/sunrpc/svc.h               | 12 ++++++++----
> > >  include/linux/sunrpc/svc_xprt.h          |  1 +
> > >  net/sunrpc/svc.c                         | 23 ++++++++++++++++++++++-
> > >  net/sunrpc/svcsock.c                     |  1 +
> > >  net/sunrpc/xprtrdma/svc_rdma_transport.c |  8 ++++++++
> > >  9 files changed, 51 insertions(+), 15 deletions(-)
> > > 
> > > -- 
> > > 2.9.3
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
