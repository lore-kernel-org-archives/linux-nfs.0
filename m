Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53830 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754450Ab2ATSfe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 13:35:34 -0500
Date: Fri, 20 Jan 2012 13:35:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [patch] nfsd: remove some unneeded checks
Message-ID: <20120120183530.GA17212@fieldses.org>
References: <1321611289-21809-1-git-send-email-levinsasha928@gmail.com>
 <20120116115258.GC3294@mwanda>
 <20120116155031.GC1750@fieldses.org>
 <20120118095601.GE3356@mwanda>
 <20120118224107.GC27205@fieldses.org>
 <20120120074818.GA12039@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120120074818.GA12039@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 20, 2012 at 10:48:18AM +0300, Dan Carpenter wrote:
> We check for zero length strings in the caller now, so these aren't
> needed.

Thanks!  Applying.--b.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index cf8a6bd..8e9689a 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -87,7 +87,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
>  	struct svc_expkey key;
>  	struct svc_expkey *ek = NULL;
>  
> -	if (mlen < 1 || mesg[mlen-1] != '\n')
> +	if (mesg[mlen - 1] != '\n')
>  		return -EINVAL;
>  	mesg[mlen-1] = 0;
>  
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 01153ea..6ab3573 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -509,7 +509,7 @@ static int unix_gid_parse(struct cache_detail *cd,
>  	time_t expiry;
>  	struct unix_gid ug, *ugp;
>  
> -	if (mlen <= 0 || mesg[mlen-1] != '\n')
> +	if (mesg[mlen - 1] != '\n')
>  		return -EINVAL;
>  	mesg[mlen-1] = 0;
>  


