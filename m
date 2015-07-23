Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57214 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753149AbbGWPxq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jul 2015 11:53:46 -0400
Date: Thu, 23 Jul 2015 11:53:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/14] nfsd: Add missing gen_confirm in
 nfsd4_setclientid()
Message-ID: <20150723155345.GC13399@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A38505.6040405@gmail.com>
 <55B0406B.7010009@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55B0406B.7010009@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 23, 2015 at 09:16:27AM +0800, Kinglong Mee wrote:
> This one needs be applied with
> "nfsd: New counter for generating client confirm verifier"
> that is only update client confirm verifier without fix this problem.

Oh, right, I forgot the original patch after the discussion; applying
"nfsd: Add missing gen_confirm...".

--b.

> 
> thanks,
> Kinglong Mee
> 
> On 7/13/2015 17:29, Kinglong Mee wrote:
> > Commit 294ac32e99 "nfsd: protect clid and verifier generation with client_lock"
> > have moved gen_confirm() to gen_clid().
> > 
> > After it, setclientid will return a bad reply with all zero confirms
> > after copy_clid().
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  fs/nfsd/nfs4state.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index e0a4556..b1f84fc 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3042,10 +3042,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	unconf = find_unconfirmed_client_by_name(&clname, nn);
> >  	if (unconf)
> >  		unhash_client_locked(unconf);
> > -	if (conf && same_verf(&conf->cl_verifier, &clverifier))
> > +	if (conf && same_verf(&conf->cl_verifier, &clverifier)) {
> >  		/* case 1: probable callback update */
> >  		copy_clid(new, conf);
> > -	else /* case 4 (new client) or cases 2, 3 (client reboot): */
> > +		gen_confirm(new, nn);
> > +	} else /* case 4 (new client) or cases 2, 3 (client reboot): */
> >  		gen_clid(new, nn);
> >  	new->cl_minorversion = 0;
> >  	gen_callback(new, setclid, rqstp);
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
