Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:1105 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757114Ab2D0NNL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 09:13:11 -0400
Date: Fri, 27 Apr 2012 23:13:06 +1000
From: Dave Chinner <david@fromorbit.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Message-ID: <20120427131306.GG9541@dastard>
References: <20120427010610.GE9541@dastard>
 <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <4111.1335519545@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4111.1335519545@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 10:39:05AM +0100, David Howells wrote:
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > If we are adding per-inode flags, then what do we do with filesystem specific
> > flags? e.g. XFS has quite a number of per-inode flags that don't align with
> > any other filesystem (e.g. filestream allocator, real time file, behaviour
> > inheritence flags, etc), but may be useful to retrieve in such a call. We
> > currently have an ioctl to get that information from each inode. Have you
> > thought about how to handle such flags?
> 
> I haven't looked at XFS with regard to xstat as yet, so I'm not sure exactly
> which flags you're talking about.  The question, though, is what will actually
> make use of these flags?  Will it just be XFS tools or are they something that
> a GUI might make use of?

Have a look at fs/xfs/xfs_dinode.h. There's a bunch of flags defined
at the bottom of the file.

Stuff like the "nodefrag", "nodump", and "prealloc" bits seem fairly
generic - they are for indicating that files are to be avoided for defrag or
backup purposes, the prealloc bit indicates that fallocate has been
used to reserve space on the inode (finding files that space can be
punched out of safely), and so on.

Currently these things are queried and manipulated by ioctls
(XFS_IOC_FSX[GS]ETATTR) along with extent size hints, project
quotas, etc. but I think there's some wider use for many of the
flags, which is why I was asking is there's any thought to this sort
of flag being exposed by the VFS.

Historically the flags exposed by the VFS are those used by extN - I
see little reason why we should favour one filesystem's flags over
any others in an extended stat interface if they are generically
useful....

> Either you can add some of them to the ioc flags (which may be impractical, I
> grant you) or we'd have to add an arbitrary fs-type specific field and specify
> the host fs (the provision of which might not be a bad idea in and of itself)
> to tell userspace how to interpret them.

Well, that's the complexity, isn't it. I have no good answer to
that...

> > Along the same lines, filesytsems can have different allocation constraints
> > to IO the filesystem block size - ext4 with it's bigalloc hack, XFS with it's
> > per-inode extent size hints and the realtime device, etc. Then there's
> > optimal IO characteristics (e.g. geometery hints like stripe unit/stripe
> > width for the allocation policy of that given file) that applications could
> > use if they were present rather than having to expose them through ioctls
> > that nobody even knows about...
> 
> Yeah...  Not representable by one number.  You'd have to unset a flag to say
> you were providing this information.
> 
> However, providing a whole bunch of hints about I/O characteristics is probably
> beyond this syscall - especially if it isn't constant over the length of a
> file.  That's specialist knowledge that most applications don't need to know.
> Having a generic way to retrieve it, though, may be a good idea.

We're continually talking about applications giving us usage hints
on what IO they are going to do so the storage can optimise the IO.
IO is still a GIGO problem, though, and the idea of geometry hints is to enable
us to tell the application to do well formed IO. i.e. less garbage.

XFS has ioctls to expose filesystem geometry, optimal IO sizes, the
alignment limits for direct IO, etc, and they are very useful to
applications that care about high performance IO. A lot of this can
be distilled down to a simple set of geometries, and generally
speaking they don't change mid way through a file....

> OTOH, there's plenty of uncommitted space, so if we can condense the hints down
> to something small, we could perhaps add it later - but from your paragraph
> above, it doesn't sound like it'll be small.

Allocation block size, minimum sane IO size (to avoid page cache RMW
cycles or DIO zeroing), minimum prefered IO size (e.g. stripe unit),
optimal IO size for bandwidth (e.g. stripe width). I don't think
there's much more than that which will be really usable by
applications.

> > Perhaps also exposing the project ID for quota purposes, like we do UID and
> > GID. That way we wouldn't need a filesystem specific ioctl to read it....
> 
> Is this an XFS only thing?  If so, can it be generalised?

Right now it is, but there's ben patches in the past to introduce
project quotas to ext4. That didn't go far because it was done in a
way that was semantically different to XFS (for no reason that I
could understand) and nobody wanted two different sets of semantics
for the "same" feature.  The most common use of project quotas is to
implement sub-tree quotas, which is probably of more interest to
btrfs folks as it is an exact match for per-subvolume quotas.

So, yes, I do see it as something generically useful - it's a
feature that a lot of people use XFS specifically for....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
