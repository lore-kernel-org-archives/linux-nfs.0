Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50076 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751699AbeCWSuN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Mar 2018 14:50:13 -0400
Date: Fri, 23 Mar 2018 14:50:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [PATCH] nfsd: tidy return values in nfs4_delegation_exists()
Message-ID: <20180323185013.GT4288@fieldses.org>
References: <20180323113705.GB28518@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180323113705.GB28518@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 23, 2018 at 02:37:05PM +0300, Dan Carpenter wrote:
> We made nfs4_delegation_exists() return a bool in 68b18f52947b ("nfsd:
> make nfs4_get_existing_delegation less confusing"), but it's still
> returning -EINVAL.  That's fine, because it -EINVAL becomes true which
> is what we want, but it's not very tidy.

Oops, I fixed this a couple days ago when Fengguang Wu complained about
the 0/false thing, but forgot to push it out.  Added a Reported-by: for
you and pushed it out now to

	git://linux-nfs.org/~bfields/linux.git nfsd-next

--b.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a64ee08aadb2..f0b5af3ca8f7 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -935,10 +935,10 @@ nfs4_delegation_exists(struct nfs4_client *clp, struct nfs4_file *fp)
>  	list_for_each_entry(searchdp, &fp->fi_delegations, dl_perfile) {
>  		searchclp = searchdp->dl_stid.sc_client;
>  		if (clp == searchclp) {
> -			return -EAGAIN;
> +			return true;
>  		}
>  	}
> -	return 0;
> +	return false;
>  }
>  
>  /**
