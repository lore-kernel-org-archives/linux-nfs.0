Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:15381 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753970Ab2D0BGO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 21:06:14 -0400
Date: Fri, 27 Apr 2012 11:06:10 +1000
From: Dave Chinner <david@fromorbit.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Message-ID: <20120427010610.GE9541@dastard>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 19, 2012 at 03:05:58PM +0100, David Howells wrote:
> 
> Implement a pair of new system calls to provide extended and further extensible
> stat functions.
> 
> The second of the associated patches is the main patch that provides these new
> system calls:
> 
> 	ssize_t ret = xstat(int dfd,
> 			    const char *filename,
> 			    unsigned atflag,
> 			    unsigned mask,
> 			    struct xstat *buffer);
> 
> 	ssize_t ret = fxstat(int fd,
> 			     unsigned atflag,
> 			     unsigned mask,
> 			     struct xstat *buffer);
> 
> which are more fully documented in the first patch's description.
> 
> These new stat functions provide a number of useful features, in summary:
> 
>  (1) More information: creation time, inode generation number, data version
>      number, flags/attributes.  A subset of these is available through a number
>      of filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).

If we are adding per-inode flags, then what do we do with filesystem
specific flags? e.g. XFS has quite a number of per-inode flags that
don't align with any other filesystem (e.g. filestream allocator,
real time file, behaviour inheritence flags, etc), but may be useful
to retrieve in such a call. We currently have an ioctl to get that
information from each inode. Have you thought about how to handle
such flags?

Along the same lines, filesytsems can have different allocation
constraints to IO the filesystem block size - ext4 with it's
bigalloc hack, XFS with it's per-inode extent size hints and the
realtime device, etc. Then there's optimal IO characteristics
(e.g. geometery hints like stripe unit/stripe width for the
allocation policy of that given file) that applications could use
if they were present rather than having to expose them through
ioctls that nobody even knows about...

Perhaps also exposing the project ID for quota purposes, like we do
UID and GID. That way we wouldn't need a filesystem specific ioctl
to read it....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
