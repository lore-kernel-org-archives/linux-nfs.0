Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21565 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345Ab0LAOuM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 09:50:12 -0500
Subject: Re: [PATCH 2/3] NFS: lock the readdir page while it is in use
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTi=p8mF2=G8TPi7TciEYS8cyDNp8OG+ksrF7b-vf@mail.gmail.com>
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
	 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTin8FSeM8cQ8BWYWjiyGy33EwzpMfFwauK+4j0uT@mail.gmail.com>
	 <1291177753.7694.17.camel@heimdal.trondhjem.org>
	 <AANLkTi=p8mF2=G8TPi7TciEYS8cyDNp8OG+ksrF7b-vf@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 09:49:55 -0500
Message-ID: <1291214995.6609.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-30 at 21:06 -0800, Linus Torvalds wrote:
> On Tue, Nov 30, 2010 at 8:29 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > I'm not worried about other readdir calls invalidating the page. My
> > concern is rather about the VM memory reclaimers ejecting the page from
> > the page cache, and calling nfs_readdir_clear_array while we're
> > referencing the page.
> 
> I think you're making a fundamental mistake here, and you're confused
> by a much deeper problem.
> 
> The thing is, the ".releasepage" callback gets called _before_ the
> page actually gets removed from the page cache, and there is no
> guarantee that it will always be removed at all!
> 
> In fact, anybody holding a reference to it will result in
> page_freeze_refs() not successfully clearing all the refs, and that in
> turn will abort the actual freeing of the page. So while you hold the
> page count, your page will NOT be freed. Guaranteed.
> 
> But it is true that the ".releasepage()" function may be called. So if
> your NFS release callback ends up invalidating the data on that page,
> that page lock thing will make a difference, yes.
> 
> But at the same time, are you sure that you are able to then handle
> the case of that page still existing in the page cache and being used
> afterwards? Looking at the code, it doesn't look that way to me.
> 
> So I think you're confused, and the NFS code totally incorrectly
> thinks that ".releasepage" is something that happens at the last use
> of the page. It simply is not so. In fact, you seem to return 0, which
> I think means "failure to release", so the VM will just mark it busy
> again afterwards.
> 
> Now, I think you do have a few options:
> 
>  - keep the current model. BUT! In the page cache release function
> (nfs_readdir_clear_array), make sure that you also clear the
> up-to-date bit, so that the page gets read back in since it no longer
> contains any valid information. And return success for the
> "releasepage" operatioin.

This is the option I'm attempting for now. I'm quite fine with the page
only being readable while under the page lock since this is readdir, and
so we don't have to worry about mmap() and its ilk.

My latest incarnation of the patches has added in all the PagePrivate()
foo to make try_to_release_page() work, and also adds in an
invalidatepage() address space operation (I rediscovered that
truncate_inode_pages() will otherwise call block_invalidatepage, and
subsequently Oops).

I'm still in the process of testing, but the latest patchset appears to
be doing all the right things for now. I'll post an update later today
so that Nick and others can test too.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

