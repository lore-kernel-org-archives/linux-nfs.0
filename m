Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58682 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755571AbZDIVVv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Apr 2009 17:21:51 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC029314E5@SACMVEXC1-PRD.hq.netapp.com>
References: <7A24DF798E223B4C9864E8F92E8C93EC029314E5@SACMVEXC1-PRD.hq.netapp.com> <49dd5b8c.85c2f10a.5f05.1c22@mx.google.com> <1253.1239275671@redhat.com>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Cc: dhowells@redhat.com, "Tom Talpey" <tmtalpey@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS fscache offline mode?
Date: Thu, 09 Apr 2009 22:21:47 +0100
Message-ID: <11770.1239312107@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Muntz, Daniel <Dan.Muntz@netapp.com> wrote:

> It's not _so_ tricky for the read-only case, and is quite useful (see
> papers by Huston+Honeyman re: disconnected AFS).  For writes, my
> recollection is that you pretty much need human intervention to resolve
> conflicts unless a trivial resolution mechanism is defined.

Oh, I agree that's it's much simpler for read-only, and that there's no
trickiness for files that haven't been modified locally whilst offline; but if
any have, it could then be a problem.

The simplest way is to simply discard local changes upon reconnection if the
backing file has changed.  Isn't that what we do anyway when in connected
mode.

> > In any case, offline mode isn't something that FS-Cache itself cares
> > about.  It is purely a data store.  The network filesystems using it must
> > implement offline mode.
> 
> That's a bit flippant.  You could just as well say that the "network" file
> system should implement its own disk cache.  If you're going to cache under
> the fs, you could also do a lot to hide the disconnected status from the fs,
> once again, not too bad if you're doing read-only.

I disagree.  FS-Cache provides or will provide the local storage required to
perform offline operation, the ability to pin data within that storage, and
the ability to tag the stored data with the metadata required; but in my
opinion, the netfs, be it NFS, AFS or CIFS, must do the actual work of:

 (1) configuring what must be available for disconnected operation,

 (2) pulling files into the cache in preparation,

 (3) handling requests from userspace that can't be satisfied when offline,
     and

 (4) resolving conflicts afterwards.

The netfs knows about the structure of the filesystem; fscache does not.  The
user interacts with the netfs, not directly with fscache.

> BTW: could we not use the term "network" file system when discussing
> FS-Cache?  You've also mentioned using it for iso9660, so it's not just
> for network file systems.

All my documents, code and emails are laced with the term 'netfs' to mean a
client of FS-Cache.

As I have pointed out in my documentation, whilst iso9660 isn't a network
filesystem, it can be considered in the same group for this topic.

David
