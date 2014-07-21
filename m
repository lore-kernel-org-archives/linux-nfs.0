Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:65509 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbaGUURs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 16:17:48 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so5934345qgd.13
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 13:17:47 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 21 Jul 2014 16:17:45 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: print status when nfsd4_open fails to open file
 it just created
Message-ID: <20140721161745.3c63001a@tlielax.poochiereds.net>
In-Reply-To: <20140721201320.GI8438@fieldses.org>
References: <1405949850-27841-1-git-send-email-jlayton@primarydata.com>
	<20140721201320.GI8438@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Jul 2014 16:13:20 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jul 21, 2014 at 09:37:30AM -0400, Jeff Layton wrote:
> > It's possible for nfsd to fail opening a file that it has just created.
> > When that happens, we throw a WARN but it doesn't include any info about
> > the error code. Print the status code to give us a bit more info.
> > 
> > Our QA group hit some of these warnings under some very heavy stress
> > testing. My suspicion is that they hit the file-max limit, but it's hard
> > to know for sure. Go ahead and add a -ENFILE mapping to
> > nfserr_serverfault to make the error more distinct (and correct).
> 
> Thanks, applying.
> 
> We do need to fix this.  The open code is complicated, but I think there
> probably aren't too many failure cases after a successful create left.
> 
> --b.
> 

Yeah, this is just an interim step to help us nail down some of the
failure scenarios. It doesn't really fix anything...

What we'll eventually need to do is reorganize the code so that the
creates and opens are atomic. That'll take some work to untangle though
since there are several steps between creating a file and opening it
now.

> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4proc.c | 4 +++-
> >  fs/nfsd/nfsproc.c  | 1 +
> >  2 files changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 29a617ebe38c..8611585f739d 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -460,7 +460,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	 * set, (2) sets open->op_stateid, (3) sets open->op_delegation.
> >  	 */
> >  	status = nfsd4_process_open2(rqstp, resfh, open);
> > -	WARN_ON(status && open->op_created);
> > +	WARN(status && open->op_created,
> > +	     "nfsd4_process_open2 failed to open newly-created file! status=%u\n",
> > +	     be32_to_cpu(status));
> >  out:
> >  	if (resfh && resfh != &cstate->current_fh) {
> >  		fh_dup2(&cstate->current_fh, resfh);
> > diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> > index b19c7e8bf64c..b8680738f588 100644
> > --- a/fs/nfsd/nfsproc.c
> > +++ b/fs/nfsd/nfsproc.c
> > @@ -745,6 +745,7 @@ nfserrno (int errno)
> >  		{ nfserr_notsupp, -EOPNOTSUPP },
> >  		{ nfserr_toosmall, -ETOOSMALL },
> >  		{ nfserr_serverfault, -ESERVERFAULT },
> > +		{ nfserr_serverfault, -ENFILE },
> >  	};
> >  	int	i;
> >  
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
