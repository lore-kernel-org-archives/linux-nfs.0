Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm18-vm0.bullet.mail.bf1.yahoo.com ([98.139.213.138]:39650 "EHLO
	nm18-vm0.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1163157AbbKTQ46 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2015 11:56:58 -0500
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
To: David Howells <dhowells@redhat.com>, arnd@arndb.de
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <564F4F4E.8060603@schaufler-ca.com>
Date: Fri, 20 Nov 2015 08:50:22 -0800
MIME-Version: 1.0
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/20/2015 6:54 AM, David Howells wrote:
> Implement new system calls to provide enhanced file stats and enhanced
> filesystem stats.  The patches can be found here:
>
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=xstat
>
>
> ===========
> DESCRIPTION
> ===========
>
> The third patch provides this new system call:
>
> 	long ret = statx(int dfd,
> 			 const char *filename,
> 			 unsigned atflag,
> 			 unsigned mask,
> 			 struct statx *buffer);
>
> This is an enhanced file stat function that provides a number of useful
> features, in summary:
>
>   (1) More information: creation time, data version number,
>       flags/attributes.  A subset of these is available through a number of
>       filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).
>
>   (2) Lightweight stat (AT_NO_ATTR_SYNC): Ask for just those details of
>       interest, and allow a network fs to approximate anything not of
>       interest, without going to the server.
>
>   (3) Heavyweight stat (AT_FORCE_ATTR_SYNC): Force a network fs to flush
>       buffers and go to the server, even if it thinks its cached attributes
>       are up to date.
>
>   (4) Allow the filesystem to indicate what it can/cannot provide: A
>       filesystem can now say it doesn't support a standard stat feature if
>       that isn't available.
>
>   (5) Make the fields a consistent size on all arches, and make them large.
>
>   (6) Can be extended by using more request flags and using up the padding
>       space in the statx struct.

How about relevant xattrs? SELinux context, ACL, that sort of thing.
The fact that these are optional should be taken care of by (4).

>
> Note that no lstat() equivalent is required as that can be implemented
> through statx() with atflag == 0.  There is also no fstat() equivalent as
> that can be implemented through statx() with filename == NULL and the
> relevant fd passed as dfd.
>
>
> The seventh patch provides another new system call:
>
> 	long ret = fsinfo(int dfd,
> 			  const char *filename,
> 			  unsigned atflag,
> 			  unsigned request,
> 			  void *buffer);
>
> This is an enhanced filesystem stat and information retrieval function that
> provides more information, in summary:
>
>   (1) All the information provided by statfs() and more.  The fields are
>       made large.
>
>   (2) Provides information about timestamp range and resolution to
>       complement statx().
>
>   (3) Provides information about IOC flags supported in statx()'s return.
>
>   (4) Provides volume binary IDs and UUIDs.
>
>   (5) Provides the filesystem name according to the kernel as a string
>       (eg. "ext4" or "nfs3") in addition to the magic number.
>
>   (6) Provides information obtained from network filesystems, such as volume
>       and domain names.
>
>   (7) Has lots of spare space that can be used for future extenstions and a
>       bit mask indicating what was provided.
>
> Note that I've added a 'request' identifier.  This is to select the set of
> data to be returned.  The idea is that 'buffer' points to a fixed-size
> struct selected by request.  Currently only 0 is available and this refers
> to 'struct fsinfo'.  However, I could split up the buffer into say 3:
>
>   (0) statfs-type information
>
>   (1) Timestamp and IOC flags info.
>
>   (2) Network fs strings.
>
> However, some of this might be better retrieved through getxattr().
>
>
> =======
> TESTING
> =======
>
> Test programs are added into samples/statx/ by the appropriate patches.
>
> David
> ---
> David Howells (12):
>        Ext4: Fix extended timestamp encoding and decoding
>        statx: Provide IOC flags for Windows fs attributes
>        statx: Add a system call to make enhanced file info available
>        statx: AFS: Return enhanced file attributes
>        statx: Ext4: Return enhanced file attributes
>        statx: NFS: Return enhanced file attributes
>        statx: CIFS: Return enhanced attributes
>        fsinfo: Add a system call to make enhanced filesystem info available
>        fsinfo: Ext4: Return information through the filesystem info syscall
>        fsinfo: AFS: Return information through the filesystem info syscall
>        fsinfo: NFS: Return information through the filesystem info syscall
>        fsinfo: CIFS: Return information through the filesystem info syscall
>
>
>   arch/x86/entry/syscalls/syscall_32.tbl |    2
>   arch/x86/entry/syscalls/syscall_64.tbl |    2
>   fs/afs/inode.c                         |   23 ++
>   fs/afs/super.c                         |   39 ++++
>   fs/cifs/cifsfs.c                       |   25 +++
>   fs/cifs/cifsfs.h                       |    4
>   fs/cifs/cifsglob.h                     |    8 +
>   fs/cifs/dir.c                          |    2
>   fs/cifs/inode.c                        |  124 ++++++++++---
>   fs/cifs/netmisc.c                      |    4
>   fs/exportfs/expfs.c                    |    4
>   fs/ext4/ext4.h                         |   24 ++-
>   fs/ext4/file.c                         |    2
>   fs/ext4/inode.c                        |   31 +++
>   fs/ext4/namei.c                        |    2
>   fs/ext4/super.c                        |   39 ++++
>   fs/ext4/symlink.c                      |    2
>   fs/nfs/inode.c                         |   45 ++++-
>   fs/nfs/internal.h                      |    1
>   fs/nfs/nfs4super.c                     |    1
>   fs/nfs/super.c                         |   58 ++++++
>   fs/ntfs/time.h                         |    2
>   fs/stat.c                              |  305 +++++++++++++++++++++++++++++---
>   fs/statfs.c                            |  218 +++++++++++++++++++++++
>   include/linux/fs.h                     |    7 +
>   include/linux/stat.h                   |   14 +
>   include/linux/syscalls.h               |    6 +
>   include/linux/time64.h                 |    2
>   include/uapi/linux/fcntl.h             |    2
>   include/uapi/linux/fs.h                |    7 +
>   include/uapi/linux/stat.h              |  185 +++++++++++++++++++
>   samples/Makefile                       |    3
>   samples/statx/Makefile                 |   13 +
>   samples/statx/test-fsinfo.c            |  179 +++++++++++++++++++
>   samples/statx/test-statx.c             |  273 +++++++++++++++++++++++++++++
>   35 files changed, 1558 insertions(+), 100 deletions(-)
>   create mode 100644 samples/statx/Makefile
>   create mode 100644 samples/statx/test-fsinfo.c
>   create mode 100644 samples/statx/test-statx.c
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

