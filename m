Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475Ab2GJQQT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:16:19 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/12] NFS: Split out version-specific code
Date: Tue, 10 Jul 2012 12:16:05 -0400
Message-Id: <1341936977-21186-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These patches split out most NFS version-specific code into files based on the
NFS version it belongs to.  The first two patches make all the NFS v2 and v3
changes that are needed, the rest carefully split out NFS v4 code from the
generic client.  I apologize for the amount of flux caused by these patches
but after this the rest of my modularization changes are really, really easy.

I would appreciate it if lots of people could take the time to look at these
patches.  I think the changes are fairly straightforward, but the large amount
of code changed means I could have easily missed something.  I expect there
will be conflicts with Chuck's recent TEST_STATEID changes, I'm willing to
update and resubmit these patches if Chuck's changes are merged into Trond's
git tree first.

When creating new files with moved code I tried to preserve the copyright of
the original file.  Right now fs/nfs/sysctl.c doesn't have a copyright line so
I used `git annotate` to guess that Trond wrote the code in 2006 when creating
fs/nfs/nfs4sysctl.c.  If I got something wrong, please let me know!

Thanks,
- Bryan

Bryan Schumaker (12):
  NFS: Split out NFS v2 inode operations
  NFS: Split out NFS v3 inode operations
  NFS: Split out NFS v4 inode operations
  NFS: Create an init_nfs_v4() function
  NFS: Initialize v4 sysctls from nfs_init_v4()
  NFS: Split out NFS v4 file operations
  NFS: Move the v4 getroot code to nfs4getroot.c
  NFS: Initialize the NFS v4 client from init_nfs_v4()
  NFS: Split out NFS v4 server creating code
  NFS: Create a single nfs_clone_super() function
  NFS: Split out the NFS v4 filesystem types
  NFS: Split out NFS v4 client functions

 fs/nfs/Makefile        |  11 +-
 fs/nfs/client.c        | 687 +------------------------------------------------
 fs/nfs/dir.c           |  93 +------
 fs/nfs/file.c          | 169 ++----------
 fs/nfs/getroot.c       |  50 ----
 fs/nfs/inode.c         |  67 ++---
 fs/nfs/internal.h      |  81 ++++++
 fs/nfs/nfs3proc.c      |  29 +++
 fs/nfs/nfs4_fs.h       |  26 +-
 fs/nfs/nfs4client.c    | 663 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c      | 126 +++++++++
 fs/nfs/nfs4getroot.c   |  49 ++++
 fs/nfs/nfs4proc.c      |  19 ++
 fs/nfs/nfs4super.c     | 358 ++++++++++++++++++++++++++
 fs/nfs/nfs4sysctl.c    |  68 +++++
 fs/nfs/proc.c          |  21 ++
 fs/nfs/super.c         | 423 ++----------------------------
 fs/nfs/sysctl.c        |  26 --
 include/linux/nfs_fs.h |   8 -
 19 files changed, 1550 insertions(+), 1424 deletions(-)
 create mode 100644 fs/nfs/nfs4client.c
 create mode 100644 fs/nfs/nfs4file.c
 create mode 100644 fs/nfs/nfs4getroot.c
 create mode 100644 fs/nfs/nfs4super.c
 create mode 100644 fs/nfs/nfs4sysctl.c

-- 
1.7.11.1

