Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51187 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756799AbZDIXFW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Apr 2009 19:05:22 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC02931627@SACMVEXC1-PRD.hq.netapp.com>
References: <7A24DF798E223B4C9864E8F92E8C93EC02931627@SACMVEXC1-PRD.hq.netapp.com> <7A24DF798E223B4C9864E8F92E8C93EC029314E5@SACMVEXC1-PRD.hq.netapp.com> <49dd5b8c.85c2f10a.5f05.1c22@mx.google.com> <1253.1239275671@redhat.com> <11770.1239312107@redhat.com>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Cc: dhowells@redhat.com, "Tom Talpey" <tmtalpey@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS fscache offline mode?
Date: Fri, 10 Apr 2009 00:05:00 +0100
Message-ID: <12825.1239318300@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Muntz, Daniel <Dan.Muntz@netapp.com> wrote:

> >  (1) configuring what must be available for disconnected operation,
> 
> You've captured the data and metadata.  I suppose there might be some
> fs-specific hooks needed (e.g., something needed to prevent the nfs
> client from thinking the server is down).  IMHO, it would be really
> handy if a canonical list of such hooks could be made, and FS-Cache
> could handle these similar to how export ops work in NFS--the fs
> supplies routines that FS-Cache calls to make disconnected operation
> work.

No, disconnected operation is a netfs thing, not an FS-Cache thing, I think.
Take NFS for example: it must know that it is in disconnected mode; it can't
fling GETATTR requests at the server to determine whether a file is valid; it
can't ask for a lease on that file; it must rely on FS-Cache to have the data
and metadata it requires to make files and directories available.

Similarly, for AFS, it can't go to the server to validate the vnodes it has
stored, and it can't request callbacks on the files it opens.  In fact both
filesystems probably should return their leases/callbacks when entering
disconnected mode.

FS-Cache doesn't do anything but store metadata and data NFS gets from the
server as it arrives, and retrieve or invalidate that data and metadata when
asked by NFS.

For the most part, NFS and AFS operate the following path in any request:

	if (in_fscache(data_or_metadata)) {
		retrieve_from_fscache(data_or_metadata);
	} else {
		get_from_server(data_or_metadata);
		store_to_fscache(data_or_metadata);
	}

But with the advent of disconnected mode, that becomes:

	if (in_fscache(data_or_metadata)) {
		retrieve_from_fscache(data_or_metadata);
	} else if (in_disconnected_mode) {
		return -EDISCONNECTED;
	} else {
		get_from_server(data_or_metadata);
		store_to_fscache(data_or_metadata);
	}

If FS-Cache doesn't have a file, directory, page or dirent stored, then the
netfs returns EDISCONNECTED or whatever for that item.

> >  (2) pulling files into the cache in preparation,
> 
> Some trivial fs-agnostic ways to do this: use the system before
> disconnecting, or run a process to walk through the fs catting files
> that you want in disconnected mode (pulling them into the cache).

Yeah, a userspace solution would be simplest here:

	[/usr/sbin/use-in-disconnected-mode]
	#!/bin/sh
	tar cf - $* >/dev/zero

However, we'd want to pin all those files, so using tar isn't necessarily the
best.  Pinning could be achieved by opening each file, emitting an fadvise()
or ioctl() to say that this should be pinned, and then reading the first byte
of each page in the file.

> Just out of curiosity, could one 'tar' up the cache on one machine and drop
> it on another and have it work?  There must be enough state on disk so that
> a reboot doesn't invalidate your cache, so I'm guessing this might be
> another way to warm your cache.

Perhaps.  You'd have to supply --xattr to tar, but you could do it.

> >  (3) handling requests from userspace that can't be satisfied 
> > when offline,
> 
> What did you have in mind?

Someone tries to access a file that isn't in the cache, say.  FS-Cache says
'no I haven't got that' and then the netfs needs to do something with it -
even if that's just returning FS-Cache's error (-ENODATA) to the caller.

> >      and
> > 
> >  (4) resolving conflicts afterwards.
> 
> If you stick to the ro case, or the two simple conflict resolution
> schemes, then this is not an issue.

Mostly true.  But it's still dealt with by the netfs.

For the discard-on-conflict option, with NFS and AFS it'd be a case of compare
an inode that's in core (if the inode is in use) or in the cache next time it
is accessed with what's on the server - as is done in connected operation.

For the writeback-on-conflict option, it's not a non-issue.  The netfs would
have to write back what's in the pagecache or in FS-Cache, and that's
something we don't do now.

David
