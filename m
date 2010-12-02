Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51898 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754069Ab0LBBWu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 20:22:50 -0500
Date: Wed, 1 Dec 2010 17:22:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
Message-Id: <20101201172224.b8a25bdf.akpm@linux-foundation.org>
In-Reply-To: <AANLkTinbuRRpg7Y8Zu=PD36BO11+qdjZ9uT=u9gCTpDw@mail.gmail.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
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
	<20101201153608.78b331f9.akpm@linux-foundation.org>
	<AANLkTinbuRRpg7Y8Zu=PD36BO11+qdjZ9uT=u9gCTpDw@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 1 Dec 2010 17:05:43 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Dec 1, 2010 at 3:36 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed, 1 Dec 2010 15:31:11 -0800
> > Linus Torvalds <torvalds@linux-foundation.org> wrote:
> >>
> >> Ergo: vmscan has a locked page leads to the filesystem being
> >> guaranteed to not be unmounted. __And that, in turn, guarantees that
> >> the module won't be unloaded until the machine has gone through an
> >> idle cycle.
> >
> > The page isn't attached to the address_space any more:
> 
> Did you even read the email?

We stopped talking about module unload hours ago.  That matter is settled.

What we're talking about is races against memory reclaim, unmount, etc.


