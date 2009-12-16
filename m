From: " J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [RFC 05/11] nfsd: skip clients marked for renewal
Date: Wed, 16 Dec 2009 15:58:53 -0500
Message-ID: <20091216205853.GC28822@fieldses.org>
References: <4B291B4C.3060603@panasas.com> <1260985285-21517-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37742 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756365AbZLPU6r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2009 15:58:47 -0500
In-Reply-To: <1260985285-21517-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 16, 2009 at 07:41:25PM +0200, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 16ccab3..15f4b63 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2613,6 +2613,9 @@ nfs4_laundromat(void)
>  				clientid_val = t;
>  			break;
>  		}
> +		/* skip clients marked for renewal */
> +		if (atomic_read(&clp->cl_state) == CL_STATE_RENEW)
> +			continue;

I may just not understand your locking scheme.

But how are concurrent expiriry and renewal handled?  Couldn't the state
be marked CL_STATE_RENEW after this check but before CL_STATE_EXPIRED is
set in the following expire_client()?  What happens then?

--b.

>  		dprintk("NFSD: purging unused client (clientid %08x)\n",
>  			clp->cl_clientid.cl_id);
>  		nfsd4_remove_clid_dir(clp);
> -- 
> 1.6.5.1
> 
