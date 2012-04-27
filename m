Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f51.google.com ([209.85.210.51]:53141 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761186Ab2D0Sn5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 14:43:57 -0400
Received: by dadz8 with SMTP id z8so1352952dad.10
        for <linux-nfs@vger.kernel.org>; Fri, 27 Apr 2012 11:43:57 -0700 (PDT)
Subject: Re: [PATCH 0/6] Extended file stat system call
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@whamcloud.com>
In-Reply-To: <20120427010610.GE9541@dastard>
Date: Thu, 26 Apr 2012 21:22:04 -0600
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Message-Id: <ED5B8F1B-6C99-4516-85FA-A767E94B635F@dilger.ca>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <20120427010610.GE9541@dastard>
To: Dave Chinner <david@fromorbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-26, at 7:06 PM, Dave Chinner wrote:
> On Thu, Apr 19, 2012 at 03:05:58PM +0100, David Howells wrote:
>> 
>> Implement a pair of new system calls to provide extended and further extensible stat functions.
>> 
>> The second of the associated patches is the main patch that provides these new system calls:
>> 
>> 	ssize_t ret = xstat(int dfd,
>> 			    const char *filename,
>> 			    unsigned atflag,
>> 			    unsigned mask,
>> 			    struct xstat *buffer);
>> 
>> 	ssize_t ret = fxstat(int fd,
>> 			     unsigned atflag,
>> 			     unsigned mask,
>> 			     struct xstat *buffer);
>> 
>> which are more fully documented in the first patch's description.
>> 
>> These new stat functions provide a number of useful features, in summary:
>> 
>> (1) More information: creation time, inode generation number, data
>>     version number, flags/attributes.  A subset of these is available
>>     through a number of filesystems (CIFS, NFS, AFS, Ext4 and BTRFS).
> 
> If we are adding per-inode flags, then what do we do with filesystem
> specific flags? e.g. XFS has quite a number of per-inode flags that
> don't align with any other filesystem (e.g. filestream allocator,
> real time file, behaviour inheritence flags, etc), but may be useful
> to retrieve in such a call. We currently have an ioctl to get that
> information from each inode. Have you thought about how to handle
> such flags?

I'm sympathetic to your cause, but I don't want this to degrade into
the same morass that it did last time when every attribute under the
sun was added to the call.  The intent is to replace the stat() call
with something that can avoid overhead on filesystems for which some
attributes are expensive, and that applications may not need.  Some
common attributes were added that are used by multiple filesystems.

If it is too filesystem-specific, and there is little possibility
that these attributes will be usable on other filesystems, then it
should remain a filesystem specific ioctl() call.  If you can make
a case that these attributes have value on a few other filesystems,
and applications are reasonably likely to be able to use them, and
their addition does not make the API overly complex, then suggest
away.

> Along the same lines, filesytsems can have different allocation
> constraints to IO the filesystem block size - ext4 with it's
> bigalloc hack, XFS with it's per-inode extent size hints and the
> realtime device, etc. Then there's optimal IO characteristics
> (e.g. geometery hints like stripe unit/stripe width for the
> allocation policy of that given file) that applications could use
> if they were present rather than having to expose them through
> ioctls that nobody even knows about...

There is already "optimal IO size" that the application can use,
how do the geometry hints differ?  Userspace is able to handle
st_blksize of several MB in size without problems, and any sane
application will do the IO sized + aligned on multiples of this.

> Perhaps also exposing the project ID for quota purposes, like we do
> UID and GID. That way we wouldn't need a filesystem specific ioctl
> to read it....

This seems reasonable and generic and simple.  This is similar to
directory quotas in other filesystems.


Cheers, Andreas





