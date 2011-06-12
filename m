Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60550 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab1FLXnr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:43:47 -0400
Message-Id: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:43:45 -0400
Content-Type: text/plain; charset=UTF-8
Subject: [PATCH 00/34] pnfs block layout driver based on v3.0-rc2
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For review only.  This patch set adds the pnfs block layout driver to the
nfs client.  It is roughly equivalent to the 88-patch set I sent earlier,
but is re-organized and based on v3.0-rc2.

There are several style problems, mostly white space and line
length problems, and I'll deal with those.  I'm interested in comments on
the structure of the patch set, and of course the logic and functionality.

Date: Sun, 12 Jun 2011 19:43:45 -0400

Among these patches, the first 6 patches are generic layer change that is
needed for block layout driver.

Patch 7~32 are block driver code.

Patch 33 is the layout prefetch patch, which Benny agrees to take in for BAT
with the default value set to 0.

Patch 34 is the fix for layoutcommit vs. update_inode. Trond hasn't merged
it so I put it here as block driver need it to pass cthon hole file test.

Although the code is almost same as previous one, we did not have much time
fully testing it. It seems increased segment number (by reducing the layout
segment size) will sometimes cause client hang in cthon test. There may be
some bugs in either generic layer segment management or block driver extent
management (we already fixed some bugs in both parts). We will do more
investigation on it tomorrow.

Andy Adamson (1):
  pnfs: GETDEVICELIST

Benny Halevy (1):
  pnfs: add set-clear layoutdriver interface

Fred (1):
  pnfsblock: find_get_extent

Fred Isaman (21):
  pnfsblock: define PNFS_BLOCK Kconfig option
  pnfsblock: blocklayout stub
  pnfsblock: layout alloc and free
  Add support for simple rpc pipefs
  pnfsblock: basic extent code
  pnfsblock: lseg alloc and free
  pnfsblock: merge extents
  pnfsblock: call and parse getdevicelist
  pnfsblock: allow use of PG_owner_priv_1 flag
  pnfsblock: xdr decode pnfs_block_layout4
  pnfsblock: SPLITME: add extent manipulation functions
  pnfsblock: merge rw extents
  pnfsblock: encode_layoutcommit
  pnfsblock: cleanup_layoutcommit
  pnfsblock: bl_read_pagelist
  pnfsblock: write_begin
  pnfsblock: write_end
  pnfsblock: write_end_cleanup
  pnfsblock: bl_write_pagelist support functions
  pnfsblock: bl_write_pagelist
  pnfsblock: note written INVAL areas for layoutcommit

Jim Rees (3):
  pnfs-block: Add block device discovery pipe
  pnfsblock: add device operations
  pnfsblock: remove device operations

Peng Tao (6):
  pnfs: let layoutcommit code handle multiple segments
  pnfs: hook nfs_write_begin/end to allow layout driver manipulation
  pnfs: ask for layout_blksize and save it in nfs_server
  pnfs: cleanup_layoutcommit
  Add configurable prefetch size for layoutget
  NFS41: do not update isize if inode needs layoutcommit

Zhang Jingwang (1):
  pnfsblock: Implement release_inval_marks

 fs/nfs/Kconfig                                   |    8 +
 fs/nfs/Makefile                                  |    1 +
 fs/nfs/blocklayout/Makefile                      |    5 +
 fs/nfs/blocklayout/block-device-discovery-pipe.c |   66 ++
 fs/nfs/blocklayout/blocklayout.c                 | 1089 ++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h                 |  287 ++++++
 fs/nfs/blocklayout/blocklayoutdev.c              |  346 +++++++
 fs/nfs/blocklayout/blocklayoutdm.c               |  120 +++
 fs/nfs/blocklayout/extents.c                     |  941 +++++++++++++++++++
 fs/nfs/client.c                                  |    8 +-
 fs/nfs/file.c                                    |   26 +-
 fs/nfs/inode.c                                   |    3 +-
 fs/nfs/nfs4_fs.h                                 |    2 +-
 fs/nfs/nfs4proc.c                                |   53 +-
 fs/nfs/nfs4xdr.c                                 |  232 +++++-
 fs/nfs/pnfs.c                                    |  105 ++-
 fs/nfs/pnfs.h                                    |  141 +++-
 fs/nfs/sysctl.c                                  |   10 +
 fs/nfs/write.c                                   |   12 +-
 include/linux/nfs4.h                             |    1 +
 include/linux/nfs_fs.h                           |    3 +-
 include/linux/nfs_fs_sb.h                        |    4 +-
 include/linux/nfs_xdr.h                          |   15 +-
 include/linux/sunrpc/simple_rpc_pipefs.h         |  105 +++
 net/sunrpc/simple_rpc_pipefs.c                   |  423 +++++++++
 25 files changed, 3962 insertions(+), 44 deletions(-)
 create mode 100644 fs/nfs/blocklayout/Makefile
 create mode 100644 fs/nfs/blocklayout/block-device-discovery-pipe.c
 create mode 100644 fs/nfs/blocklayout/blocklayout.c
 create mode 100644 fs/nfs/blocklayout/blocklayout.h
 create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c
 create mode 100644 fs/nfs/blocklayout/blocklayoutdm.c
 create mode 100644 fs/nfs/blocklayout/extents.c
 create mode 100644 include/linux/sunrpc/simple_rpc_pipefs.h
 create mode 100644 net/sunrpc/simple_rpc_pipefs.c

-- 
1.7.4.1

