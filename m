Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45332 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752990Ab0LAQsA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 11:48:00 -0500
In-Reply-To: <4CF67955.2050808@redhat.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com> <4CF67955.2050808@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 08:47:34 -0800
Message-ID: <AANLkTinwrhUOQ0LnavQY6+TQS_TqnRS0q-XXykZ8ap5G@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
To: Rik van Riel <riel@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 8:35 AM, Rik van Riel <riel@redhat.com> wrote:
>
> Surely somebody can have just looked up the page and
> gotten a reference count, right before your ->freepage
> call is invoked?

No.

The removal from the page cache is atomic, even in the presence of the
lockless lookup.

The page cache lookup does a "get_page_unless_zero()" on the count, so
when __remove_mapping() has removed the page using
"page_freeze_refs()", it's really gone, and cannot be looked up.

And if that is broken, then we have much more serious problems (like
aliasing the same page when doing mmap/read etc), so that's more than
just an implementation detail, it's a fundamental requirement of the
whole page-cache design.

And that's the whole point of adding this callback to the
__remove_mapping() stage: that's the _only_ point where we really end
up knowing that "yes, we really removed that page, and there are no
more users".

                              Linus
