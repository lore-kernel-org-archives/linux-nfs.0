Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33289 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756823Ab0LATzz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 14:55:55 -0500
In-Reply-To: <1291229669.6609.24.camel@heimdal.trondhjem.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com> <1291229669.6609.24.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 11:47:14 -0800
Message-ID: <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 10:54 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> Hmm... Looking again at the problem, it appears that the same callback
> needs to be added to truncate_complete_page() and
> invalidate_complete_page2(). Otherwise we end up in a situation where
> the page can sometimes be removed from the page cache without calling
> freepage().

Yes, I think any caller of __remove_from_page_cache() should do it
once it has dropped all locks.

And to be consistent with that rule, even in the __remove_mapping()
function I suspect the code to call ->freepage() might as well be done
only in the __remove_from_page_cache() case (ie not in the
PageSwapCache() case).

Then, add the case to the end of "remove_page_cache()" itself, and now
it's really easy to just grep for __remove_from_page_cache() and make
sure they all do it.

That sounds sane, no?

                Linus
