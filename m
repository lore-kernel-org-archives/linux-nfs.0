Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45546 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755819Ab0LAXcC convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 18:32:02 -0500
In-Reply-To: <20101201143856.51f4f9d9.akpm@linux-foundation.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
 <1291229669.6609.24.camel@heimdal.trondhjem.org> <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
 <1291234251.6609.39.camel@heimdal.trondhjem.org> <20101201123341.d12ef362.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1012011258220.18662@tigran.mtv.corp.google.com>
 <alpine.LSU.2.00.1012011311590.18920@tigran.mtv.corp.google.com>
 <20101201133831.ea6ba10a.akpm@linux-foundation.org> <1291240272.6609.50.camel@heimdal.trondhjem.org>
 <20101201141351.8609140b.akpm@linux-foundation.org> <AANLkTimgZPET+T16Qpj_KnpCu==97g-8+_y5dtjNOrxG@mail.gmail.com>
 <20101201143856.51f4f9d9.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 15:31:11 -0800
Message-ID: <AANLkTi=x1bz5sJXOGERXh8iRHNZa+_gaYOyDecg3G92+@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 2:38 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> OK, the stop_machine() plugs a lot of potential race-vs-module-unload
> things.  But Trond is referring to races against vmscan inode reclaim,
> unmount, etc.

So?

A filesystem module cannot be unloaded while it's still mounted.

And unmount doesn't succeed until all inodes are gone.

And getting rid of an inode doesn't succeed until all pages associated
with it are gone.

And getting rid of the pages involves locking them (whether in
truncate or vmscan) and removing them from all lists.

Ergo: vmscan has a locked page leads to the filesystem being
guaranteed to not be unmounted.  And that, in turn, guarantees that
the module won't be unloaded until the machine has gone through an
idle cycle.

It really is that simple. There's nothing subtle there. The reason
spin_unlock(&mapping->tree_lock) is safe is exactly the above trivial
chain of dependencies. And it's also exactly why
mapping->a_ops->freepage() would also be safe.

This is pretty much how all the module races are handled. Doing module
ref-counts per page (or per packet in flight for things like
networking) would be prohibitively expensive. There's no way we can
ever do that.

                    Linus
