From: " J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/3] SQUASHME: pnfsd: always set both MDS and DS
	exchangeid capability flags
Date: Wed, 9 Dec 2009 13:54:03 -0500
Message-ID: <20091209185403.GB23234@fieldses.org>
References: <4B1F7AF6.2080305@panasas.com> <1260354440-12073-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1260354440-12073-1-git-send-email-bhalevy@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 09, 2009 at 12:27:20PM +0200, Benny Halevy wrote:
> We always support both modes when CONFIG_PNFSD is enabled.
> The client needs to remember what the session is used for
> if it cares to distiguish between DSs and MDSs.

OK, thanks.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |   15 ++-------------
>  1 files changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 108cb3e..aa2e9c2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1103,20 +1103,9 @@ static void
>  nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
>  {
>  #if defined(CONFIG_PNFSD)
> -	int mds_and_ds = EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS;
> -	int mds_or_ds = 0;
> -
> -	/* Save the client's MDS or DS flags, or set them both.
> -	 * XXX We currently do not have a method of determining
> -	 * what a server supports prior to receiving a filehandle
> -	 * e.g. at exchange id time. */
> -	mds_or_ds = clid->flags & mds_and_ds;
> -	if (mds_or_ds)
> -		new->cl_exchange_flags |= mds_or_ds;
> -	else
> -		new->cl_exchange_flags |= mds_and_ds;
> +	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_PNFS_MDS |
> +				  EXCHGID4_FLAG_USE_PNFS_DS;
>  #else  /* CONFIG_PNFSD */
> -	/* pNFS is not supported */
>  	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
>  #endif /* CONFIG_PNFSD */

As usual, let's also hide the ifdef's e.g.:

	new->cl_exchange_flags |= PNFS_EXCHGID_FLAGS

with the define conditional on CONFIG_PNFSD.

--b.
