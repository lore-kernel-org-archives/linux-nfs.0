Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:51930 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab1FNCcB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:01 -0400
Message-Id: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 00/33] v2 block layout patches
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:31:58 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This version is based on commit 3f585d500f68912fa622749f519ed7df16e417b8.
It fixes the whitespace errors, adds a couple of missing signed-offs, moves
the configurable prefetch to the end and labels it DEVONLY, fixes the
Kconfig, standardizes on "pnfsblock" for patch subject, and makes some other
minor cleanups.  I have not yet incorporated Fred's suggestions.

This patch set is also available on the for-benny branch of
git://citi.umich.edu/projects/linux-pnfs-blk.git .

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
  pnfsblock: add support for simple rpc pipefs
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
  pnfsblock: add block device discovery pipe
  pnfsblock: add device operations
  pnfsblock: remove device operations

Peng Tao (5):
  pnfs: let layoutcommit code handle multiple segments
  pnfs: hook nfs_write_begin/end to allow layout driver manipulation
  pnfs: ask for layout_blksize and save it in nfs_server
  pnfs: cleanup_layoutcommit
  pnfsblock DEVONLY: Add configurable prefetch size for layoutget

Zhang Jingwang (1):
  pnfsblock: Implement release_inval_marks

 fs/nfs/Kconfig                                   |   10 +
 fs/nfs/Makefile                                  |    1 +
 fs/nfs/blocklayout/Makefile                      |    5 +
 fs/nfs/blocklayout/block-device-discovery-pipe.c |   66 ++
 fs/nfs/blocklayout/blocklayout.c                 | 1085 ++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h                 |  287 ++++++
 fs/nfs/blocklayout/blocklayoutdev.c              |  346 +++++++
 fs/nfs/blocklayout/blocklayoutdm.c               |  120 +++
 fs/nfs/blocklayout/extents.c                     |  941 +++++++++++++++++++
 fs/nfs/client.c                                  |    9 +-
 fs/nfs/file.c                                    |   26 +-
 fs/nfs/nfs4_fs.h                                 |    2 +-
 fs/nfs/nfs4proc.c                                |   54 +-
 fs/nfs/nfs4xdr.c                                 |  232 +++++-
 fs/nfs/pnfs.c                                    |  107 ++-
 fs/nfs/pnfs.h                                    |  142 +++-
 fs/nfs/sysctl.c                                  |   10 +
 fs/nfs/write.c                                   |   12 +-
 include/linux/nfs4.h                             |    1 +
 include/linux/nfs_fs.h                           |    3 +-
 include/linux/nfs_fs_sb.h                        |    4 +-
 include/linux/nfs_xdr.h                          |   15 +-
 include/linux/sunrpc/simple_rpc_pipefs.h         |  105 +++
 net/sunrpc/simple_rpc_pipefs.c                   |  423 +++++++++
 24 files changed, 3963 insertions(+), 43 deletions(-)
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

