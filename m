From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [patch] nfs: testing the wrong variable
Date: Thu, 28 Oct 2010 14:18:01 -0400
Message-ID: <1288289881.14221.14.camel@heimdal.trondhjem.org>
References: <20101028060557.GY6062@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24940 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760903Ab0J1SS4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 14:18:56 -0400
In-Reply-To: <20101028060557.GY6062@bicker>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-10-28 at 08:05 +0200, Dan Carpenter wrote:
> The intent was to test "*desc" for allocation failures, but it tests
> "desc" which is always a valid pointer here.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index dec47ed..4e2d9b6 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -123,7 +123,7 @@ static ssize_t nfs_idmap_get_desc(const char *name, size_t namelen,
>  	size_t desclen = typelen + namelen + 2;
>  
>  	*desc = kmalloc(desclen, GFP_KERNEL);
> -	if (!desc)
> +	if (!*desc)
>  		return -ENOMEM;
>  
>  	cp = *desc;

Thanks! Applied!

Trond
