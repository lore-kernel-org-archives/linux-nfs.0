Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab3I0Ry0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Sep 2013 13:54:26 -0400
From: David Howells <dhowells@redhat.com>
To: Trond.Myklebust@netapp.com, steved@redhat.com
cc: dhowells@redhat.com, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: [GIT PULL] NFS/FS-Cache: Fix crash from accidentally starting caching whilst writing
Date: Fri, 27 Sep 2013 18:54:22 +0100
Message-ID: <32376.1380304462@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond,

Can you pull these commits to fix an issue with NFS whereby caching can be
enabled on a file that is open for writing by subsequently opening it for
reading.  This can be made to crash by opening it for writing again if you're
quick enough.

The gist of the patchset is that the cookie should be acquired at inode
creation only and subsequently enabled and disabled as appropriate (which
dispenses with the backing objects when they're not needed).

The extra synchronisation that NFS does can then be dispensed with as it is
thenceforth managed by FS-Cache.

Could you send these on to Linus?

This likely will need fixing also in CIFS and 9P also once the FS-Cache
changes are upstream.  AFS and Ceph are probably safe.

Thanks,
David
---
The following changes since commit 2457aaf73a97a97c8596ed3903bd09601976f3bc:

  Merge tag 'pm+acpi-3.12-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm (2013-09-20 15:17:14 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git fscache

for you to fetch changes up to f1fe29b4a02d0805aa7d0ff6b73410a9f9316d69:

  NFS: Use i_writecount to control whether to get an fscache cookie in nfs_open() (2013-09-27 18:40:25 +0100)

----------------------------------------------------------------
(from the branch description for fscache local branch)

clone of "master"
----------------------------------------------------------------
David Howells (3):
      FS-Cache: Add use/unuse/wake cookie wrappers
      FS-Cache: Provide the ability to enable/disable cookies
      NFS: Use i_writecount to control whether to get an fscache cookie in nfs_open()

 Documentation/filesystems/caching/netfs-api.txt |  73 +++++++--
 fs/9p/cache.c                                   |   6 +-
 fs/afs/cell.c                                   |   2 +-
 fs/afs/inode.c                                  |   2 +-
 fs/afs/vlocation.c                              |   3 +-
 fs/afs/volume.c                                 |   2 +-
 fs/cachefiles/interface.c                       |   2 +-
 fs/ceph/cache.c                                 |   4 +-
 fs/cifs/fscache.c                               |   8 +-
 fs/fscache/cookie.c                             | 193 ++++++++++++++++------
 fs/fscache/fsdef.c                              |   1 +
 fs/fscache/netfs.c                              |   1 +
 fs/fscache/object.c                             |   7 +-
 fs/fscache/page.c                               |  59 +++++--
 fs/nfs/dir.c                                    |   2 +-
 fs/nfs/fscache.c                                | 202 +++++++-----------------
 fs/nfs/fscache.h                                |  18 +--
 fs/nfs/inode.c                                  |   6 +-
 fs/nfs/nfs4file.c                               |   2 +-
 include/linux/fs.h                              |   5 +
 include/linux/fscache-cache.h                   |  50 +++---
 include/linux/fscache.h                         | 113 +++++++++++--
 include/linux/nfs_fs.h                          |   8 +-
 23 files changed, 464 insertions(+), 305 deletions(-)
