From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] {SQUASHME} layout_get_done errors are nfs_errors not
 Kernel
Date: Tue, 14 Jul 2009 20:41:01 +0300
Message-ID: <4A5CC32D.3070706@panasas.com>
References: <4A5CA5D7.4060505@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:8094
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752361AbZGNRlH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2009 13:41:07 -0400
In-Reply-To: <4A5CA5D7.4060505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 14, 2009, 18:35 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
> in layout_get_done rpc_status is of type enum nfsstat4
> "case" on the correct values.

Sorry, these need to be translated by nfs4_stat_to_errno.
We need to add the nfs41 error codes to nfs_errtbl.

By the way, Trond, what do you think of having
two error translation tables in fs/nfs/nfs4xdr.c?
One for the basic errors (up to and including NFS4ERR_STALE)
and one, adjusted by -10000 for NFS4ERR_BADHANDLE and up.
Then, we can use direct lookup using the nfserr (adjusted for
high values) rather than linear scan.

I'm not sure if optimizing the error path is worth doing...
what do you think?

Benny

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/pnfs.c |   21 +++++++++++----------
>  1 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index c1b0927..6218f78 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -974,24 +974,25 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
>  		dprintk("%s: ERROR retrieving layout %d\n",
>  			__func__, rpc_status);
>  
> -		switch (rpc_status) {
> -		case -ENOENT:   /* NFS4ERR_BADLAYOUT */
> +		switch (-rpc_status) {
> +		case NFS4ERR_BADLAYOUT:
>  			/* transient error, don't mark with
>  			 * NFS_INO_LAYOUT_FAILED */
>  			lgp->status = 1;
>  			break;
> -		case -EAGAIN:   /* NFS4ERR_LAYOUTTRYLATER,
> -				 * NFS4ERR_RECALLCONFLICT, NFS4ERR_LOCKED
> -				 */
> +		case NFS4ERR_LAYOUTTRYLATER:
> +		case NFS4ERR_RECALLCONFLICT:
> +		case NFS4ERR_LOCKED:
> +
>  			suspend = get_seconds() + 1;
>  			dprintk("%s: layout_get suspended until %ld\n",
>  				__func__, suspend);
>  			break;
> -		case -EINVAL:   /* NFS4ERR_INVAL, NFSERR_BADIOMODE,
> -				 * NFS4ERR_UNKNOWN_LAYOUTTYPE
> -				 */
> -		case -ENOTSUPP:	/* NFS4ERR_LAYOUTUNAVAILABLE */
> -		case -ETOOSMALL:/* NFS4ERR_TOOSMALL */
> +		case NFS4ERR_INVAL:
> +		case NFS4ERR_BADIOMODE:
> +		case NFS4ERR_UNKNOWN_LAYOUTTYPE:
> +		case NFS4ERR_LAYOUTUNAVAILABLE:
> +		case NFS4ERR_TOOSMALL:
>  		default:
>  			/* suspend layout get for ever for this file */
>  			dprintk("%s: no layout_get until %ld\n",
