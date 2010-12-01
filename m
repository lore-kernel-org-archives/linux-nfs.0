Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59485 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756073Ab0LATwj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 14:52:39 -0500
In-Reply-To: <alpine.LSU.2.00.1012011058560.16407@tigran.mtv.corp.google.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
 <1291229669.6609.24.camel@heimdal.trondhjem.org> <alpine.LSU.2.00.1012011058560.16407@tigran.mtv.corp.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 11:52:17 -0800
Message-ID: <AANLkTika6iMcX9=WhLrwHSNoSAcWuzAoJ_uX3yvSOwck@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
To: Hugh Dickins <hughd@google.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@kernel.dk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 11:23 AM, Hugh Dickins <hughd@google.com> wrote:
>
> But I'd prefer us not to throw in another callback if it's well
> workable with the ->releasepage we already have.

The thing is, NFS already really uses releasepage for its "real"
designed usage, in the form of the fscache case (which the directory
inodes don't use).

I really hate mixing things up. The NFS directory case really hasn't
got anything to do with releasepage, and taking the page lock on the
read side is just really sad. As is marking the page not up-to-date,
just so that it will get filled again.

In fact, I don't even know if it's kosher by VFS standards to clear
the up-to-date bit in the first place after it has already gotten set.
It absolutely isn't for anything that can be mmap'ed. Obviously, mmap
doesn't work on the directory cache anyway, but the point is that the
work-arounds for the semantic gap are really quite ugly.

Certainly much uglier than just adding some much simpler semantics to
the "now I'm releasing the page" case in the VM.

                                 Linus
