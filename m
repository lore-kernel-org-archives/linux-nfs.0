Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:42556 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941359AbdDYUhP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Apr 2017 16:37:15 -0400
Subject: Re: [PATCH 1/1 linux-next] nfs: kmap can't fail
To: Fabian Frederick <fabf@skynet.be>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <20170425181033.1892-1-fabf@skynet.be>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <2158af9c-96c7-c124-38c6-3779fbaf373b@Netapp.com>
Date: Tue, 25 Apr 2017 16:37:08 -0400
MIME-Version: 1.0
In-Reply-To: <20170425181033.1892-1-fabf@skynet.be>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Fabian,

On 04/25/2017 02:10 PM, Fabian Frederick wrote:
> Remove NULL test on kmap()
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  fs/nfs/dir.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 3a188cb..f89e54c 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -179,8 +179,6 @@ struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
>  	if (page == NULL)
>  		return ERR_PTR(-EIO);
>  	ptr = kmap(page);
> -	if (ptr == NULL)
> -		return ERR_PTR(-ENOMEM);>  	return ptr;

While you're at it, can you remove the ptr variable entirely and change the code to "return kmap(page)" instead?

Thanks,
Anna

>  }
>  
> 
