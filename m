Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754284Ab2G3UF3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:29 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 00/10] Create NFS modules
Date: Mon, 30 Jul 2012 16:05:15 -0400
Message-Id: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is the final set of patches to turn NFS into modules.  The first patch
creates an "nfs_subversion" structure that will represent a single NFS
version.  The next 6 patches are cleanups that the nfs_subversion structure
allows us to put in.  Finally, the last 3 patches convert v2, v3 and v4 into
kernel modules.

Changes in version 2:
- Add a patch to keep nfs4 module parameters in the generic client.  Without
  this we break backwards compatibility with older kernels.

- Bryan

Bryan Schumaker (10):
  NFS: Add version registering framework
  NFS: Remove the NFS v4 xdev mount function
  NFS: Create a try_mount rpc op
  NFS: Only initialize the ACL client in the v3 case
  NFS: Pass super operations and xattr handlers in the nfs_subversion
  NFS: Split out remaining NFS v4 inode functions
  NFS: Keep module parameters in the generic NFS client
  NFS: Convert v2 into a module
  NFS: Convert v3 into a module
  NFS: Convert v4 into a module

 fs/nfs/Kconfig            |   6 +-
 fs/nfs/Makefile           |  27 +++----
 fs/nfs/callback.c         |  24 ------
 fs/nfs/callback.h         |   2 +-
 fs/nfs/client.c           | 191 +++++++++++++++++++++++++---------------------
 fs/nfs/delegation.h       |   2 +-
 fs/nfs/dir.c              |  20 ++++-
 fs/nfs/direct.c           |   2 +-
 fs/nfs/dns_resolve.c      |   4 +
 fs/nfs/file.c             |  15 ++++
 fs/nfs/idmap.c            |   3 -
 fs/nfs/inode.c            | 105 ++++++++++++-------------
 fs/nfs/internal.h         |  38 +++++----
 fs/nfs/namespace.c        |  17 +----
 fs/nfs/netns.h            |   2 +-
 fs/nfs/nfs.h              |  29 +++++++
 fs/nfs/nfs2super.c        |  31 ++++++++
 fs/nfs/nfs3client.c       |  65 ++++++++++++++++
 fs/nfs/nfs3proc.c         |   3 +
 fs/nfs/nfs3super.c        |  31 ++++++++
 fs/nfs/nfs4_fs.h          |  13 ++--
 fs/nfs/nfs4client.c       |  23 ++----
 fs/nfs/nfs4proc.c         |   9 +--
 fs/nfs/nfs4super.c        | 106 +++++++++++++------------
 fs/nfs/nfs4xdr.c          |   6 --
 fs/nfs/pagelist.c         |   4 +
 fs/nfs/pnfs.c             |   2 +
 fs/nfs/proc.c             |   3 +
 fs/nfs/read.c             |   5 ++
 fs/nfs/super.c            | 172 ++++++++++++++++++++++++++++-------------
 fs/nfs/write.c            |  35 +++------
 include/linux/nfs_fs.h    |   6 +-
 include/linux/nfs_fs_sb.h |   7 +-
 include/linux/nfs_idmap.h |   2 +-
 include/linux/nfs_xdr.h   |   9 ++-
 35 files changed, 632 insertions(+), 387 deletions(-)
 create mode 100644 fs/nfs/nfs.h
 create mode 100644 fs/nfs/nfs2super.c
 create mode 100644 fs/nfs/nfs3client.c
 create mode 100644 fs/nfs/nfs3super.c

-- 
1.7.11.3

