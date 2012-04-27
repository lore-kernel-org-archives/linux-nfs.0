Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759915Ab2D0Jju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 05:39:50 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120427010610.GE9541@dastard>
References: <20120427010610.GE9541@dastard> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
To: Dave Chinner <david@fromorbit.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Fri, 27 Apr 2012 10:39:05 +0100
Message-ID: <4111.1335519545@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dave Chinner <david@fromorbit.com> wrote:

> If we are adding per-inode flags, then what do we do with filesystem specific
> flags? e.g. XFS has quite a number of per-inode flags that don't align with
> any other filesystem (e.g. filestream allocator, real time file, behaviour
> inheritence flags, etc), but may be useful to retrieve in such a call. We
> currently have an ioctl to get that information from each inode. Have you
> thought about how to handle such flags?

I haven't looked at XFS with regard to xstat as yet, so I'm not sure exactly
which flags you're talking about.  The question, though, is what will actually
make use of these flags?  Will it just be XFS tools or are they something that
a GUI might make use of?

Either you can add some of them to the ioc flags (which may be impractical, I
grant you) or we'd have to add an arbitrary fs-type specific field and specify
the host fs (the provision of which might not be a bad idea in and of itself)
to tell userspace how to interpret them.

> Along the same lines, filesytsems can have different allocation constraints
> to IO the filesystem block size - ext4 with it's bigalloc hack, XFS with it's
> per-inode extent size hints and the realtime device, etc. Then there's
> optimal IO characteristics (e.g. geometery hints like stripe unit/stripe
> width for the allocation policy of that given file) that applications could
> use if they were present rather than having to expose them through ioctls
> that nobody even knows about...

Yeah...  Not representable by one number.  You'd have to unset a flag to say
you were providing this information.

However, providing a whole bunch of hints about I/O characteristics is probably
beyond this syscall - especially if it isn't constant over the length of a
file.  That's specialist knowledge that most applications don't need to know.
Having a generic way to retrieve it, though, may be a good idea.

OTOH, there's plenty of uncommitted space, so if we can condense the hints down
to something small, we could perhaps add it later - but from your paragraph
above, it doesn't sound like it'll be small.

> Perhaps also exposing the project ID for quota purposes, like we do UID and
> GID. That way we wouldn't need a filesystem specific ioctl to read it....

Is this an XFS only thing?  If so, can it be generalised?

David
