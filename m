Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757757Ab2CUPVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:12 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 00/23] NFS: Create NFS Modules
Date: Wed, 21 Mar 2012 11:20:30 -0400
Message-Id: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch series turns NFS v2, v3 and v4 into loadable kernel modules that
are requested before using.  This should eventually help clean up all of
the NFS code by giving us a chance to remove most of the ifdefs that check
for CONFIG_NFS_V3 and CONFIG_NFS_V4.

I have tried to move as little code as possible while making these patches
since version specific code can be moved later once the basic framework has
been merged and tested.  I still had to move a large chunk of code out of
super.c and into nfs4super.c, but the other files are mostly untouched.


Initial size (without v4.1):
584	nfs.ko  (without v4.1)

Final sizes (without v4.1):
312	nfs.ko
44	nfs2.ko
68	nfs3.ko
264	nfs4.ko


Initial size (with v4.1):
708	nfs.ko

Final sizes (with v4.1):
316	nfs.ko
44	nfs2.ko
68	nfs3.ko
384	nfs4.ko


Patch Map
---------
- Patch 1 moves a function out of v2-specific code
- Patch 2 makes NFS v2 configurable
- Patch 3 adds the modules framework
- Patch 4 makes NFS v2 an optional kernel module
- Patches 5 - 9 make NFS v3 an optional kernel module
- Patches 10 - 24 make NFS v4 an optional kernel module

Changes in v4
-------------
- Use request_module to load modules
- Correct Makefile for $(CONFIG_NFS_V3_ACL)
- Various compiler errors found while changing CONFIG_NFS_* values
- Fix dependency cycle with NFS v4.1 enabled

Known bug
---------
I found that if 2 - 3 threads all try to mount NFS v4 at almost the exact
same time then try_then_request_module() will sometimes return success before
the nfs4.ko module is fully initialized.  This leads to get_nfs_version()
returning -EPROTONOSUPPORT to one thread (the others are all able to use v4
without a problem).  Doing schedule() then try_then_request_module() a second
time seems to fix the problem, but that feels more like a workaround than a
real fix.

I've left it out for now with hope that there is a better way to handle this.
For my own testing, I've started doing `modprobe nfs4` before mounting anything
using NFS 4.


Comments and suggestions are appreciated.  Thanks!

- Bryan

Bryan Schumaker (23):
  NFS: Relocate the stat_to_errno() function
  NFS: Make v2 configurable
  NFS: Add version registering framework
  NFS: Convert v2 into a module
  NFS: Break up the nfs_fs_mount function
  NFS: Create a single nfs_clone_super() function
  NFS: Version specific xdev mounting
  NFS: Only initialize the ACL client in the v3 case
  NFS: Convert v3 into a module
  NFS: Initialize NFS v4 from nfs4super.c
  NFS: Move lots of code from super.c
  NFS: module-specific submount function
  NFS: Custom alloc and free client functions for modules
  NFS: Move nfs4_set_client() and support code to nfs4client.c
  NFS: Move the nfs4_init_client() to nfs4client.c
  NFS: Move the v4 getroot code to nfs4getroot.c
  NFS: Deal with delegations
  NFS: Create a v4-specific fsync function
  NFS: Create custom NFS v4 write_inode() function
  NFS: Create custom init_read() and init_write() functions
  NFS: Give modules a custom set / unset layoutdriver functions
  NFS: Use the IS_ENABLED macro for CONFIG_NFS_V4
  NFS: Convert v4 into a module

 fs/lockd/clnt4xdr.c               |    2 +-
 fs/lockd/clntxdr.c                |    6 +-
 fs/lockd/mon.c                    |    4 +-
 fs/nfs/Kconfig                    |   13 +-
 fs/nfs/Makefile                   |   25 +-
 fs/nfs/callback.h                 |    2 +-
 fs/nfs/client.c                   |  799 ++++++++-----------------------
 fs/nfs/delegation.c               |    8 +-
 fs/nfs/delegation.h               |   11 +-
 fs/nfs/dir.c                      |   77 ++-
 fs/nfs/direct.c                   |    2 +-
 fs/nfs/dns_resolve.c              |    3 +
 fs/nfs/file.c                     |  114 ++---
 fs/nfs/fscache.c                  |    3 +
 fs/nfs/getroot.c                  |  136 +-----
 fs/nfs/inode.c                    |   72 +--
 fs/nfs/internal.h                 |   19 +-
 fs/nfs/mount_clnt.c               |    6 +-
 fs/nfs/namespace.c                |   59 +--
 fs/nfs/netns.h                    |    2 +-
 fs/nfs/nfs.h                      |  147 ++++++
 fs/nfs/nfs2super.c                |   92 ++++
 fs/nfs/nfs2xdr.c                  |   66 +--
 fs/nfs/nfs3client.c               |   75 +++
 fs/nfs/nfs3super.c                |  123 +++++
 fs/nfs/nfs3xdr.c                  |    4 +-
 fs/nfs/nfs4_fs.h                  |   24 +-
 fs/nfs/nfs4client.c               |  543 +++++++++++++++++++++
 fs/nfs/nfs4file.c                 |   57 +++
 fs/nfs/nfs4getroot.c              |  135 ++++++
 fs/nfs/nfs4namespace.c            |   11 +
 fs/nfs/nfs4proc.c                 |    8 +-
 fs/nfs/nfs4super.c                |  703 +++++++++++++++++++++++++++
 fs/nfs/{sysctl.c => nfs4sysctl.c} |   43 +-
 fs/nfs/nfs4xdr.c                  |    2 +-
 fs/nfs/pagelist.c                 |    3 +
 fs/nfs/pnfs.c                     |   16 +-
 fs/nfs/pnfs.h                     |   13 +-
 fs/nfs/read.c                     |    8 +-
 fs/nfs/super.c                    |  938 ++++++-------------------------------
 fs/nfs/sysctl.c                   |   26 -
 fs/nfs/unlink.c                   |    3 +-
 fs/nfs/write.c                    |   36 +-
 fs/nfsd/nfs4callback.c            |    2 +-
 include/linux/lockd/xdr4.h        |    2 +-
 include/linux/nfs_fs.h            |   10 +-
 include/linux/nfs_fs_sb.h         |    6 +-
 include/linux/nfs_idmap.h         |    2 +-
 include/linux/nfs_xdr.h           |   12 +-
 include/linux/sunrpc/clnt.h       |    2 +-
 net/sunrpc/rpcb_clnt.c            |    8 +-
 51 files changed, 2530 insertions(+), 1953 deletions(-)
 create mode 100644 fs/nfs/dangling.txt
 create mode 100644 fs/nfs/nfs.h
 create mode 100644 fs/nfs/nfs2super.c
 create mode 100644 fs/nfs/nfs3client.c
 create mode 100644 fs/nfs/nfs3super.c
 create mode 100644 fs/nfs/nfs4client.c
 create mode 100644 fs/nfs/nfs4file.c
 create mode 100644 fs/nfs/nfs4getroot.c
 create mode 100644 fs/nfs/nfs4super.c
 copy fs/nfs/{sysctl.c => nfs4sysctl.c} (51%)

-- 
1.7.9.4

