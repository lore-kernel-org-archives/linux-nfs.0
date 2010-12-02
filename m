Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36376 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754664Ab0LBCGx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 21:06:53 -0500
Date: Wed, 1 Dec 2010 18:05:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
Message-Id: <20101201180518.62f0915c.akpm@linux-foundation.org>
In-Reply-To: <AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
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
	<20101201153608.78b331f9.akpm@linux-foundation.org>
	<AANLkTinbuRRpg7Y8Zu=PD36BO11+qdjZ9uT=u9gCTpDw@mail.gmail.com>
	<20101201172224.b8a25bdf.akpm@linux-foundation.org>
	<AANLkTinpvMJsC2XMUyDTaAdozFBLkcdde5_V57Jx-Z4w@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 1 Dec 2010 17:42:08 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Dec 1, 2010 at 5:22 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > What we're talking about is races against memory reclaim, unmount, etc.
> 
> Ahh. Those I can believe in. Although I think they'd almost
> incidentally be fixed by making inode freeing (which is where the
> 'struct address_space' is embedded) RCU-safe, which we're going to do
> anyway in 38. Then we could make the vmscan code just be a rcu-read
> section.

I didn't know that aspect of it.  It will be nice to plug this race -
it's been there for so long because nobody was able to think of an
acceptable way of fixing it by direct means (synchronous locking,
refcounting, etc).  Taking a ref on the inode doesn't work, because we
can't run iput_final() in direct-reclaim contexts (lock ordering snafus).

vmscan is the problematic path - I _think_ all other code paths which
remove pagecache have an inode ref.  But this assumes that
inode->i_mapping points at inode->i_data!  Need to think about the
situation where it points at a different inode's i_data - in that case
these callers may have a ref on the wrong inode.

> Of course,  I do think the race is basically impossible to hit in
> practice regardless.

Actually I was able to hit the race back in late 2.5 or thereabouts. 
Really massive memory pressure caused vmscan->icache_shrinker to free
the inode/address_space while another CPU in vmscan was playing with the
address_space.  That was quite a debugging session ;)

