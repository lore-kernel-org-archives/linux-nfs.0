Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49461 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757794Ab0LTOqt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 09:46:49 -0500
Date: Mon, 20 Dec 2010 09:46:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 00/12] make rpc_pipefs be mountable multiple times
Message-ID: <20101220144644.GC20643@fieldses.org>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 20, 2010 at 01:54:26PM +0200, Kirill A. Shutsemov wrote:
> From: Kirill A. Shutemov <kirill@shutemov.name>
> 
> Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> Only for client for now.
> 
> Only quick sanity check was made. BTW, is there any check list for NFS
> contributors?

Nothing formal.

Chuck may have some nlm patches that conflict; I'm not sure what their
status is.

For testing rpc_pipefs, maybe a few mounts (simultaneous mounts might be
good), possibly over different security flavors, and with some of them
nfsv4, might be a good idea.

By the way, was there ever a resolution to Trond's question?:

	http://marc.info/?l=linux-nfs&m=128655758712817&w=2

	"The keyring upcalls are currently initiated through the same
	mechanism as module_request and therefore get started with the
	init_nsproxy namespace. We'd really like them to run inside the
	same container as the process.  As part of the same problem,
	there is the issue of what to do with the dns resolver and
	Bryan's new keyring based idmapper code."

--b.

> 
> Kirill A. Shutemov (12):
>   sunrpc: mount rpc_pipefs on initialization
>   sunrpc: introduce init_rpc_pipefs
>   sunrpc: push init_rpc_pipefs up to rpc_create() callers
>   sunrpc: tag svc_serv with rpc_pipefs mount point
>   sunrpc: get rpc_pipefs mount point for svc_serv from callers
>   lockd: get rpc_pipefs mount point from callers
>   sunrpc: get rpc_pipefs mount point for rpcb_create_local from callers
>   sunrpc: tag pipefs field of cache_detail with rpc_pipefs mount point
>   nfs: per-rpc_pipefs dns cache
>   sunrpc: introduce get_rpc_pipefs()
>   nfs: introduce mount option 'rpcmount'
>   sunrpc: make rpc_pipefs be mountable multiple times
> 
>  fs/lockd/clntlock.c                |    8 +-
>  fs/lockd/host.c                    |   12 +++-
>  fs/lockd/mon.c                     |   13 ++-
>  fs/lockd/svc.c                     |    4 +-
>  fs/nfs/cache_lib.c                 |   18 +----
>  fs/nfs/cache_lib.h                 |    3 +-
>  fs/nfs/callback.c                  |    6 +-
>  fs/nfs/callback.h                  |    3 +-
>  fs/nfs/client.c                    |   45 ++++++++++--
>  fs/nfs/dns_resolve.c               |  128 ++++++++++++++++++++++++++-------
>  fs/nfs/dns_resolve.h               |    8 +--
>  fs/nfs/inode.c                     |    8 +--
>  fs/nfs/internal.h                  |   10 ++-
>  fs/nfs/mount_clnt.c                |    1 +
>  fs/nfs/namespace.c                 |    3 +-
>  fs/nfs/nfs4namespace.c             |   20 +++--
>  fs/nfs/super.c                     |   20 +++++
>  fs/nfsd/nfs4callback.c             |    2 +
>  fs/nfsd/nfssvc.c                   |    8 +-
>  include/linux/lockd/bind.h         |    3 +-
>  include/linux/lockd/lockd.h        |    4 +-
>  include/linux/nfs_fs_sb.h          |    1 +
>  include/linux/sunrpc/cache.h       |    9 +--
>  include/linux/sunrpc/clnt.h        |    5 +-
>  include/linux/sunrpc/rpc_pipe_fs.h |    6 +-
>  include/linux/sunrpc/svc.h         |    9 +-
>  net/sunrpc/cache.c                 |   16 +++--
>  net/sunrpc/clnt.c                  |   19 +++--
>  net/sunrpc/rpc_pipe.c              |  142 ++++++++++++++++++++++++++++++------
>  net/sunrpc/rpcb_clnt.c             |   13 ++-
>  net/sunrpc/svc.c                   |   52 ++++++++-----
>  31 files changed, 430 insertions(+), 169 deletions(-)
> 
> -- 
> 1.7.3.4
> 
