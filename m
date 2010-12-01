Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62441 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756589Ab0LAXn6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 18:43:58 -0500
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>,
        Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
In-Reply-To: <AANLkTi=x1bz5sJXOGERXh8iRHNZa+_gaYOyDecg3G92+@mail.gmail.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
	 <20101201150428.GA2879@elliptictech.com>
	 <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
	 <1291229669.6609.24.camel@heimdal.trondhjem.org>
	 <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
	 <1291234251.6609.39.camel@heimdal.trondhjem.org>
	 <20101201123341.d12ef362.akpm@linux-foundation.org>
	 <alpine.LSU.2.00.1012011258220.18662@tigran.mtv.corp.google.com>
	 <alpine.LSU.2.00.1012011311590.18920@tigran.mtv.corp.google.com>
	 <20101201133831.ea6ba10a.akpm@linux-foundation.org>
	 <1291240272.6609.50.camel@heimdal.trondhjem.org>
	 <20101201141351.8609140b.akpm@linux-foundation.org>
	 <AANLkTimgZPET+T16Qpj_KnpCu==97g-8+_y5dtjNOrxG@mail.gmail.com>
	 <20101201143856.51f4f9d9.akpm@linux-foundation.org>
	 <AANLkTi=x1bz5sJXOGERXh8iRHNZa+_gaYOyDecg3G92+@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 18:43:56 -0500
Message-ID: <1291247036.6609.76.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 15:31 -0800, Linus Torvalds wrote:
> On Wed, Dec 1, 2010 at 2:38 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > OK, the stop_machine() plugs a lot of potential race-vs-module-unload
> > things.  But Trond is referring to races against vmscan inode reclaim,
> > unmount, etc.
> 
> So?
> 
> A filesystem module cannot be unloaded while it's still mounted.
> 
> And unmount doesn't succeed until all inodes are gone.
> 
> And getting rid of an inode doesn't succeed until all pages associated
> with it are gone.
> 
> And getting rid of the pages involves locking them (whether in
> truncate or vmscan) and removing them from all lists.
> 
> Ergo: vmscan has a locked page leads to the filesystem being
> guaranteed to not be unmounted.  And that, in turn, guarantees that
> the module won't be unloaded until the machine has gone through an
> idle cycle.
> 
> It really is that simple. There's nothing subtle there. The reason
> spin_unlock(&mapping->tree_lock) is safe is exactly the above trivial
> chain of dependencies. And it's also exactly why
> mapping->a_ops->freepage() would also be safe.
> 
> This is pretty much how all the module races are handled. Doing module
> ref-counts per page (or per packet in flight for things like
> networking) would be prohibitively expensive. There's no way we can
> ever do that.

Although the page is locked, it may no longer be visible to the lockless
page lookup once the radix_tree_delete() completes in
__remove_from_page_cache.
Furthermore, if the same routine causes mapping->nr_pages to go to zero
before iput_final() hits truncate_inode_pages(), then the latter exits
immediately.

Both these cases would appear to allow iput_final() to release the inode
before vmscan gets round to unlocking the mapping->tree_lock since
truncate_inode_pages() no longer thinks it has any work to do.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

