From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/4] NFS: Add string length argument to
	nfs_parse_server_address
Date: Thu, 19 Jun 2008 13:43:43 -0400
Message-ID: <1213897423.7120.17.camel@localhost>
References: <20080618222951.16006.3679.stgit@ellison.1015granger.net>
	 <20080618223211.16006.8247.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45062 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183AbYFSRol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 13:44:41 -0400
In-Reply-To: <20080618223211.16006.8247.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-06-18 at 18:32 -0400, Chuck Lever wrote:
> To make nfs_parse_server_address() more generally useful, allow it to
> accept input strings that are not terminated with '\0'.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/super.c |  107 ++++++++++++++++++++++++++++++++++++++++----------------
>  1 files changed, 77 insertions(+), 30 deletions(-)
> 
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 98c8110..818bc1b 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -62,6 +62,13 @@
>  
>  #define NFSDBG_FACILITY		NFSDBG_VFS
>  
> +#ifndef INET_ADDRSTRLEN
> +#define INET_ADDRSTRLEN		(16)
> +#endif
> +#ifndef INET6_ADDRSTRLEN
> +#define INET6_ADDRSTRLEN	(48)
> +#endif
> +

If you're resending, then can you please get rid of the above #ifndefs?
If somebody else is defining an INET_ADDRSTRLEN that overrides ours,
then I definitely want to know about it at compile time, so that I can
check for correctness.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
