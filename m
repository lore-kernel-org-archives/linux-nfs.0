Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652Ab3ITPJH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Sep 2013 11:09:07 -0400
Subject: [RFC][PATCH 0/3] FS-Cache: NFS(/CIFS/Ceph/9P): Fix start-caching
 whilst writing race
To: Trond.Myklebust@netapp.com, steved@redhat.com
From: David Howells <dhowells@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org
Date: Fri, 20 Sep 2013 16:09:03 +0100
Message-ID: <20130920150902.16220.32737.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Following this mail is a series of patches to fix an issue with NFS whereby
caching can be enabled on a file that is open for writing by subsequently
opening it for reading.  This can be made to crash by opening it for writing
again if you're quick enough.

The patches mailed here may not apply directly.  They are based on top of three
fix patches as can be seen in the GIT branch here:

  http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache


The gist of the patchset is that the cookie should be acquired at inode
creation only and subsequently enabled and disabled as appropriate (which
dispenses with the backing objects when they're not needed).

The extra synchronisation that NFS does can then be dispensed with as it is
thenceforth managed by FS-Cache.

This likely will need applying to CIFS, Ceph and 9P also once this is okayed
for NFS.  AFS is probably safe.

David
---
David Howells (3):
      FS-Cache: Add use/unuse/wake cookie wrappers
      FS-Cache: Provide the ability to enable/disable cookies
      NFS: Use i_writecount to control whether to get an fscache cookie in nfs_open()


 Documentation/filesystems/caching/netfs-api.txt |   73 +++++++--
 fs/9p/cache.c                                   |    6 -
 fs/afs/cell.c                                   |    2 
 fs/afs/inode.c                                  |    2 
 fs/afs/vlocation.c                              |    3 
 fs/afs/volume.c                                 |    2 
 fs/cachefiles/interface.c                       |    2 
 fs/ceph/cache.c                                 |    4 
 fs/cifs/fscache.c                               |    8 -
 fs/fscache/cookie.c                             |  193 +++++++++++++++++------
 fs/fscache/fsdef.c                              |    1 
 fs/fscache/netfs.c                              |    1 
 fs/fscache/object.c                             |    7 +
 fs/fscache/page.c                               |   59 +++++--
 fs/nfs/dir.c                                    |    2 
 fs/nfs/fscache.c                                |  196 +++++++----------------
 fs/nfs/fscache.h                                |   18 +-
 fs/nfs/inode.c                                  |    6 -
 fs/nfs/nfs4file.c                               |    2 
 include/linux/fs.h                              |    5 +
 include/linux/fscache-cache.h                   |   50 ++----
 include/linux/fscache.h                         |  113 ++++++++++++-
 include/linux/nfs_fs.h                          |    8 +
 23 files changed, 462 insertions(+), 301 deletions(-)

