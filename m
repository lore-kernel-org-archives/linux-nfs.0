Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58040 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344AbcHPVRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2016 17:17:47 -0400
Date: Tue, 16 Aug 2016 17:17:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, hch@lst.de
Subject: Re: [RFC PATCH] nfsd: fix error handling for clients that fail to
 return the layout
Message-ID: <20160816211745.GA795@fieldses.org>
References: <1471368867-29362-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1471368867-29362-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 16, 2016 at 01:34:27PM -0400, Jeff Layton wrote:
> Currently, when the client fails to return the layout we'll eventually
> give up trying but leave the layout in place.

Maybe I'm not reading the code right, but I think the layout is
eventually removed unconditionally in every case, by
nfsd4_cb_layout_release--were you seeing something else?

> What we really need to
> do here is fence the client in this case. Have it fall through to that
> code in that case instead of into the NFS4ERR_NOMATCHING_LAYOUT case.

So the only change here is to fence in the case a client keeps
responding with DELAY, right?

That does seem like an improvement.

I wonder if the result is completely correct.

In the list_empty(&ls->ls_layouts) case, shouldn't we also call
trace_layout_recall_done()?

Does it really make sense to retry the callback in the case the callback
succeeds but the client hasn't returned yet?

If the client returns the layout but returns a status other than 0,
DELAY, or NOMATCHING_LAYOUT, is it really correct to fence it?

If trunking's in effect and we have to change the callback connection
while waiting for the return, do we do the right thing?  (Looking at
it... Actually, I think nfsd4_cb_sequence_done should handle these cases
for us, OK, maybe I'm less worried.)

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4layouts.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> Note that this patch is untested, other than for compilation as I
> don't have a block/scsi pnfs setup on which to do so. Still, I think
> it makes more sense to fence clients that don't return the layout
> instead of just giving up.
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 42aace4fc4c8..596205d939a1 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -686,10 +686,6 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
>  			return 0;
>  		}
>  		/* Fallthrough */
> -	case -NFS4ERR_NOMATCHING_LAYOUT:
> -		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
> -		task->tk_status = 0;
> -		return 1;
>  	default:
>  		/*
>  		 * Unknown error or non-responding client, we'll need to fence.
> @@ -702,6 +698,10 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
>  		else
>  			nfsd4_cb_layout_fail(ls);
>  		return -1;
> +	case -NFS4ERR_NOMATCHING_LAYOUT:
> +		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
> +		task->tk_status = 0;
> +		return 1;
>  	}
>  }
>  
> -- 
> 2.7.4
