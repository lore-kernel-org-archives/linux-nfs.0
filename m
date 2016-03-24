Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38538 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984AbcCXTLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2016 15:11:00 -0400
Date: Thu, 24 Mar 2016 15:10:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@primarydata.com>
Subject: Re: [GIT PULL] nfsd changes for 4.6
Message-ID: <20160324191059.GA23783@fieldses.org>
References: <20160324133551.GA21950@fieldses.org>
 <CAHQdGtQWNaTVVBA7VxRHh2jmxCVO_7pMHXt6JEQsLr0K9TThtg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQWNaTVVBA7VxRHh2jmxCVO_7pMHXt6JEQsLr0K9TThtg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 24, 2016 at 03:00:55PM -0400, Trond Myklebust wrote:
> On Thu, Mar 24, 2016 at 9:35 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Please pull nfsd changes for 4.6 from
> >
> >   git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.6
> >
> > ----------------------------------------------------------------
> > Various bugfixes, a RDMA update from Chuck Lever, and support for a new
> > pnfs layout type from Christoph Hellwig.  The new layout type is a
> > variant of the block layout which uses SCSI features to offer improved
> > fencing and device identification.
> >
> > (Also: note this pull request also includes the client side of SCSI
> > layout, with Trond's permission.)
> 
> Umm.... Did you forget to include those patches, Bruce?

Oh no, I forgot to update a branch before running my usual script so,
yes, that tag's a subset of what I meant to send.

Uh, I guess what I'll do is push an nfsd-4.6-1 tag with the rest.  Linus
can either pull both tags or just the new one and hopefully the result's
OK either way.  Just a couple minutes....

--b.
