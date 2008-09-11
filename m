From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/6] NLM: Clean up before introducing new debugging
	messages
Date: Thu, 11 Sep 2008 17:45:43 -0400
Message-ID: <20080911214543.GA24459@fieldses.org>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net> <20080827205714.17837.95227.stgit@manray.1015granger.net> <20080911214225.GD17355@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49971 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbYIKVpp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2008 17:45:45 -0400
In-Reply-To: <20080911214225.GD17355@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2008 at 05:42:25PM -0400, bfields wrote:
> On Wed, Aug 27, 2008 at 04:57:15PM -0400, Chuck Lever wrote:
> > We're about to introduce some extra debugging messages in nlm_lookup_host().
> > Bring the coding style up to date first so we can cleanly introduce the new
> > debugging messages.
> 
> Looks fine to me.--b.

Whoops, sorry, ignore me, I was starting to run through patches I've
already applied....--b.

> 
> > 
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > ---
> > 
> >  fs/lockd/host.c |   19 +++++++++++--------
> >  1 files changed, 11 insertions(+), 8 deletions(-)
> > 
> > diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> > index a17664c..cb26e3d 100644
> > --- a/fs/lockd/host.c
> > +++ b/fs/lockd/host.c
> > @@ -103,16 +103,19 @@ static struct nlm_host *nlm_lookup_host(int server,
> >  		nlm_get_host(host);
> >  		goto out;
> >  	}
> > -	if (nsm)
> > -		atomic_inc(&nsm->sm_count);
> > -
> > -	host = NULL;
> >  
> > -	/* Sadly, the host isn't in our hash table yet. See if
> > -	 * we have an NSM handle for it. If not, create one.
> > +	/*
> > +	 * The host wasn't in our hash table.  If we don't
> > +	 * have an NSM handle for it yet, create one.
> >  	 */
> > -	if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len)))
> > -		goto out;
> > +	if (nsm)
> > +		atomic_inc(&nsm->sm_count);
> > +	else {
> > +		host = NULL;
> > +		nsm = nsm_find(sin, hostname, hostname_len);
> > +		if (!nsm)
> > +			goto out;
> > +	}
> >  
> >  	host = kzalloc(sizeof(*host), GFP_KERNEL);
> >  	if (!host) {
> > 
