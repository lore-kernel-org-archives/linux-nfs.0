Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62907 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564Ab1JKCbM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Oct 2011 22:31:12 -0400
Received: by ywb5 with SMTP id 5so6037047ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Oct 2011 19:31:11 -0700 (PDT)
Message-ID: <4E8F2FB7.40803@tonian.com>
Date: Fri, 07 Oct 2011 12:58:31 -0400
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 13/19] pnfs-obj: Remove redundant EOF from objlayout_io_state
References: <4E8ADEDA.4050709@panasas.com> <1317724499-27702-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <1317724499-27702-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-04 06:34, Boaz Harrosh wrote:
> The EOF calculation was done on .read_pagelist(), cached
> in objlayout_io_state->eof, and set in objlayout_read_done()
> into nfs_read_data->res.eof.
> 
> So set it directly into nfs_read_data->res.eof and avoid
> the extra member.
> 
> This is a slight behaviour change because before eof was
> *not* set on an error update at objlayout_read_done(). But
> is that a problem? Is Generic layer so sensitive that it
> will miss the error IO if eof was set? From my testing
> I did not see such a problem.
> 
> Benny please review.
> 
> Which brings me to a more abstract problem. Why does the
> LAYOUT driver needs to do this eof calculation? .i.e we
> are inspecting generic i_size_read() and if spanned by
> offset + count which is received from generic layer we set
> eof. It looks like all this can/should be done in generic
> layer and not at LD. Where does NFS and files-LD do it?
> It looks like it can be promoted.

In the files layout case, nfs_read_done sets res.eof.
But I agree this code could be moved to the generic layout
at least to serve non-rpc LDs.

And BTW, current the object layout handling of the eof flag
is stricter than the blocks layout and it requires an extra
call with offset >= i_size to set the eof flag, while for
nfs and blocks eof is set when offset + count >= i_size

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Reviewed-by: Benny Halevy <bhalevy@tonian.com>

> ---
>  fs/nfs/objlayout/objlayout.c |   16 +++++++---------
>  fs/nfs/objlayout/objlayout.h |    1 -
>  2 files changed, 7 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 1d06f8e..1300736 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -287,17 +287,14 @@ static void _rpc_read_complete(struct work_struct *work)
>  void
>  objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
>  {
> -	int eof = state->eof;
> -	struct nfs_read_data *rdata;
> +	struct nfs_read_data *rdata = state->rpcdata;
>  
>  	state->status = status;
> -	dprintk("%s: Begin status=%zd eof=%d\n", __func__, status, eof);
> -	rdata = state->rpcdata;
> +	dprintk("%s: Begin status=%zd eof=%d\n", __func__,
> +		status, rdata->res.eof);
>  	rdata->task.tk_status = status;
> -	if (status >= 0) {
> +	if (status >= 0)
>  		rdata->res.count = status;
> -		rdata->res.eof = eof;
> -	}
>  	objlayout_iodone(state);
>  	/* must not use state after this point */
>  
> @@ -330,11 +327,14 @@ objlayout_read_pagelist(struct nfs_read_data *rdata)
>  			status = 0;
>  			rdata->res.count = 0;
>  			rdata->res.eof = 1;
> +			/*FIXME: do we need to call pnfs_ld_read_done() */

Yes, it looks like we do, otherwise we might leak a refcount on the lseg.
We also need to set rdata->task.tk_status = 0, to mimic what objlayout_read_done
would have done in the sync case.

Benny

>  			goto out;
>  		}
>  		count = eof - offset;
>  	}
>  
> +	rdata->res.eof = (offset + count) >= eof;
> +
>  	state = objlayout_alloc_io_state(NFS_I(rdata->inode)->layout,
>  					 rdata->args.pages, rdata->args.pgbase,
>  					 offset, count,
> @@ -345,8 +345,6 @@ objlayout_read_pagelist(struct nfs_read_data *rdata)
>  		goto out;
>  	}
>  
> -	state->eof = state->offset + state->count >= eof;
> -
>  	status = objio_read_pagelist(state);
>   out:
>  	dprintk("%s: Return status %Zd\n", __func__, status);
> diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
> index a8244c8..ffb884c 100644
> --- a/fs/nfs/objlayout/objlayout.h
> +++ b/fs/nfs/objlayout/objlayout.h
> @@ -86,7 +86,6 @@ struct objlayout_io_state {
>  
>  	void *rpcdata;
>  	int status;             /* res */
> -	int eof;                /* res */
>  	int committed;          /* res */
>  
>  	/* Error reporting (layout_return) */
