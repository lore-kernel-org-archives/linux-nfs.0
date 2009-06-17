From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 09/44] nfsd41: sanity check client drc maxreqs
Date: Tue, 16 Jun 2009 20:44:43 -0400
Message-ID: <20090617004443.GB8980@fieldses.org>
References: <1245115178-7097-1-git-send-email-bhalevy@panasas.com> <20090617003538.GA8980@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	andros@citi.umich.edu
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52833 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756731AbZFQAol (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 20:44:41 -0400
In-Reply-To: <20090617003538.GA8980@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 08:35:38PM -0400, bfields wrote:
> On Tue, Jun 16, 2009 at 04:19:38AM +0300, Benny Halevy wrote:
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Ensure the client requested maximum requests are between 1 and
> > NFSD_MAX_SLOTS_PER_SESSION
> > 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> >  fs/nfsd/nfs4state.c |    5 +++++
> >  1 files changed, 5 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 582cd2c..90e6645 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -425,6 +425,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
> >  {
> >  	int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
> >  
> > +	if (fchan->maxreqs < 1)
> > +		return nfserr_inval;
> > +	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
> > +		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
> > +
> >  	spin_lock(&nfsd_serv->sv_lock);
> 
> How did this use of sv_lock creep in?  Let's remove that before we do
> anything else....

(But--applied.)

--b.

> 
> --b.
> 
> >  	if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
> >  		np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
> > -- 
> > 1.6.3
> > 
