Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57843 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043Ab0LAOzz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 09:55:55 -0500
Subject: Re: [PATCH 2/3] NFS: lock the readdir page while it is in use
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4CF64A34.7070100@redhat.com>
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
	 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTin8FSeM8cQ8BWYWjiyGy33EwzpMfFwauK+4j0uT@mail.gmail.com>
	 <1291177753.7694.17.camel@heimdal.trondhjem.org>
	 <4CF64A34.7070100@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 09:55:53 -0500
Message-ID: <1291215353.6609.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 08:14 -0500, Rik van Riel wrote:
> On 11/30/2010 11:29 PM, Trond Myklebust wrote:
> 
> > I'm not worried about other readdir calls invalidating the page. My
> > concern is rather about the VM memory reclaimers ejecting the page from
> > the page cache, and calling nfs_readdir_clear_array while we're
> > referencing the page.
> 
> Wait, if nfs_readdir_clear_array can clear the page while
> somebody else has a refcount to it, what good is the
> refcount?

Hi Rik

This is readdir, so there should normally be only one process accessing
the page. If that process locks it (we don't have mmap() to worry about,
so page locking is reasonable here) then the scheme is safe.

Note that we do clear Pg_uptodate under the page lock in the latest
version of the releasepage method (patches to be published later today
after I finish testing).

> Why is your .releasepage modifying the data on the page,
> instead of just the metadata in the struct page?

We want to be able to free up the data that is referenced by the array
on the page before the page itself is freed. 

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

