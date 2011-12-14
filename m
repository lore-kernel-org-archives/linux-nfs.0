Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:26164 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311Ab1LNOgC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2011 09:36:02 -0500
Subject: Re: [PATCH 0/5] nfsd: overhaul the client name tracking code (RFC)
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
Date: Wed, 14 Dec 2011 09:35:57 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <18F62B11-1541-4B87-95A7-8106459903DF@oracle.com>
References: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 14, 2011, at 8:54 AM, Jeff Layton wrote:

> First, a little background: I've recently been tasked with a project
> to make active/active serving of NFSv4 from clustered filesystems work.
> This is a large-scale, long-term project, but there are pieces of the
> existing code that are clearly unsuitable in such a configuration...
> 
> One of the things that Bruce has long had on his wishlist is to replace
> the client name tracking code that the kernel uses:
> 
>    http://wiki.linux-nfs.org/wiki/index.php/Nfsd4_server_recovery
> 
> The existing code manipulates the filesystem directly to track this
> info. Not only is that something that makes the VFS maintainers look
> askance at knfsd, but it also is unsuitable in a clustered
> configuration.
> 
> Typically we think of the grace period as a property of the server, but
> with a clustered filesystem, we need to consider it as a property of the
> cluster as a whole. On a cold startup of the cluster, once any node
> grants a non-reclaim lock, then no more reclaim can be allowed on any
> node. Grace periods must be coordinated amongst all cluster nodes.

Agreed, but as you go forward with this effort, you should consider that NFSv4 migration allows individual file systems to be in grace.

> In order to achieve that goal, we need to first allow the client name
> reclaim to be cluster aware as well. This patchset is a move toward that
> goal and covers the initial kernel part of such a change. A patchset to
> add a daemon to handle the upcalls will follow.
> 
> Note that this patchset is still a little rough, so consider this an
> RFC for the overall design. We'll also need to consider a plan to
> deprecate the old client tracking code.
> 
> The goal with this patchset is to replace the existing functionality,
> without disturbing the existing code too much. There's some room for
> more cleanup and reorganization once the old tracker is gone.
> 
> Jeff Layton (5):
>  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
>  sunrpc: create nfsd dir in rpc_pipefs
>  nfsd: add a header describing upcall for clname tracking daemon
>  nfsd: add a cl_daddr field and a generic flags field to nfs4_client
>  nfsd: add the infrastructure to handle the clstate upcall
> 
> fs/nfsd/nfs4recover.c        |  442 +++++++++++++++++++++++++++++++++++++++++-
> fs/nfsd/nfs4state.c          |   49 ++---
> fs/nfsd/state.h              |   16 +-
> include/linux/nfsd/clstate.h |   59 ++++++
> net/sunrpc/rpc_pipe.c        |    5 +
> 5 files changed, 526 insertions(+), 45 deletions(-)
> create mode 100644 include/linux/nfsd/clstate.h
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




