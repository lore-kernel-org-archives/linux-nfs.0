Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41630 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750794AbcL2Uy2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Dec 2016 15:54:28 -0500
Date: Thu, 29 Dec 2016 15:54:26 -0500
From: Bruce James Fields <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] RFC 7530: Filehandle of opened file after the REMOVE
Message-ID: <20161229205426.GA389@fieldses.org>
References: <CAABAsM5L0xdKodxk1dRSugLyROzn2JzgDkq6kdHE0LuGcfh++A@mail.gmail.com>
 <20161213181734.Horde.EqgB09El8rupnkesIQaBwJ3@mail.telka.sk>
 <CADaq8jcq2C0o8EWXoGjxDn58sV_J+-SP-=rj934Se-DV69b-pw@mail.gmail.com>
 <20161214112112.Horde.aPh8AjT6iWRl37CULwihyV7@mail.telka.sk>
 <CAABAsM7v6y0bsb0jKzfvobkUjniTLhM3uv8FYjo07HcLD2004w@mail.gmail.com>
 <20161227144414.GA32002@fieldses.org>
 <CADaq8jck14SKL6Ua9QxbqPyX1=1aaA7+76wv-__EWFvh7ZcEJA@mail.gmail.com>
 <C496AE44-0F27-4B66-A1F6-A76AEAFD7A90@gmail.com>
 <20161229024703.GA21325@fieldses.org>
 <20161229074830.GA3002@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161229074830.GA3002@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 29, 2016 at 08:48:30AM +0100, Christoph Hellwig wrote:
> On Wed, Dec 28, 2016 at 09:47:03PM -0500, Bruce James Fields wrote:
> > I never seriously worked on it, but for a while I was in the habit of
> > running it by people.  Christoph Hellwig thought it was doable (I think
> > he suggested some sort of callback from the filesystem during the
> > garbage collection, possibly because he had in mind some other
> > application for that--but my memory may be wrong).  Chris Mason didn't
> > like the idea at all.  He asked what we expect to happen on fsck, or if
> > the filesystem gets mounted without nfs getting started, or... some
> > other scenarios I forget.
> 
> The way open but unlinked files are handled by modern transaction
> file systems is that the file system has a list of those inodes
> (in XFS this is the unlinked inode list in the allocation group header,
> other file systems use different terminologies and slightly different
> technics, e.g. in ext4 the list is global for the whole file system).
> 
> After an unclean shutdown when file system recovery is run we'll perform
> the deferred delete for all the inodes on the unlinked inode list.
> At that point the file system could in theory inform NFSD about that
> fact.  But at least as far as the current Linux kernel is concerned (
> sorry for delving into implementation details, but I guess this is still
> easier to understand than an abstract discussion) at the point where
> file system performs recovery NFSD has not been started, or at least doesn't
> know about the file system yet.   We could still persist that information
> somewhere, or use a flag to delay the deletion of unlinked inodes until
> NFSD runs.

Veering even further into implementation details (and changing cc: to
linux-nfs instead of nfsv4@ietf, hope that's OK):

I assume this would need userspace updates too, so fsck would know not
to free the unlinked files, and so administrators could see what was
going on and maybe free them manually if need be.

It may seem like overkill, but we have (mostly complete) support for
running multiple nfsd's in containers, which can be started and stopped
independently.  And we may want to allow a single filesystem to be
exported by more than one such nfsd. I think we can still manage that
with a single unlinked inode list, though--we'd just need logic in nfsd
to delay freeing as long as any nfsd is restarting.

--b.

> > We could do the same silly rename tricks on the server side.  Something
> > like: create a directory with an unlikely name in the root of the
> > export, rename files there on REMOVE.  Possible problems:
> 
> Personally I'd love to see sillyrename die.  It's a major pain for
> getting sensible semantics out of NFS.
> 
> > 	- you'll never be able to completely hide that directory.  But
> > 	  maybe we could get some sort of filesystem support for a
> > 	  hidden directory.
> 
> 
> The unlinked inode list is almost a directory, except that it doesn't
> have names for the entries, you can only find inodes on it by the inode
> number and generation (aka NFS file handle).
