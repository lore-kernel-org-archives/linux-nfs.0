Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37878 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756498Ab0LBEAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 23:00:03 -0500
In-Reply-To: <1291262016.6609.115.camel@heimdal.trondhjem.org>
References: <1291259285-26803-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291259285-26803-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291259285-26803-3-git-send-email-Trond.Myklebust@netapp.com>
 <alpine.LSU.2.00.1012011925580.25894@tigran.mtv.corp.google.com> <1291262016.6609.115.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 19:58:18 -0800
Message-ID: <AANLkTi=LJaSTREikZg3M=QFkihEcQEGCJLW4wUPsDm9s@mail.gmail.com>
Subject: Re: [PATCH v3 2/3] Call the filesystem back whenever a page is
 removed from the page cache
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Hugh Dickins <hughd@google.com>, Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 7:53 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> Again, I was being cautious (I freely admit to not having studied
> stop_machine()). If nobody disagrees with your interpretation, then I'm
> very happy to drop the preempt disable/enable crud.

Just remove it. It won't matter for the stop_machine case, and the
other case that Andrew pointed out (just unmap with memory pressure)
is an independent thing that doesn't do stop_machine anyway.

In the next merge window we'll see the whole RCU name lookup (let's
see if people can agree on it, or whether I'll just have to do an
executive decision and push it through even without consensus), which
then rcu-delays inode freeing, and that will fix it for real. When
that happens, doing a "rcu_read_lock()" in vmscan.c before the removal
of the page from the mapping, and then unlocking after the callback
will be a real fix, but it will require the rcu release to be that
real fix anyway, so doing something else now will just confuse things.

                       Linus
