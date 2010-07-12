From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs41: Do not free slot if retried while operation was
 in progress
Date: Mon, 12 Jul 2010 15:59:35 -0400
Message-ID: <1278964775.12559.17.camel@heimdal.trondhjem.org>
References: <20100712182927.GB22461@merit.edu>
	 <4C3B65E4.4070704@panasas.com>
	 <1278962046.12559.3.camel@heimdal.trondhjem.org>
	 <4C3B6A1D.40202@panasas.com>
	 <1278962763.12559.10.camel@heimdal.trondhjem.org>
	 <4C3B71B3.3050009@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jim Rees <rees@umich.edu>, NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54873 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab0GLUAL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 16:00:11 -0400
In-Reply-To: <4C3B71B3.3050009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-07-12 at 22:49 +0300, Benny Halevy wrote:
> On Jul. 12, 2010, 22:26 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > On Mon, 2010-07-12 at 22:16 +0300, Benny Halevy wrote:
> >> On Jul. 12, 2010, 22:14 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> >>> On Mon, 2010-07-12 at 21:58 +0300, Benny Halevy wrote:
> >>>> [pnfs@linux-nfs.org -> linux-nfs@vger.kernel.org]
> >>>>
> >>>> On Jul. 12, 2010, 21:29 +0300, Jim Rees <rees@umich.edu> wrote:
> >>>>> Does anyone still care about this?
> >>>>>
> >>>>>  WARNING: nfs41_sequence_done: Operation in progress slot=1 seq=7 highest_used_slotid=1: please report to pnfs@linux-nfs.org if you saw this message
> >>>>
> >>>> Heh, need to update hard-coded instructions to point to the new list...
> >>>>
> >>>>>
> >>>>> I'm getting this on the client side of a pnfs block layout mount against the
> >>>>> spnfs server.  Kernel is benny's pnfs-all-2.6.35-rc3-2010-07-01 plus EMC
> >>>>> complex block layout patches.  It's possible the complex layout code is to
> >>>>> blame, but I doubt it because this isn't a complex layout mount.  I can
> >>>>> provide more details.
> >>>>
> >>>> I agree.  This is a generic issue.
> >>>> The patch that  adds this check is
> >>>> d6ce9ad DEVONLY: nfs41: Do not free slot if retried while operation was in progress
> >>>>
> >>>> It was originally rejected (http://www.spinics.net/lists/linux-nfs/msg09562.html)
> >>>> due to noise regarding where nfs41_sequence_free_slot is called
> >>>> but that masked the real issue.
> >>>>
> >>>> Can you readily reproduce this?
> >>>> Can you debug also the server side to see if indeed the client retries the RPC
> >>>> while it is in progress on the server?
> >>>
> >>> So what is the root cause here? Is it the known issue that we don't deal
> >>> correctly with an NFS4ERR_DELAY on the SEQUENCE operation?
> >>
> >> Yes.
> > 
> > I'm happy to take patches to fix that.
> > 
> > Trond
> 
> >From 7dc3c468463a337dabff7f714a3475e3f51380f6 Mon Sep 17 00:00:00 2001
> From: Benny Halevy <bhalevy@panasas.com>
> Date: Mon, 12 Jul 2010 22:42:15 +0300
> Subject: [PATCH] nfs41: Do not free slot if retried while operation was in progress
> 
> Getting NFS4ERR_DELAY on OP_SEQUENCE means that the compound was retried
> while it's still in progress on the server.  Therefore its respective
> slot must not be freed and reused for other compounds until it either
> succeeds or fails with another error status.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> 
> That fixed, do we ensure that the client either closes or loses the connection
> before retrying?
> 
>  fs/nfs/nfs4proc.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 70015dd..baf86b9 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -425,6 +425,12 @@ static void nfs41_sequence_done(struct nfs_client *clp,
>  		/* Check sequence flags */
>  		if (atomic_read(&clp->cl_count) > 1)
>  			nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
> +	} else if (unlikely(res->sr_status == -NFS4ERR_DELAY)) {
> +		/* Do not free slot if retried while operation was in progress */
> +		tbl = &res->sr_session->fc_slot_table;
> +		dprintk("%s: slot=%d seq=%d: Operation in progress\n", __func__,
> +			res->sr_slotid, tbl->slots[res->sr_slotid].seq_nr);
> +		return;
>  	}
>  out:
>  	/* The session may be reset by one of the error handlers. */

No. That is very clearly insufficient...


Never mind. I'll do it...
