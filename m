Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45375 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070AbaEFQg4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 12:36:56 -0400
Date: Tue, 6 May 2014 12:36:55 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/70] NFSd: Ensure we clear the cstate->slot in
 nfsd4_proc_compound
Message-ID: <20140506163655.GC18281@fieldses.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <20140506153159.GA18281@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140506153159.GA18281@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 06, 2014 at 11:32:00AM -0400, Bruce Fields wrote:
> On Fri, Apr 18, 2014 at 02:43:55PM -0400, Trond Myklebust wrote:
> > Otherwise, we may end up triggering all those nfsd4_has_session()
> > tests.
> 
> Surely we'd have seen failures if this was actually not zeroed....
> 
> Right, I think the
> 
> 	memset(rqstp->rq_argp, 0, procp->pc_argsize);
> 
> in svc_process_common() handles this.
> 
> But apparently the lack of an explicit assignment was confusing.  So
> maybe it's better to have one.
> 
> (Or if not, to get rid of the other unnecessary assignments.)

(Dropping, assuming you'll resend with updated changelog if you feel
strongly about it....).

> 
> --b.
> 
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfsd/nfs4proc.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index d543222babf3..8eabbfb25441 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -1293,6 +1293,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
> >  	cstate->minorversion = args->minorversion;
> >  	cstate->replay_owner = NULL;
> >  	cstate->session = NULL;
> > +	cstate->slot = NULL;
> >  	fh_init(current_fh, NFS4_FHSIZE);
> >  	fh_init(save_fh, NFS4_FHSIZE);
> >  	/*
> > -- 
> > 1.9.0
> > 
