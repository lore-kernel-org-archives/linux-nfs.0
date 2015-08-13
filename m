Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33582 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbbHMS0i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Aug 2015 14:26:38 -0400
Received: by ykaz130 with SMTP id z130so48862340yka.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2015 11:26:38 -0700 (PDT)
Date: Thu, 13 Aug 2015 14:26:35 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4.1/pNFS: Fix borken function
 _same_data_server_addrs_locked()
Message-ID: <20150813142635.4368011b@tlielax.poochiereds.net>
In-Reply-To: <1439480749-54600-1-git-send-email-trond.myklebust@primarydata.com>
References: <1439480749-54600-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 13 Aug 2015 11:45:49 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> - Switch back to using list_for_each_entry(). To fix an incorrect test
>   for list NULL termination.
> - Do not assume that lists are sorted.
> - Finally, consider an existing entry to match if it consists of a subset
>   of the addresses in the new entry.
> 
> Cc: stable@vger.kernel.org # 4.0+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/pnfs_nfs.c | 33 +++++++++++++++++++--------------
>  1 file changed, 19 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index cd3c0403101b..bbd407b6bc1f 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -373,26 +373,31 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
>  	return false;
>  }
>  
> +/*
> + * Checks if 'dsaddrs1' contains a subset of 'dsaddrs2'. If it does,
> + * declare a match.
> + */
>  static bool
>  _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
>  			       const struct list_head *dsaddrs2)
>  {
>  	struct nfs4_pnfs_ds_addr *da1, *da2;
> -
> -	/* step through both lists, comparing as we go */
> -	for (da1 = list_first_entry(dsaddrs1, typeof(*da1), da_node),
> -	     da2 = list_first_entry(dsaddrs2, typeof(*da2), da_node);
> -	     da1 != NULL && da2 != NULL;
> -	     da1 = list_entry(da1->da_node.next, typeof(*da1), da_node),
> -	     da2 = list_entry(da2->da_node.next, typeof(*da2), da_node)) {
> -		if (!same_sockaddr((struct sockaddr *)&da1->da_addr,
> -				   (struct sockaddr *)&da2->da_addr))
> -			return false;
> +	struct sockaddr *sa1, *sa2;
> +	bool match = false;
> +
> +	list_for_each_entry(da1, dsaddrs1, da_node) {
> +		sa1 = (struct sockaddr *)&da1->da_addr;
> +		match = false;
> +		list_for_each_entry(da2, dsaddrs2, da_node) {
> +			sa2 = (struct sockaddr *)&da2->da_addr;
> +			match = same_sockaddr(sa1, sa2);
> +			if (match)
> +				break;

Sure would be nice to consolidate some of these "same_sockaddr"
functions at some point. We also have nfs_sockaddr_cmp which does the
exact same thing, and probably some similar ones in the RPC layer.

> +		}
> +		if (!match)
> +			break;
>  	}
> -	if (da1 == NULL && da2 == NULL)
> -		return true;
> -
> -	return false;
> +	return match;
>  }
>  
>  /*

Nice catch:

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
