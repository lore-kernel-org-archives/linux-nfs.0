From: " J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH v2 05/35] pnfsd: don't set up back channel on
	create_session for ds
Date: Mon, 7 Dec 2009 15:10:38 -0500
Message-ID: <20091207201038.GC32454@fieldses.org>
References: <4B1CCA52.8020900@panasas.com> <1260178251-14816-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org,
	Dean Hildebrand <seattleplus@gmail.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1260178251-14816-1-git-send-email-bhalevy@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2009 at 11:30:51AM +0200, Benny Halevy wrote:
> From: Dean Hildebrand <seattleplus@gmail.com>
> 
> [was pnfsd: Add use of pnfs exchange flags]
> Should this code be surrounded by CONFIG_PNFSD?

Might be nice, but I suppose it's not important.

> 
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9ecbc25..dc9d553 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1349,6 +1349,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		cr_ses->flags &= ~SESSION4_PERSIST;
>  		cr_ses->flags &= ~SESSION4_RDMA;
>  
> +		if (!(unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS) &&
> +		    (unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS))
> +			cr_ses->flags &= ~SESSION4_BACK_CHAN;
> +

Might be easier to read as:

	if (is_ds_only_session(unconf))
		cr_ses->flags &= ~SESSION4_BACK_CHAN;

with is_ds_only_session() defined in the obvious way.

--b.

>  		if (cr_ses->flags & SESSION4_BACK_CHAN) {
>  			unconf->cl_cb_xprt = rqstp->rq_xprt;
>  			svc_xprt_get(unconf->cl_cb_xprt);
> -- 
> 1.6.5.1
> 
