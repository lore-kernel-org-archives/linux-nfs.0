Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41549 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932835Ab1LFCIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Dec 2011 21:08:52 -0500
Date: Mon, 5 Dec 2011 21:08:51 -0500
To: Benny Halevy <bhalevy@tonian.com>
Cc: tigran.mkrtchyan@desy.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsv41: handle current stateid on open and close
Message-ID: <20111206020851.GA4486@fieldses.org>
References: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1323000237-13565-3-git-send-email-tigran.mkrtchyan@desy.de>
 <4EDB6AA3.1030702@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EDB6AA3.1030702@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 04, 2011 at 02:42:11PM +0200, Benny Halevy wrote:
> On 2011-12-04 14:03, tigran.mkrtchyan@desy.de wrote:
> > From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> > 
> > 
> > Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> > ---
> >  fs/nfsd/nfs4proc.c  |    6 ++++++
> >  fs/nfsd/nfs4state.c |   26 ++++++++++++++++++++------
> >  2 files changed, 26 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index fa38336..535aed2 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -400,6 +400,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	 */
> >  	status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
> >  	WARN_ON(status && open->op_created);
> > +
> > +	if(status)
> > +		goto out;
> > +
> > +	/* set current state id */
> > +	memcpy(&cstate->current_stateid, &open->op_stateid, sizeof(stateid_t));

That comment is a bit redundant.

> Since this should be done for all stateid-returning operations
> I think that a cleaner approach could be to mark those as such in
> nfsd4_ops by providing a per-op function to return the operation's
> stateid.  You can then call this method from nfsd4_proc_compound()
> after the call to nfsd4_encode_operation() and when status == 0.

So the choice is between

+       memcpy(&cstate->current_stateid, &open->op_stateid,
sizeof(stateid_t));

and

+       static void get_open_stateid(stateid_t *s)
+       {
+               memcpy(s, open->op_stateid);
+       }
+
+       [OP_OPEN] = {
+               ...
+               .op_get_stateid = get_open_stateid,
+               ...
+       }

?

I'm not so sure.

Anyway, thanks Tigran for looking at this.

Do we want to guarantee that the client can't expire as long as a
compound references the stateid?  I think that's the case.

--b.
