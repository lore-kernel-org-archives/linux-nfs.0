Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:20592 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab3LCDji (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 22:39:38 -0500
Date: Tue, 3 Dec 2013 11:33:42 +0800
From: Minlan Wang <wangminlan@huawei.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Jeff Layton <jlayton@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: 3.12-rc2 nfsd oops in nfsd_cache_lookup
Message-ID: <20131203033342.GA8877@f18.localdomain>
References: <20131201102954.GA26976@infradead.org>
 <20131202122219.043174d6@tlielax.poochiereds.net>
 <20131202172547.GA5211@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <20131202172547.GA5211@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 09:25:47AM -0800, Christoph Hellwig wrote:
> On Mon, Dec 02, 2013 at 12:22:19PM -0500, Jeff Layton wrote:
> > Looks like a similar oops to the one reported here:
> > 
> >     https://bugzilla.redhat.com/show_bug.cgi?id=1025907
> > 
> > Do you have a way to reproduce this reliably?
> 
> Seem to happen about 2/3s of the time when running xfstests on a v3
> export for me.  The other one third create a different lockup in the
> same test that I'm looking at at the moment.
> 
I reviewed the code of nfsd_cache_lookup(), this part makes me
suspicious:
in nfsd_cache_lookup():
The first entry in lru_head is keeped for recycle later:
	if (!list_empty(&lru_head)) {
		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
		if (nfsd_cache_entry_expired(rp) ||
		    num_drc_entries >= max_drc_entries) {
			lru_put_end(rp);
			prune_cache_entries();
			goto search_cache;
		}
	}
But in prune_cache_entries(), there's no guarantee that it won't be freed: if
all entries in lru_head is expired, all of them will be freed.
So, later in the search_cache part, if rp from the first entry in lru_head is reused, would we
run into some illegal memory acess, or the problem happened in this
thread?
