From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] Register kernel RPC services via rpcbind v4
Date: Wed, 20 Aug 2008 19:20:02 -0400
Message-ID: <20080820232002.GA28617@fieldses.org>
References: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754785AbYHTXUG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 19:20:06 -0400
In-Reply-To: <20080818233128.1214.48603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 18, 2008 at 07:33:20PM -0400, Chuck Lever wrote:
> Hi Bruce, Trond-
> 
> Here's the patch series that adds rpcbind v4 support to svc_register(), with
> the simplification we discussed last week.  I think this looks cleaner.
> 
> Please consider these for 2.6.28.

Thanks. I've applied #5, #6, and 37 (#2, #3, and #4 were already
applied--let me know if my versions are out of date--and #1 I'll leave
to Trond):

	git://linux-nfs.org/~bfields/linux.git for-2.6.28

Keep sending patches....

--b.


> 
> ---
> 
> Chuck Lever (7):
>       SUNRPC: Support IPv6 when registering kernel RPC services
>       SUNRPC: Split portmap unregister API into separate function
>       SUNRPC: Simplify rpcb_register() API
>       SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
>       SUNRPC: Set V6ONLY socket option for RPC listener sockets
>       SUNRPC: Add address family field to svc_serv data structure
>       NFS: nfs_parsed_mount_options can use unsigned int
> 
> 
>  fs/Kconfig                  |   22 +++++
>  fs/lockd/svc.c              |    2 
>  fs/nfs/callback.c           |    3 -
>  fs/nfs/internal.h           |    8 +-
>  fs/nfsd/nfssvc.c            |    3 -
>  include/linux/sunrpc/clnt.h |    4 -
>  include/linux/sunrpc/svc.h  |   15 ++--
>  net/sunrpc/rpcb_clnt.c      |   65 +++++++---------
>  net/sunrpc/svc.c            |  175 ++++++++++++++++++++++++++++++++++++-------
>  net/sunrpc/svc_xprt.c       |   37 +++++++--
>  net/sunrpc/svcsock.c        |   13 +++
>  11 files changed, 260 insertions(+), 87 deletions(-)
> 
> -- 
> Chuck Lever
