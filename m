Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750838Ab1LNOtb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 09:49:31 -0500
Date: Wed, 14 Dec 2011 09:49:20 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] nfsd: overhaul the client name tracking code (RFC)
Message-ID: <20111214094920.6d3fafa8@tlielax.poochiereds.net>
In-Reply-To: <18F62B11-1541-4B87-95A7-8106459903DF@oracle.com>
References: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
	<18F62B11-1541-4B87-95A7-8106459903DF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Dec 2011 09:35:57 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Dec 14, 2011, at 8:54 AM, Jeff Layton wrote:
> 
> > First, a little background: I've recently been tasked with a project
> > to make active/active serving of NFSv4 from clustered filesystems work.
> > This is a large-scale, long-term project, but there are pieces of the
> > existing code that are clearly unsuitable in such a configuration...
> > 
> > One of the things that Bruce has long had on his wishlist is to replace
> > the client name tracking code that the kernel uses:
> > 
> >    http://wiki.linux-nfs.org/wiki/index.php/Nfsd4_server_recovery
> > 
> > The existing code manipulates the filesystem directly to track this
> > info. Not only is that something that makes the VFS maintainers look
> > askance at knfsd, but it also is unsuitable in a clustered
> > configuration.
> > 
> > Typically we think of the grace period as a property of the server, but
> > with a clustered filesystem, we need to consider it as a property of the
> > cluster as a whole. On a cold startup of the cluster, once any node
> > grants a non-reclaim lock, then no more reclaim can be allowed on any
> > node. Grace periods must be coordinated amongst all cluster nodes.
> 
> Agreed, but as you go forward with this effort, you should consider that NFSv4 migration allows individual file systems to be in grace.
> 

Yes. The eventual goal is eliminate the grace period on failovers once
the cluster fs is up and running, and out of its initial grace period.

In order to do that, we'll need to push grace period handling into the
VFS layer to some degree, probably by providing a standard set of grace
period handling ops and allowing the filesystems to override them in
some fashion (maybe a new set of export ops?).

In any case, design of that is a later phase of this project once I get
this part settled...

> > In order to achieve that goal, we need to first allow the client name
> > reclaim to be cluster aware as well. This patchset is a move toward that
> > goal and covers the initial kernel part of such a change. A patchset to
> > add a daemon to handle the upcalls will follow.
> > 
> > Note that this patchset is still a little rough, so consider this an
> > RFC for the overall design. We'll also need to consider a plan to
> > deprecate the old client tracking code.
> > 
> > The goal with this patchset is to replace the existing functionality,
> > without disturbing the existing code too much. There's some room for
> > more cleanup and reorganization once the old tracker is gone.
> > 
> > Jeff Layton (5):
> >  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
> >  sunrpc: create nfsd dir in rpc_pipefs
> >  nfsd: add a header describing upcall for clname tracking daemon
> >  nfsd: add a cl_daddr field and a generic flags field to nfs4_client
> >  nfsd: add the infrastructure to handle the clstate upcall
> > 
> > fs/nfsd/nfs4recover.c        |  442 +++++++++++++++++++++++++++++++++++++++++-
> > fs/nfsd/nfs4state.c          |   49 ++---
> > fs/nfsd/state.h              |   16 +-
> > include/linux/nfsd/clstate.h |   59 ++++++
> > net/sunrpc/rpc_pipe.c        |    5 +
> > 5 files changed, 526 insertions(+), 45 deletions(-)
> > create mode 100644 include/linux/nfsd/clstate.h
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
