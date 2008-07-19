From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/8] rpcbind v4 support in net/sunrpc/svc*
Date: Fri, 18 Jul 2008 21:07:38 -0400
Message-ID: <20080719010738.GA19106@fieldses.org>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59396 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbYGSBHx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2008 21:07:53 -0400
In-Reply-To: <20080630224147.24887.18730.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 06:45:21PM -0400, Chuck Lever wrote:
> Hi Bruce, Trond -
> 
> These implement basic support in net/sunrpc/svc* for registering IPv6-
> enabled kernel RPC services with the local user-space rpcbind.  These
> all depend on the new rpcb_v4_register() API I just posted.
> 
> The last patch enables IPv6 support for the NFSv4 callback service, even
> though it doesn't register with rpcbind.

There's some conflicts against my latest tree.  Would it be possible to
rebase to

	git://linux-nfs.org/~bfields/linux.git for-2.6.27

sometime?

--b.

> 
> ---
> 
> Chuck Lever (8):
>       NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets
>       SUNRPC: Set V6ONLY socket option for RPC listener sockets
>       SUNRPC: Add kernel build option to disable server-side use of rpcbind v3/v4
>       SUNRPC: Use new rpcb_v4_register() interface in svc_register()
>       SUNRPC: Clean up svc_register
>       SUNRPC: Split portmap unregister API into separate function
>       SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
>       SUNRPC: Add address family field to svc_serv data structure
> 
> 
>  fs/Kconfig                 |   22 +++++
>  fs/lockd/svc.c             |    2 
>  fs/nfs/callback.c          |   12 +-
>  fs/nfs/callback.h          |    4 -
>  fs/nfs/client.c            |    2 
>  fs/nfsd/nfssvc.c           |    1 
>  include/linux/sunrpc/svc.h |   11 +-
>  net/sunrpc/svc.c           |  212 ++++++++++++++++++++++++++++++++++++--------
>  net/sunrpc/svc_xprt.c      |   39 +++++++-
>  net/sunrpc/svcsock.c       |   12 ++
>  10 files changed, 260 insertions(+), 57 deletions(-)
> 
> -- 
> Chuck Lever
> chu ckl eve rat ora cle dot com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
