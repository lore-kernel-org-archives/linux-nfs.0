Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755192Ab3KLSm5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 13:42:57 -0500
Subject: [PATCH 0/3] Extended file stat system call [ver #2]
To: viro@ZenIV.linux.org.uk
From: David Howells <dhowells@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        libc-alpha@sourceware.org, linux-api@vger.kernel.org,
        andreas.gruenbacher@gmail.com, samba-technical@lists.samba.org,
        linux-fsdevel@vger.kernel.org
Date: Tue, 12 Nov 2013 18:41:27 +0000
Message-ID: <20131112184127.2880.24025.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Implement a new system call to provide an extended and further extensible stat
function.

=======
CHANGES
=======

 (*) Added an optional auxiliary data buffer pointer argument to sys_statxat()
     and moved some of the stuff into it.

 (*) Discarded "has an ACL info flag" for now.

 (*) AFS doesn't need to set time granularity itself as the default is 1s
     anyway.


===========
DESCRIPTION
===========

The second of the associated patches is the main patch that provides this new
system call:

	long ret = statxat(int dfd,
			   const char *filename,
			   unsigned atflag,
			   unsigned mask,
			   struct statx *buffer,
			   struct statx_auxinfo *auxinfo);

which is more fully documented in the main patch's description.

This new stat function provides a number of useful features, in summary:

 (1) More information: creation time, data version number, flags/attributes.
     A subset of these is available through a number of filesystems (such as
     CIFS, NFS, AFS, Ext4 and BTRFS).

 (2) Lightweight stat: Ask for just those details of interest, and allow a
     netfs (such as NFS) to approximate anything not of interest, possibly
     without going to the server.

 (3) Heavyweight stat: Force a netfs to go to the server, even if it thinks its
     cached attributes are up to date.

 (4) Allow the filesystem to indicate what it can/cannot provide: A filesystem
     can now say it doesn't support a standard stat feature if that isn't
     available.

 (5) Make the fields a consistent size on all arches, and make them large.

 (6) Can be extended by using more request flags and appending further data
     after the end of the standard return data.

Note that no lstat() equivalent is required as that can be implemented through
statxat() with atflag == 0.  There is also no fstat() equivalent as that can be
implemented through statxat() with filename == NULL and the relevant fd passed
as dfd.


=======
PATCHES
=======

Patch 1 introduces IOC flags for Windows Hidden, Archive and System attributes.

Patch 2 defines the statxat() system call.

Patch 3 implements extended stat facilities for AFS.  Other fs patches to go
through their respective trees once the core is in.


==============
CONSIDERATIONS
==============

Should the default for a network fs be to do an unconditional (heavyweight)
stat with a flag to suppress going to the server to update the locally held
attributes and flushing pending writebacks?

Is it useful to pass the volume ID out?  Or should statfs() be used for this?

Is there anything else I can usefully add at the moment?


==========
TO BE DONE
==========

Autofs, ntfs, btrfs, ...

I should perhaps use u8/u32/u64 rather than uint8/32/64_t.

Handle remote filesystems being offline and indicate this with
STATX_INFO_OFFLINE.

Should a "light stat" be explicitly requested by its own AT_ flag?


=======
TESTING
=======

There's a test program attached to the description for the main patch.  It can
be run as follows:
[root@andromeda tmp]# ./xstat -R /mnt/foo

	xstat(/mnt/foo) = 0
	0000: 000081a40000ffef 0000000000000001 0000020000000000 0000100000080000
	0020: 0000000000000000 0000000600000008 000000004f88499a 0000000136fd9208
	0040: 000000004f88499a 0000000136fd9208 000000004f8849b9 0000000106daf187
	0060: 000000004f8849b9 0000000106daf187 000000000000000c 000000000000000f
	0080: 0000000000000008 00000000484ebbef 0000000000000025 5949ebd4711efd82
	00a0: d3250b5c15d5e380 0000000000000000 0000000000000000 0000000000000000
	00c0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
	00e0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
	results=ffef
	  Size: 15              Blocks: 8          IO Block: 4096    regular file
	Device: 08:06           Inode: 12          Links: 1    
	Access: (0644/-rw-r--r--)  Uid: 0   
	Gid: 0
	Access: 2012-04-13 16:43:22.922587656+0100
	Modify: 2012-04-13 16:43:53.115011975+0100
	Change: 2012-04-13 16:43:53.115011975+0100
	Create: 2012-04-13 16:43:22.922587656+0100
	Inode version: 484ebbefh
	Data version: 25h
	Inode flags: 00080000 (-------- ----e--- -------- --------)
	Information: 00000200 (-------- -------- ------a- --------)
	Volume ID: 82fd1e71d4eb4959-80e3d5155c0b25d3

David
---
David Howells (3):
      statxat: Provide IOC flags for Windows fs attributes
      statxat: Add a system call to make extended file stats available
      statxat: AFS: Return enhanced basic attributes


 arch/x86/ia32/sys_ia32.c         |    2 
 arch/x86/syscalls/syscall_32.tbl |    1 
 arch/x86/syscalls/syscall_64.tbl |    1 
 fs/afs/inode.c                   |   46 ++++-
 fs/ceph/inode.c                  |    2 
 fs/cifs/inode.c                  |    5 -
 fs/compat.c                      |    2 
 fs/nfsd/nfsxdr.c                 |    2 
 fs/stat.c                        |  348 ++++++++++++++++++++++++++++++++++++--
 include/linux/fs.h               |    3 
 include/linux/stat.h             |   16 ++
 include/linux/syscalls.h         |    6 +
 include/uapi/linux/fcntl.h       |    1 
 include/uapi/linux/fs.h          |    7 +
 include/uapi/linux/stat.h        |  164 ++++++++++++++++++
 15 files changed, 567 insertions(+), 39 deletions(-)

