Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35420 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbcD3VFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 17:05:53 -0400
Received: by mail-qk0-f178.google.com with SMTP id q76so52644524qke.2
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 14:05:53 -0700 (PDT)
Message-ID: <1462050349.10011.52.camel@poochiereds.net>
Subject: Re: [RFC][PATCH 0/6] Enhanced file stat system call
From: Jeff Layton <jlayton@poochiereds.net>
To: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Date: Sat, 30 Apr 2016 17:05:49 -0400
In-Reply-To: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-04-29 at 13:57 +0100, David Howells wrote:
> Implement a new system call to provide enhanced file stats.  The patches can
> be found here:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=xstat
> 
> 
> ===========
> DESCRIPTION
> ===========
> 
> The first patch provides this new system call:
> 
> 	long ret = statx(int dfd,
> 			 const char *filename,
> 			 unsigned atflag,
> 			 unsigned mask,
> 			 struct statx *buffer);
> 
> This is an enhanced file stat function that provides a number of useful
> features, in summary:
> 
>  (1) More information: creation time, data version number, inode generation
>      number and flags.  A subset of these is available through a number of
>      filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).
> 
>  (2) Lightweight stat (AT_NO_ATTR_SYNC): Ask for just those details of
>      interest, and allow a network fs to approximate anything not of
>      interest, without going to the server.
> 
>  (3) Heavyweight stat (AT_FORCE_ATTR_SYNC): Force a network fs to flush
>      buffers and go to the server, even if it thinks its cached attributes
>      are up to date.
> 
>  (4) Allow the filesystem to indicate what it can/cannot provide: A
>      filesystem can now say it doesn't support a standard stat feature if
>      that isn't available.
> 
>  (5) Make the fields a consistent size on all arches, and make them large.
> 
>  (6) Can be extended by using more request flags and using up the padding
>      space in the statx struct.
> 
> Note that no lstat() equivalent is required as that can be implemented
> through statx() with atflag == 0.  There is also no fstat() equivalent as
> that can be implemented through statx() with filename == NULL and the
> relevant fd passed as dfd.
> 
> 
> =======
> TESTING
> =======
> 
> A test program is added into samples/statx/ by the first patch.
> 
> David
> ---
> David Howells (6):
>       statx: Add a system call to make enhanced file info available
>       statx: AFS: Return enhanced file attributes
>       statx: Ext4: Return enhanced file attributes
>       statx: NFS: Return enhanced file attributes
>       statx: Make windows attributes available for CIFS, NTFS and FAT to use
>       statx: CIFS: Return enhanced attributes
> 
> 
>  arch/x86/entry/syscalls/syscall_32.tbl |    1 
>  arch/x86/entry/syscalls/syscall_64.tbl |    1 
>  fs/afs/inode.c                         |   24 ++-
>  fs/cifs/cifsfs.h                       |    4 
>  fs/cifs/cifsglob.h                     |    8 +
>  fs/cifs/dir.c                          |    2 
>  fs/cifs/inode.c                        |  117 +++++++++---
>  fs/exportfs/expfs.c                    |    4 
>  fs/ext4/ext4.h                         |    2 
>  fs/ext4/file.c                         |    2 
>  fs/ext4/inode.c                        |   30 +++
>  fs/ext4/namei.c                        |    2 
>  fs/ext4/symlink.c                      |    2 
>  fs/nfs/inode.c                         |   41 ++++
>  fs/stat.c                              |  306 +++++++++++++++++++++++++++++---
>  include/linux/fs.h                     |    5 -
>  include/linux/stat.h                   |   15 +-
>  include/linux/syscalls.h               |    4 
>  include/uapi/linux/fcntl.h             |    2 
>  include/uapi/linux/stat.h              |  135 ++++++++++++++
>  samples/Makefile                       |    2 
>  samples/statx/Makefile                 |   10 +
>  samples/statx/test-statx.c             |  274 +++++++++++++++++++++++++++++
>  23 files changed, 910 insertions(+), 83 deletions(-)
>  create mode 100644 samples/statx/Makefile
>  create mode 100644 samples/statx/test-statx.c
> 


I looked over the patchset and it looks fairly straightforward to me.

Are there things that I'd have probably done differently? Yes, but
nothing really sticks out to me as show-stopping and this has the
potential to be helpful in all sorts of ways.

I think we really ought to resist excessive bikeshedding this time
around. With the way the interface is designed, we should be able to
expand on it later if we want to add new attributes after the interface
itself is merged.

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
