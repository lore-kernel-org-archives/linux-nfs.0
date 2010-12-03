Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:30265 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758224Ab0LCJRY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Dec 2010 04:17:24 -0500
Date: Fri, 3 Dec 2010 20:12:12 +1100
From: Nick Piggin <npiggin@kernel.dk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
Message-ID: <20101203091212.GA3346@amd>
References: <20101201133831.ea6ba10a.akpm@linux-foundation.org>
 <1291240272.6609.50.camel@heimdal.trondhjem.org>
 <20101201141351.8609140b.akpm@linux-foundation.org>
 <AANLkTimgZPET+T16Qpj_KnpCu==97g-8+_y5dtjNOrxG@mail.gmail.com>
 <20101201143856.51f4f9d9.akpm@linux-foundation.org>
 <AANLkTi=x1bz5sJXOGERXh8iRHNZa+_gaYOyDecg3G92+@mail.gmail.com>
 <20101201153608.78b331f9.akpm@linux-foundation.org>
 <AANLkTinbuRRpg7Y8Zu=PD36BO11+qdjZ9uT=u9gCTpDw@mail.gmail.com>
 <20101201172224.b8a25bdf.akpm@linux-foundation.org>
 <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 01, 2010 at 05:42:08PM -0800, Linus Torvalds wrote:
> On Wed, Dec 1, 2010 at 5:22 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > What we're talking about is races against memory reclaim, unmount, etc.
> 
> Ahh. Those I can believe in.

Yeah, it's a tricky question. It would be solved if the inode reclaim
code didn't have the nasty shortcuts for nr_pages == 0 sitting outisde
the tree_lock... any time we have these kinds of optimisations checking
things outside locks, we invaraibly find they have races or data races
:(

So doing those checks under lock would be a reasonable way to fix it
if anyone cares for 2.6.37 or earlier (eg. distros). But it is another
lock in inode freeing path which is nice to avoid, so let's just get
it fixed with RCU in 2.6.38.


> Although I think they'd almost
> incidentally be fixed by making inode freeing (which is where the
> 'struct address_space' is embedded) RCU-safe, which we're going to do
> anyway in 38. Then we could make the vmscan code just be a rcu-read
> section.

Yep, good observation.

Thanks,
Nick

