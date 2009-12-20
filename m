From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: Problem with 2.6.33-rc1 and insecure flag
Date: Sun, 20 Dec 2009 10:46:24 -0500
Message-ID: <20091220154624.GC2841@fieldses.org>
References: <20091220094625.GA2159@trillian.comsick.at> <7A24DF798E223B4C9864E8F92E8C93EC04EBFD3F@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51898 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080AbZLTPqP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Dec 2009 10:46:15 -0500
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC04EBFD3F-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 20, 2009 at 02:13:07AM -0800, Muntz, Daniel wrote:
> If one were to hit this bug with v4.x, would the error be something like
> this in the RPC layer:
> 
>    Reply State: denied (1)
>    Reject State: AUTH_ERROR (1)
>    Auth State: bad credential (seal broken) (1) 

Since we let the "insecure" flag vary by filesystem, we don't catch this
until we decode filehandles, so return an nfs-level error.

--b.

> 
>   -Dan
> 
> > -----Original Message-----
> > From: Michael Guntsche [mailto:mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org] 
> > Sent: Sunday, December 20, 2009 1:46 AM
> > To: bfields@citi.umich.edu
> > Cc: linux-nfs
> > Subject: Re: Problem with 2.6.33-rc1 and insecure flag
> > 
> > I think I figured out the problem. 
> > 
> > Apparently the code checked if insecure was set, while it 
> > should check if it was NOT set.
> > 
> > Kind regards,
> > Michael
> > 
> > diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> > index 1c12177..55c8e63 100644
> > --- a/fs/nfsd/nfsfh.c
> > +++ b/fs/nfsd/nfsfh.c
> > @@ -89,7 +89,7 @@ static __be32 
> > nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
> >         int flags = nfsexp_flags(rqstp, exp);
> >  
> >         /* Check if the request originated from a secure port. */
> > -       if (!rqstp->rq_secure && (flags & NFSEXP_INSECURE_PORT)) {
> > +       if (!rqstp->rq_secure && !(flags & NFSEXP_INSECURE_PORT)) {
> >                 RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> >                 dprintk(KERN_WARNING
> >                        "nfsd: request from insecure port %s!\n",
> > 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe 
> > linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
