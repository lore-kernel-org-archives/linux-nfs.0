From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/12] sunrpc/cache: avoid variable over-loading in
	cache_defer_req
Date: Thu, 6 Aug 2009 14:35:28 +1000
Message-ID: <19066.23952.91954.409689@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
	<20090804052239.15929.87201.stgit@notabene.brown>
	<20090804204729.GB24758@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43567 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbZHFEfT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2009 00:35:19 -0400
In-Reply-To: message from J. Bruce Fields on Tuesday August 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday August 4, bfields@fieldses.org wrote:
> On Tue, Aug 04, 2009 at 03:22:39PM +1000, NeilBrown wrote:
> > In cache_defer_req, 'dreq' is used for two significantly different
> > values that happen to be of the same type.
> > 
> > This is both confusing, and make it hard to extend the range of one of
> > the values as we will in the next patch.
> > So introduce 'discard' to take one of the values.
> > 
> > Signed-off-by: NeilBrown <neilb@suse.de>
...
> > @@ -586,20 +586,20 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
> >  	list_add(&dreq->hash, &cache_defer_hash[hash]);
> >  
> >  	/* it is in, now maybe clean up */
> > -	dreq = NULL;
> > +	discard = NULL;
> >  	if (++cache_defer_cnt > DFR_MAX) {
> > -		dreq = list_entry(cache_defer_list.prev,
> > -				  struct cache_deferred_req, recent);
> > +		discard = list_entry(cache_defer_list.prev,
> > +				     struct cache_deferred_req, recent);
> >  		list_del_init(&dreq->recent);
> >  		list_del_init(&dreq->hash);
> 
> Shouldn't these two "dreq"'s be "discard"'s as well?

Yes, definitely.  Thanks for catching that.

NeilBrown
