From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 14/29] knfsd: better hashing in the reply cache
Date: Fri, 8 May 2009 18:01:44 -0400
Message-ID: <20090508220144.GD22377@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202942.848645000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44103 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbZEHWBp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 18:01:45 -0400
In-Reply-To: <20090331202942.848645000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 07:28:14AM +1100, Greg Banks wrote:
> Improve the hash function to handle clients which increment the XID
> in the unexpected byte order, by folding down the top bits of the XID.

I'm confused; maybe my arithemtic's wrong, but:

> 
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---
> 
>  fs/nfsd/nfscache.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> Index: bfields/fs/nfsd/nfscache.c
> ===================================================================
> --- bfields.orig/fs/nfsd/nfscache.c
> +++ bfields/fs/nfsd/nfscache.c
> @@ -35,12 +35,15 @@ static struct list_head 	lru_head;
>  static int			cache_disabled = 1;
>  
>  /*
> - * Calculate the hash index from an XID.
> + * Calculate the hash index from an XID.  Note, some clients increment
> + * their XIDs in host order, which can result in all the variation being
> + * in the top bits we see here.  So we fold those bits down.
>   */
>  static inline u32 request_hash(u32 xid)
>  {
>  	u32 h = xid;
>  	h ^= (xid >> 24);

This xor's the highest 8 bits into the lowest 8 bits; so the
higest-order bits are already being "folded down".

> +	h ^= ((xid & 0xff0000) >> 8);

This just folds those same bits down into the order 16-23 bits.  Does
that help?

>  	return h & (HASHSIZE-1);

Especially when we're only taking the bottom few (6, currently) bits
anyway?

--b.

>  }
>  
> 
> --
> Greg
