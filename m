From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
Date: Sat, 21 Jun 2008 16:54:47 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0806211651210.2926@woody.linux-foundation.org>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com> <20080621224135.GD4692@csn.ul.ie> <Pine.LNX.4.64.0806211636090.18642@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>,
	Alexander Beregalov <a.beregalov@gmail.com>,
	kernel-testers@vger.kernel.org,
	kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	Lee Schermerhorn <lee.schermerhorn@hp.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>,
	Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Return-path: <kernel-testers-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0806211636090.18642-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
Sender: kernel-testers-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Sat, 21 Jun 2008, Christoph Lameter wrote:
>
>   Not a direct explanation for the problem but the memory wastage could 
> certainly can heretofore undiscovered locking dependencies to be 
> exposed.

Well, not for these traces, no. The trace contains __slab_alloc() in the 
call chain, which definitely fingers SLUB, not slab, despite the name 
(slab calls its allocation routines "cache_alloc", while slub calls them 
"slab_alloc" ;)

So the patch looks fine, and I applied it, but as Mel already mentioned, 
it looks like it won't be making any difference for Alexander.

		Linus
