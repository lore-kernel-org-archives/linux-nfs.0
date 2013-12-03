Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25555 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753871Ab3LCS3B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Dec 2013 13:29:01 -0500
Date: Tue, 3 Dec 2013 05:59:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Minlan Wang <wangminlan@huawei.com>
Cc: Christoph Hellwig <hch@infradead.org>, <linux-nfs@vger.kernel.org>
Subject: Re: 3.12-rc2 nfsd oops in nfsd_cache_lookup
Message-ID: <20131203055938.582db322@tlielax.poochiereds.net>
In-Reply-To: <20131203033342.GA8877@f18.localdomain>
References: <20131201102954.GA26976@infradead.org>
	<20131202122219.043174d6@tlielax.poochiereds.net>
	<20131202172547.GA5211@infradead.org>
	<20131203033342.GA8877@f18.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 3 Dec 2013 11:33:42 +0800
Minlan Wang <wangminlan@huawei.com> wrote:

> On Mon, Dec 02, 2013 at 09:25:47AM -0800, Christoph Hellwig wrote:
> > On Mon, Dec 02, 2013 at 12:22:19PM -0500, Jeff Layton wrote:
> > > Looks like a similar oops to the one reported here:
> > > 
> > >     https://bugzilla.redhat.com/show_bug.cgi?id=1025907
> > > 
> > > Do you have a way to reproduce this reliably?
> > 
> > Seem to happen about 2/3s of the time when running xfstests on a v3
> > export for me.  The other one third create a different lockup in the
> > same test that I'm looking at at the moment.
> > 
> I reviewed the code of nfsd_cache_lookup(), this part makes me
> suspicious:
> in nfsd_cache_lookup():
> The first entry in lru_head is keeped for recycle later:
> 	if (!list_empty(&lru_head)) {
> 		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
> 		if (nfsd_cache_entry_expired(rp) ||
> 		    num_drc_entries >= max_drc_entries) {
> 			lru_put_end(rp);
> 			prune_cache_entries();
> 			goto search_cache;
> 		}
> 	}
> But in prune_cache_entries(), there's no guarantee that it won't be freed: if
> all entries in lru_head is expired, all of them will be freed.
> So, later in the search_cache part, if rp from the first entry in lru_head is reused, would we
> run into some illegal memory acess, or the problem happened in this
> thread?

Actually, it's pretty unlikely that this would get pruned here.
lru_put_end updates the timestamp on the entry, so the
prune_cache_entries run would have to take more than 120s and prune
everything off of the list.

The real bug is that we can later find the entry in the hash that we
intend to reuse and then free that cache entry. The safe thing to do
here is to just unhash the entry that we intend to use so that it can't
be found or pruned.

I sent a patch that should fix this the correct way:

    [PATCH] nfsd: when reusing an existing repcache entry, unhash it first

-- 
Jeff Layton <jlayton@redhat.com>
