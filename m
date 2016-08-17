Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33329 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbcHQN2R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2016 09:28:17 -0400
Received: by mail-qk0-f177.google.com with SMTP id z190so67959884qkc.0
        for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2016 06:28:16 -0700 (PDT)
Message-ID: <1471440494.3196.21.camel@redhat.com>
Subject: Re: [RFC PATCH] nfsd: fix error handling for clients that fail to
 return the layout
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, hch@lst.de
Date: Wed, 17 Aug 2016 09:28:14 -0400
In-Reply-To: <20160816211745.GA795@fieldses.org>
References: <1471368867-29362-1-git-send-email-jlayton@redhat.com>
	 <20160816211745.GA795@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-08-16 at 17:17 -0400, J. Bruce Fields wrote:
> On Tue, Aug 16, 2016 at 01:34:27PM -0400, Jeff Layton wrote:
> > 
> > Currently, when the client fails to return the layout we'll
> > eventually
> > give up trying but leave the layout in place.
> 
> Maybe I'm not reading the code right, but I think the layout is
> eventually removed unconditionally in every case, by
> nfsd4_cb_layout_release--were you seeing something else?
> 

Yes, you're correct. Still, we'll be revoking the layout record in the
server, but the client could still think it has it and it could
continue writing to the storage. If we're revoking the layout without
the client explicitly acknowledging that it's no longer using it, then
we really do have to fence as well.

> > 
> > What we really need to
> > do here is fence the client in this case. Have it fall through to
> > that
> > code in that case instead of into the NFS4ERR_NOMATCHING_LAYOUT
> > case.
> 
> So the only change here is to fence in the case a client keeps
> responding with DELAY, right?
> 

That, or if it is returning 0 and not following up with a LAYOUTRETURN.

> That does seem like an improvement.
> 
> I wonder if the result is completely correct.
> 
> In the list_empty(&ls->ls_layouts) case, shouldn't we also call
> trace_layout_recall_done()?
> 
> Does it really make sense to retry the callback in the case the
> callback
> succeeds but the client hasn't returned yet?
> 

No it doesn't, but fixing that is a little more difficult. Right now,
we time out the recall in the ->done operation. If we don't retry the
call then we don't have a mechanism to handle the timeout.

There are several ways to fix that, but they're all pretty ugly,
AFAICT. Any thoughts on how you'd like to handle the timeout?

> If the client returns the layout but returns a status other than 0,
> DELAY, or NOMATCHING_LAYOUT, is it really correct to fence it?
> 

Probably not. Some of the error cases (e.g. NFS4ERR_BADHANDLE) could
probably be considered the same as NFS4ERR_NOMATCHING_LAYOUT. That
said, fencing is generally the safer option when we're in doubt.

> If trunking's in effect and we have to change the callback connection
> while waiting for the return, do we do the right thing?  (Looking at
> it... Actually, I think nfsd4_cb_sequence_done should handle these
> cases
> for us, OK, maybe I'm less worried.)
> 

Yeah, that should all be handled in the CB_SEQUENCE op.

> --b.
> 
> > 
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4layouts.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > Note that this patch is untested, other than for compilation as I
> > don't have a block/scsi pnfs setup on which to do so. Still, I
> > think
> > it makes more sense to fence clients that don't return the layout
> > instead of just giving up.
> > 
> > diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> > index 42aace4fc4c8..596205d939a1 100644
> > --- a/fs/nfsd/nfs4layouts.c
> > +++ b/fs/nfsd/nfs4layouts.c
> > @@ -686,10 +686,6 @@ nfsd4_cb_layout_done(struct nfsd4_callback
> > *cb, struct rpc_task *task)
> >  			return 0;
> >  		}
> >  		/* Fallthrough */
> > -	case -NFS4ERR_NOMATCHING_LAYOUT:
> > -		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
> > -		task->tk_status = 0;
> > -		return 1;
> >  	default:
> >  		/*
> >  		 * Unknown error or non-responding client, we'll
> > need to fence.
> > @@ -702,6 +698,10 @@ nfsd4_cb_layout_done(struct nfsd4_callback
> > *cb, struct rpc_task *task)
> >  		else
> >  			nfsd4_cb_layout_fail(ls);
> >  		return -1;
> > +	case -NFS4ERR_NOMATCHING_LAYOUT:
> > +		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
> > +		task->tk_status = 0;
> > +		return 1;
> >  	}
> >  }
> >  
> > -- 
> > 2.7.4

-- 
Jeff Layton <jlayton@redhat.com>
