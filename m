Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:46214 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473Ab3HVMzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Aug 2013 08:55:11 -0400
Message-ID: <52160A2C.7000804@netapp.com>
Date: Thu, 22 Aug 2013 08:55:08 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH 4/6] NFSv4: Deal with a sparse warning in nfs_idmap_get_key()
References: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com> <1377131186-40249-2-git-send-email-Trond.Myklebust@netapp.com> <1377131186-40249-3-git-send-email-Trond.Myklebust@netapp.com> <1377131186-40249-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131186-40249-4-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/21/2013 08:26 PM, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/idmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index c2c4163..65c7d91 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -310,7 +310,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
>  	if (ret < 0)
>  		goto out_up;
>  
> -	payload = rcu_dereference(rkey->payload.data);
> +	payload = rcu_dereference(rkey->payload.rcudata);

Loks good to me!

Acked-by: Bryan Schumaker <bjschuma@netapp.com>

>  	if (IS_ERR_OR_NULL(payload)) {
>  		ret = PTR_ERR(payload);
>  		goto out_up;
> 

