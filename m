From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs4: allow server to change forechannel max_ops
Date: Tue, 25 May 2010 14:32:23 -0400
Message-ID: <20100525183223.GA6929@fieldses.org>
References: <20100525164224.GC4235@fieldses.org> <1274806624.11283.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48742 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933013Ab0EYSc0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 14:32:26 -0400
In-Reply-To: <1274806624.11283.10.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 25, 2010 at 12:57:04PM -0400, Trond Myklebust wrote:
> On Tue, 2010-05-25 at 12:42 -0400, J. Bruce Fields wrote: 
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > Section 18.36.3 of rfc 5661 says that "For the fore channel, the server
> > MAY change the requested value."
> > 
> > Also, there's no reason why the client would have to care if the server
> > is willing to accept *more* operations per compound than the client
> > requested.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  fs/nfs/nfs4proc.c |    1 -
> >  1 files changed, 0 insertions(+), 1 deletions(-)
> > 
> > On the other hand, if the server *decreases* max_ops on the forechannel,
> > the client may need to do something.  (Probably just fail for now.)  Why
> > aren't we checking for that case?
> > 
> > --b.
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 071fced..a5a3690 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -4880,7 +4880,6 @@ static int nfs4_verify_channel_attrs(struct nfs41_create_session_args *args,
> >  
> >  	ret |= _verify_fore_channel_attr(headerpadsz);
> >  	ret |= _verify_fore_channel_attr(max_resp_sz);
> > -	ret |= _verify_fore_channel_attr(max_ops);
> >  
> >  	ret |= _verify_back_channel_attr(headerpadsz);
> >  	ret |= _verify_back_channel_attr(max_rqst_sz);
> 
> Yes. That all looks wrong.
> 
> Can we please just get rid of that senseless macro, and open code those
> checks instead of the above patch? The current code is just pure
> obfuscation...

Sounds good to me.  I'm hoping Andy can be roped into it....

--b.
