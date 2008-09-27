From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] Bake-a-thon fixes
Date: Fri, 26 Sep 2008 20:01:11 -0400
Message-ID: <20080927000111.GC9889@fieldses.org>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34949 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431AbYI0ABO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 20:01:14 -0400
In-Reply-To: <20080925154814.8353.64762.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2008 at 11:56:47AM -0400, Chuck Lever wrote:
> Hi Trond, Bruce-
> 
> I know it is late, but please consider these three bug fixes for 2.6.28.

Thanks, I've applied 1 and 2.

--b.

> 
> The first patch is another result of Olaf's recent exploration of the
> Linux rpcbind port.  It belongs with the other patches for 2.6.28 that
> provide proper support for IPv6 and rpcbind v4 when the kernel registers
> its RPC services with the local rpcbind daemon.
> 
> The second patch is a simple clean up that reduces the verbosity of
> rpcbind debugging messages.
> 
> The third is important for NFSv4 over IPv6.  Without it, the NFSv4.0
> callback channel does not work properly over IPv6.  There may be more
> problems there, so this does not yet guarantee that we have working
> callback support over IPv6.
> 
> ---
> 
> Chuck Lever (3):
>       NFS: SETCLIENTID truncates client ID and netid
>       SUNRPC: Clean up debug messages in rpcb_clnt.c
>       SUNRPC: Fix up svc_unregister()
> 
> 
>  include/linux/nfs_xdr.h |    8 +++---
>  net/sunrpc/rpcb_clnt.c  |   14 ++++-------
>  net/sunrpc/svc.c        |   58 +++++++++++++++++++++++++++++++----------------
>  3 files changed, 47 insertions(+), 33 deletions(-)
> 
> -- 
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
