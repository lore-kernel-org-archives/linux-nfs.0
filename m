Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922AbZDIW1s convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2009 18:27:48 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS fscache offline mode?
Date: Thu, 9 Apr 2009 15:27:16 -0700
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC02931627@SACMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <11770.1239312107@redhat.com>
References: <7A24DF798E223B4C9864E8F92E8C93EC029314E5@SACMVEXC1-PRD.hq.netapp.com> <49dd5b8c.85c2f10a.5f05.1c22@mx.google.com> <1253.1239275671@redhat.com> <11770.1239312107@redhat.com>
From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
To: "David Howells" <dhowells@redhat.com>
Cc: "Tom Talpey" <tmtalpey@gmail.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 

> -----Original Message-----
> From: David Howells [mailto:dhowells@redhat.com] 
> Sent: Thursday, April 09, 2009 2:22 PM
> To: Muntz, Daniel
> Cc: dhowells@redhat.com; Tom Talpey; linux-nfs@vger.kernel.org
> Subject: Re: NFS fscache offline mode?
> 
> Muntz, Daniel <Dan.Muntz@netapp.com> wrote:
> 
> > It's not _so_ tricky for the read-only case, and is quite 
> useful (see 
> > papers by Huston+Honeyman re: disconnected AFS).  For writes, my 
> > recollection is that you pretty much need human intervention to 
> > resolve conflicts unless a trivial resolution mechanism is defined.
> 
> Oh, I agree that's it's much simpler for read-only, and that 
> there's no trickiness for files that haven't been modified 
> locally whilst offline; but if any have, it could then be a problem.
> 
> The simplest way is to simply discard local changes upon 
> reconnection if the backing file has changed.  Isn't that 
> what we do anyway when in connected mode.

The two trivial cases are: discard changes from disconnected mode, or
propagate all changes when reconnected.  Doing something more
intelligent is difficult.  If writes are allowed, you still run the risk
of evicting something you really wanted in the cache (oops, forgot to
pin my .bashrc), or getting unexpected disk-full errors.  But, you still
have something potentially useful if you just make the cache ro when
disconnected.

> > > In any case, offline mode isn't something that FS-Cache 
> itself cares 
> > > about.  It is purely a data store.  The network 
> filesystems using it 
> > > must implement offline mode.
> > 
> > That's a bit flippant.  You could just as well say that the 
> "network" 
> > file system should implement its own disk cache.  If you're 
> going to 
> > cache under the fs, you could also do a lot to hide the 
> disconnected 
> > status from the fs, once again, not too bad if you're doing 
> read-only.
> 
> I disagree.  FS-Cache provides or will provide the local 
> storage required to perform offline operation, the ability to 
> pin data within that storage, and the ability to tag the 
> stored data with the metadata required; but in my opinion, 
> the netfs, be it NFS, AFS or CIFS, must do the actual work of:
> 
>  (1) configuring what must be available for disconnected operation,

You've captured the data and metadata.  I suppose there might be some
fs-specific hooks needed (e.g., something needed to prevent the nfs
client from thinking the server is down).  IMHO, it would be really
handy if a canonical list of such hooks could be made, and FS-Cache
could handle these similar to how export ops work in NFS--the fs
supplies routines that FS-Cache calls to make disconnected operation
work.

> 
>  (2) pulling files into the cache in preparation,

Some trivial fs-agnostic ways to do this: use the system before
disconnecting, or run a process to walk through the fs catting files
that you want in disconnected mode (pulling them into the cache).  Just
out of curiosity, could one 'tar' up the cache on one machine and drop
it on another and have it work?  There must be enough state on disk so
that a reboot doesn't invalidate your cache, so I'm guessing this might
be another way to warm your cache.

>
 
>  (3) handling requests from userspace that can't be satisfied 
> when offline,

What did you have in mind?

>      and
> 
>  (4) resolving conflicts afterwards.

If you stick to the ro case, or the two simple conflict resolution
schemes, then this is not an issue.

> 
> The netfs knows about the structure of the filesystem; 
> fscache does not.  The user interacts with the netfs, not 
> directly with fscache.
> 
> > BTW: could we not use the term "network" file system when 
> discussing 
> > FS-Cache?  You've also mentioned using it for iso9660, so it's not 
> > just for network file systems.
> 
> All my documents, code and emails are laced with the term 
> 'netfs' to mean a client of FS-Cache.

That's what 'sed' is for :-)

> 
> As I have pointed out in my documentation, whilst iso9660 
> isn't a network filesystem, it can be considered in the same 
> group for this topic.
> 
> David
> 
