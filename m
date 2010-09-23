From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 4/7] sunrpc/cache: centralise handling of size limit on
 deferred list.
Date: Thu, 23 Sep 2010 13:02:49 +1000
Message-ID: <20100923130249.4678c4a7@notabene>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
	<20100922025507.31745.61919.stgit@localhost.localdomain>
	<20100922183154.GC26903@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41307 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378Ab0IWDC4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 23:02:56 -0400
In-Reply-To: <20100922183154.GC26903@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 22 Sep 2010 14:31:54 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Sep 22, 2010 at 12:55:07PM +1000, NeilBrown wrote:
> > We limit the number of 'defer' requests to DFR_MAX.
> > 
> > The imposition of this limit is spread about a bit - sometime we don't
> > add new things to the list, sometimes we remove old things.
> > 
> > Also it is currently applied to requests which we are 'waiting' for
> > rather than 'deferring'.  This doesn't seem ideal as 'waiting'
> > requests are naturally limited by the number of threads.
> > 
> > So gather the DFR_MAX handling code to one place and only apply it to
> > requests that are actually being deferred.
> > 
> > This means that not all 'cache_deferred_req' structures go on the
> > 'cache_defer_list, so we need to be careful when removing things.
> 
> The idea sounds OK.
> 
> > +static void cache_limit_defers(struct cache_deferred_req *dreq)
> > +{
> > +	/* Add 'dreq' to the list of deferred requests and make sure
> > +	 * we don't exceed the limit of allowed deferred requests.
> > +	 */
> > +	struct cache_deferred_req *discard = NULL;
> > +
> > +	spin_lock(&cache_defer_lock);
> > +	if (!list_empty(&dreq->recent) ||
> > +	    hlist_unhashed(&dreq->hash)) {
> > +		/* Must have lost a race, maybe cache_revisit_request is
> > +		 * already processing this.  In any case, there is nothing for
> > +		 * us to do.
> > +		 */
> > +		spin_unlock(&cache_defer_lock);
> 
> Did you mean to return here?
> 

Yes :-(

Thanks,
NeilBrown
