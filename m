From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: Avoid overrun when copying client IP address
 string
Date: Sun, 04 Oct 2009 18:33:16 -0400
Message-ID: <1254695596.30515.75.camel@heimdal.trondhjem.org>
References: <1254662749.2395.68.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, 549002@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48778 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528AbZJDWdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Oct 2009 18:33:55 -0400
In-Reply-To: <1254662749.2395.68.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-10-04 at 14:25 +0100, Ben Hutchings wrote:
> As seen in <http://bugs.debian.org/549002>, nfs4_init_client() can
> overrun the source string when copying the client IP address from
> nfs_parsed_mount_data::client_address to nfs_client::cl_ipaddr.  Since
> these are both treated as null-terminated strings elsewhere, the copy
> should be done with strlcpy() not memcpy().
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 75c9cd2..f525a2f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1073,7 +1073,7 @@ static int nfs4_init_client(struct nfs_client *clp,
>  				      1, flags & NFS_MOUNT_NORESVPORT);
>  	if (error < 0)
>  		goto error;
> -	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
> +	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
>  
>  	error = nfs_idmap_new(clp);
>  	if (error < 0) {

It looks good, so I'll push it upstream. I assume the bug report also
applies to stable@kernel.org?

Thanks!

  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
