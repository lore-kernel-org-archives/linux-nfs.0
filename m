From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/5] Repost of remaining server-side IPv6 patches
Date: Tue, 26 Jan 2010 18:30:38 -0500
Message-ID: <20100126233038.GC806@fieldses.org>
References: <20100126190214.3368.89388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56932 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747Ab0AZX3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 18:29:04 -0500
In-Reply-To: <20100126190214.3368.89388.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 26, 2010 at 02:03:38PM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> Repost of last week's IPv6 patch set.  I've attempted to address your
> comments.

Thanks!  First four applied.  Fifth looks fine too, but see comment on
that mail.

--b.

> 
> ---
> 
> Aime Le Rouzic (1):
>       NFSD: Support AF_INET6 in svc_addsock() function
> 
> Chuck Lever (4):
>       NFSD: Create PF_INET6 listener in write_ports
>       SUNRPC: NFS kernel APIs shouldn't return ENOENT for "transport not found"
>       SUNRPC: Bury "#ifdef IPV6" in svc_create_xprt()
>       SUNRPC: Use rpc_pton() in ip_map_parse()
> 
> 
>  fs/lockd/svc.c            |    2 --
>  fs/nfs/callback.c         |    2 --
>  fs/nfsd/nfsctl.c          |   24 ++++++++++++++++++-----
>  net/sunrpc/svc_xprt.c     |    9 ++++++++-
>  net/sunrpc/svcauth_unix.c |   47 +++++++++++++++++++++++++--------------------
>  net/sunrpc/svcsock.c      |    2 +-
>  6 files changed, 54 insertions(+), 32 deletions(-)
> 
> -- 
> Chuck Lever <chuck.lever@oracle.com>
