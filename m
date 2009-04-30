From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 08/31] nfsd41: sanity check client drc maxreqs
Date: Thu, 30 Apr 2009 14:43:52 -0400
Message-ID: <1241117032.15476.43.camel@heimdal.trondhjem.org>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
	 <1240938005-23778-2-git-send-email-andros@netapp.com>
	 <1240938005-23778-3-git-send-email-andros@netapp.com>
	 <1240938005-23778-4-git-send-email-andros@netapp.com>
	 <1240938005-23778-5-git-send-email-andros@netapp.com>
	 <1240938005-23778-6-git-send-email-andros@netapp.com>
	 <1240938005-23778-7-git-send-email-andros@netapp.com>
	 <1240938005-23778-8-git-send-email-andros@netapp.com>
	 <49F9E10A.60801@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andros@netapp.com, bfields@fieldses.org, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50154 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541AbZD3SoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2009 14:44:04 -0400
In-Reply-To: <49F9E10A.60801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-04-30 at 20:34 +0300, Benny Halevy wrote:
> On Apr. 28, 2009, 19:59 +0300, andros@netapp.com wrote:
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Ensure the client requested maximum requests are between 1 and
> > NFSD_MAX_SLOTS_PER_SESSION
> > 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  fs/nfsd/nfs4state.c |    5 +++++
> >  1 files changed, 5 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index e216169..59b601b 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -427,6 +427,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
> >  {
> >  	int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
> >  
> > +	if (fchan->maxreqs < 1)
> > +		return nfserr_inval;
> 
> Is 0 prohibited by the protocol?
> The server can set it to whatever value it wants,
> or if we can live with it, it actually provides a
> nice way to test the server end-cases.
> 
> Benny

The draft spec doesn't appear to explicitly exclude the value 0 for
ca_maxrequests.

I suppose a client might be able to request a session with a back
channel, but no fore channel if it wants to. The problem is that it
wouldn't be able to send SEQUENCE or BACKCHANNEL_CTL requests, and so
managing that back channel would be tough. There would be no way for the
server to tell the client of a back channel fault, or of the GSS context
expiring, and no way for the client to change that context.

In practice, therefore, it probably isn't a bad idea to return
NFS4ERR_INVAL...

Cheers
  Trond

