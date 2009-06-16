From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/44] nfsd41: create_session check replay first
Date: Tue, 16 Jun 2009 17:16:33 -0400
Message-ID: <20090616211633.GF3045@fieldses.org>
References: <1245115172-7030-1-git-send-email-bhalevy@panasas.com> <20090616204734.GE3045@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org, andros@netapp.com
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42938 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762121AbZFPVQb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 17:16:31 -0400
In-Reply-To: <20090616204734.GE3045@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:47:34PM -0400, bfields wrote:
> On Tue, Jun 16, 2009 at 04:19:32AM +0300, Benny Halevy wrote:
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Replay processing needs to preceed other error processing.
> 
> Why?

Note: there's a slight leak of information here, which I don't think is
really important, but still by default would rather avoid: if a replay
is sent by someone other than the sender of the original create_session,
then sending back the cached result means they get to see a
create_session result that otherwise would have required them to sniff
the network (or decrypt a packet sent with the original user's creds, if
krb5p was in effect).

I doubt that's a big deal: I don't see anything that looks
security-critical in the create_session results.  But absent any real
reason to do otherwise, I'd rather check the creds before checking for
replay.

(Note: this is more critical in the case of the sessions DRC: e.g. if
the cached result includes read data, then we could end up exposing
filesystem data to someone who wouldn't otherwise be able to see it.)

--b.

> 
> --b.
> 
> > 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> >  fs/nfsd/nfs4state.c |   12 ++++++------
> >  1 files changed, 6 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index bfc808b..5aef525 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1378,12 +1378,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >  		}
> >  		conf->cl_slot.sl_seqid++;
> >  	} else if (unconf) {
> > -		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> > -		    (ip_addr != unconf->cl_addr)) {
> > -			status = nfserr_clid_inuse;
> > -			goto out_cache;
> > -		}
> > -
> >  		slot = &unconf->cl_slot;
> >  		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
> >  		if (status) {
> > @@ -1392,6 +1386,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >  			goto out;
> >  		}
> >  
> > +		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> > +		    (ip_addr != unconf->cl_addr)) {
> > +			status = nfserr_clid_inuse;
> > +			goto out_cache;
> > +		}
> > +
> >  		slot->sl_seqid++; /* from 0 to 1 */
> >  		move_to_confirmed(unconf);
> >  
> > -- 
> > 1.6.3
> > 
