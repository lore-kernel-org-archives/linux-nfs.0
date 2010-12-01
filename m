Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51512 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807Ab0LAFGW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 00:06:22 -0500
In-Reply-To: <1291177753.7694.17.camel@heimdal.trondhjem.org>
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTin8FSeM8cQ8BWYWjiyGy33EwzpMfFwauK+4j0uT@mail.gmail.com> <1291177753.7694.17.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 30 Nov 2010 21:06:00 -0800
Message-ID: <AANLkTi=p8mF2=G8TPi7TciEYS8cyDNp8OG+ksrF7b-vf@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFS: lock the readdir page while it is in use
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 30, 2010 at 8:29 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> I'm not worried about other readdir calls invalidating the page. My
> concern is rather about the VM memory reclaimers ejecting the page from
> the page cache, and calling nfs_readdir_clear_array while we're
> referencing the page.

I think you're making a fundamental mistake here, and you're confused
by a much deeper problem.

The thing is, the ".releasepage" callback gets called _before_ the
page actually gets removed from the page cache, and there is no
guarantee that it will always be removed at all!

In fact, anybody holding a reference to it will result in
page_freeze_refs() not successfully clearing all the refs, and that in
turn will abort the actual freeing of the page. So while you hold the
page count, your page will NOT be freed. Guaranteed.

But it is true that the ".releasepage()" function may be called. So if
your NFS release callback ends up invalidating the data on that page,
that page lock thing will make a difference, yes.

But at the same time, are you sure that you are able to then handle
the case of that page still existing in the page cache and being used
afterwards? Looking at the code, it doesn't look that way to me.

So I think you're confused, and the NFS code totally incorrectly
thinks that ".releasepage" is something that happens at the last use
of the page. It simply is not so. In fact, you seem to return 0, which
I think means "failure to release", so the VM will just mark it busy
again afterwards.

Now, I think you do have a few options:

 - keep the current model. BUT! In the page cache release function
(nfs_readdir_clear_array), make sure that you also clear the
up-to-date bit, so that the page gets read back in since it no longer
contains any valid information. And return success for the
"releasepage" operatioin.

Alternatively:

 - introduce a callback for the case of the page actually being gone
from the page cache, which gets called _after_ the removal.

which seems to be what you really want, since for you the releasepage
thing is about releasing the data structures associated with that
cache. So you don't want to worry about the page lock, and you don't
want to worry about the case of "maybe it won't get released at all
after this because somebody still holds a ref-count".

> As far as I can see, the only way to protect against that is to lock the
> page, perform the usual tests and then release the page lock when we're
> done...

I think one of us is confused. And it's possible that it is me. It's
been a _long_ time since I looked at that code, and I may well be
missing something. But I get the strong feeling you're mis-using
'.releasepage' and confused about the semantics.

                 Linus "maybe confused myself" Torvalds
