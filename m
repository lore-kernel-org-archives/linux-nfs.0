Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48994 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab2DSOGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 10:06:33 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 0/6] Extended file stat system call
To: linux-fsdevel@vger.kernel.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Date: Thu, 19 Apr 2012 15:05:58 +0100
Message-ID: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Implement a pair of new system calls to provide extended and further extensible
stat functions.

The second of the associated patches is the main patch that provides these new
system calls:

	ssize_t ret = xstat(int dfd,
			    const char *filename,
			    unsigned atflag,
			    unsigned mask,
			    struct xstat *buffer);

	ssize_t ret = fxstat(int fd,
			     unsigned atflag,
			     unsigned mask,
			     struct xstat *buffer);

which are more fully documented in the first patch's description.

These new stat functions provide a number of useful features, in summary:

 (1) More information: creation time, inode generation number, data version
     number, flags/attributes.  A subset of these is available through a number
     of filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).

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
xstat() with atflag == 0.


=======
PATCHES
=======

Patch 1 defines the xstat() and fxstat() system calls.

Patches 2-6 implement extended stat facilities for Ext4, AFS, NFS and CIFS, and
make eCryptFS go to the lower filesystem for such details.


==============
CONSIDERATIONS
==============

Should fxstat() be implemented as xstat() with a NULL filename, using dfd as
fd?

Should the default for a network fs be to do an unconditional (heavyweight)
stat with a flag to suppress going to the server to update the locally held
attributes and flushing pending writebacks?

Should things like the Windows Archive, Hidden and System bits be handled
through IOC flags, perhaps expanded to 64-bits?

Are these things useful to userspace other than Samba and userspace NFS
servers?

Is it useful to pass the volume ID out?  Or is statfs() sufficient for this?

Should I add a sixth argument to xstat(), mark it reserved and require that
must be supplied as 0 to hedge against future use?

Is there anything else I can usefully add at the moment?


==========
TO BE DONE
==========

Autofs, ntfs, btrfs, ...

I should perhaps use u8/u32/u64 rather than uint8/32/64_t.

Handle remote filesystems being offline and indicate this with
XSTAT_INFO_OFFLINE.


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
David Howells (6):
      xstat: eCryptFS: Return extended attributes
      xstat: CIFS: Return extended attributes
      xstat: NFS: Return extended attributes
      xstat: AFS: Return extended attributes
      xstat: Ext4: Return extended attributes
      xstat: Add a pair of system calls to make extended file stats available


 arch/x86/syscalls/syscall_32.tbl |    2 
 arch/x86/syscalls/syscall_64.tbl |    2 
 fs/afs/inode.c                   |   29 ++-
 fs/afs/super.c                   |    7 +
 fs/cifs/cifsfs.h                 |    4 
 fs/cifs/cifsglob.h               |   16 +-
 fs/cifs/dir.c                    |    2 
 fs/cifs/inode.c                  |  120 +++++++++++--
 fs/ecryptfs/inode.c              |   14 +-
 fs/ext4/ext4.h                   |    2 
 fs/ext4/file.c                   |    2 
 fs/ext4/inode.c                  |   32 +++
 fs/ext4/namei.c                  |    2 
 fs/ext4/super.c                  |    1 
 fs/ext4/symlink.c                |    2 
 fs/nfs/inode.c                   |   49 ++++-
 fs/nfs/super.c                   |    1 
 fs/stat.c                        |  350 +++++++++++++++++++++++++++++++++++---
 include/linux/fcntl.h            |    1 
 include/linux/fs.h               |    4 
 include/linux/stat.h             |  126 +++++++++++++-
 include/linux/syscalls.h         |    7 +
 22 files changed, 694 insertions(+), 81 deletions(-)

