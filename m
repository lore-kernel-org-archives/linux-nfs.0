Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45492 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407Ab0LAR6U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 12:58:20 -0500
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
In-Reply-To: <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
	 <20101201150428.GA2879@elliptictech.com>
	 <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 12:58:17 -0500
Message-ID: <1291226297.6609.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 08:17 -0800, Linus Torvalds wrote:
> On Wed, Dec 1, 2010 at 7:36 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > We need to ensure that the entries in the nfs_cache_array get cleared
> > when the page is removed from the page cache. To do so, we use the
> > releasepage address_space operation (which also requires us to set
> > the Pg_private flag).
> 
> So I really think that the whole "releasepage" use in NFS is simply
> overly complicated and was obviously too subtle.
> 
> The whole need for odd return values, for the page lock, and for the
> addition of clearing the up-to-date bit comes from the fact that this
> wasn't really what releasepage was designed for.
> 
> 'releasepage' was really designed for the filesystem having its own
> version of 'try_to_free_buffers()', which is just an optimistic "ok,
> we may be releasing this page, so try to get rid of any IO structures
> you have cached". It wasn't really a memory management thing.
> 
> And the thing is, it looks trivial to do the memory management
> approach by adding a new callback that gets called after the page is
> actually removed from the page cache. If we do that, then there are no
> races with any other users, since we remove things from the page cache
> atomically wrt page cache lookup. So the need for playing games with
> page locking and 'uptodate' simply goes away. As does the PG_private
> thing or the interaction with invalidatepage() etc.
> 
> So this is a TOTALLY UNTESTED trivial patch that just adds another
> callback. Does this work? I dunno. But I get the feeling that instead
> of having NFS work around the odd semantics that don't actually match
> what NFS wants, introducing a new callback with much simpler semantics
> would be simpler for everybody, and avoid the need for subtle code.
> 
> Hmm?
> 
>                    Linus

This works for me, and I can code up a patch that uses it if you like...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

