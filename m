Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:52818 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751295AbeDXSf7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Apr 2018 14:35:59 -0400
Date: Tue, 24 Apr 2018 14:35:36 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        Richard Weinberger <richard@nod.at>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Philippe Ombredanne <pombredanne@nexb.com>,
        Kate Stewart <kstewart@linuxfoundation.org>,
        Mikulas Patocka <mpatocka@redhat.com>,
        linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180424183536.GF30619@thunk.org>
References: <20180424162712.GL17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180424162712.GL17484@dhcp22.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 24, 2018 at 10:27:12AM -0600, Michal Hocko wrote:
> fs/ext4/xattr.c
> 
> What to do about this? Well, there are two things. Firstly, it would be
> really great to double check whether the GFP_NOFS is really needed. I
> cannot judge that because I am not familiar with the code.

*Most* of the time it's not needed, but there are times when it is.
We could be more smart about sending down GFP_NOFS only when it is
needed.  If we are sending too many GFP_NOFS's allocations such that
it's causing heartburn, we could fix this.  (xattr commands are rare
enough that I dind't think it was worth it to modulate the GFP flags
for this particular case, but we could make it be smarter if it would
help.)

> If the use is really valid then we have a way to do the vmalloc
> allocation properly. We have memalloc_nofs_{save,restore} scope api. How
> does that work? You simply call memalloc_nofs_save when the reclaim
> recursion critical section starts (e.g. when you take a lock which is
> then used in the reclaim path - e.g. shrinker) and memalloc_nofs_restore
> when the critical section ends. _All_ allocations within that scope
> will get GFP_NOFS semantic automagically. If you are not sure about the
> scope itself then the easiest workaround is to wrap the vmalloc itself
> with a big fat comment that this should be revisited.

This is something we could do in ext4.  It hadn't been high priority,
because we've been rather overloaded.  As a suggestion, could you take
documentation about how to convert to the memalloc_nofs_{save,restore}
scope api (which I think you've written about e-mails at length
before), and put that into a file in Documentation/core-api?

The question I was trying to figure out which triggered the above
request is how/whether to gradually convert to that scope API.  Is it
safe to add the memalloc_nofs_{save,restore} to code and keep the
GFP_NOFS flags until we're sure we got it all right, for all of the
code paths, and then drop the GFP_NOFS?

Thanks,

						- Ted
