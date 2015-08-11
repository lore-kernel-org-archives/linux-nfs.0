Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:47278 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309AbbHKRcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Aug 2015 13:32:23 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] nfs: allow nfs4_label_free to ignore a PTR_ERR value
To: Jeff Layton <jlayton@poochiereds.net>, <trond.myklebust@primarydata.com>
References: <1439313239-30593-1-git-send-email-jeff.layton@primarydata.com>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>
Message-ID: <55CA3195.4000601@Netapp.com>
Date: Tue, 11 Aug 2015 13:32:05 -0400
MIME-Version: 1.0
In-Reply-To: <1439313239-30593-1-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,


On 08/11/2015 01:13 PM, Jeff Layton wrote:
> nfs4_label_alloc is a little odd in that a NULL return means "label is
> not needed" and a PTR_ERR return means an actual error. In at least one
> place however (nfs_lookup_revalidate) we can end up passing an error
> value to nfs4_label_free, which will likely lead to an oops.
> 
> We could fix that one caller, but I think just allowing the free to
> accept and ignore PTR_ERR values is probably appropriate given how the
> allocation works.

This makes sense, but I wonder if there are other functions that may-or-may-not allocate a structure without it being considered an error?  Does nfs4_label_alloc() match what other functions do?

Thanks,
Anna

> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfs/internal.h | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 9b372b845f6a..44bc298f6216 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -312,13 +312,13 @@ nfs4_label_copy(struct nfs4_label *dst, struct nfs4_label *src)
>  
>  	return dst;
>  }
> +
>  static inline void nfs4_label_free(struct nfs4_label *label)
>  {
> -	if (label) {
> -		kfree(label->label);
> -		kfree(label);
> -	}
> -	return;
> +	if (IS_ERR_OR_NULL(label))
> +		return;
> +	kfree(label->label);
> +	kfree(label);
>  }
>  
>  static inline void nfs_zap_label_cache_locked(struct nfs_inode *nfsi)
> 

