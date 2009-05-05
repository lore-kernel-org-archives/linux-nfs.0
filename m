From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [RFC 04/10] nfsd41: Remember the auth flavor to use forcallbacks
Date: Mon, 4 May 2009 19:51:03 -0700
Message-ID: <273FE88A07F5D445824060902F70034405917618@SACMVEXC1-PRD.hq.netapp.com>
References: <20090503204236.GB22306@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <pnfs@linux-nfs.org>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55084 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676AbZEECwI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2009 22:52:08 -0400
In-Reply-To: <20090503204236.GB22306@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Sunday, May 03, 2009 1:43 PM
> To: Benny Halevy
> Cc: Labiaga, Ricardo; pnfs@linux-nfs.org; linux-nfs@vger.kernel.org
> Subject: Re: [RFC 04/10] nfsd41: Remember the auth flavor to use
> forcallbacks
> 
> On Fri, May 01, 2009 at 02:06:01AM +0300, Benny Halevy wrote:
> > From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> >
> > The callbacks will be sent using the same authentication flavor that
> > was used during session creation.  We'll add code to remember the
> > principal in the case RPCSEC_GSS in a separate patch.
> >
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> >  fs/nfsd/nfs4state.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index cc9705b..ad30039 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1284,6 +1284,7 @@ out_new:
> >  	copy_verf(new, &verf);
> >  	copy_cred(&new->cl_cred, &rqstp->rq_cred);
> >  	new->cl_addr = ip_addr;
> > +	new->cl_flavor = rqstp->rq_flavor;
> >  	gen_clid(new);
> >  	gen_confirm(new);
> >  	add_to_unconfirmed(new, strhashval);
> 
> Most of the code here is duplicated between the 4.1 and 4.0 cases, and
> this is just adding a line that was already there in the 4.0 case.
(The
> same will be true for rembering the princpal in the RPCSEC_GSS case.)
> Could we move the rest of this initialization into create_client
(giving
> it some more arguments if necessary), and eliminate some code
> duplication?

Sounds good.  I'll take care of that.

- ricardo

> --b.
> 
> > --
> > 1.6.2.1
> >
