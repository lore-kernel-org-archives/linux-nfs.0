Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54170 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756437Ab1FIVwz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 17:52:55 -0400
Message-ID: <4DF140AF.20208@panasas.com>
Date: Thu, 09 Jun 2011 14:52:47 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: rees@umich.edu
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 00/88] pnfs block layout driver
References: <cover.1307464381.git.rees@umich.edu>
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2011 10:24 AM, rees@umich.edu wrote:
> This patch set adds a block layout driver to the pnfs client.
> 
> Benny Halevy (25):
>   pnfs: add set-clear layoutdriver interface
>   pnfs: xdr support for three word attribute bitmap
>   pnfsblock: select BLK_DEV_DM when PNFS_BLOCK is configured
>   SQUASHME: pnfs-block: convert APIs pnfs-post-submit
>   SQUASHME: pnfsblock: get rid of threshold policy ops
>   SQUASHME: pnfs-block: nfs4_blk_add_block_disk ret must be signed
>   SQUASHME: pnfs-block: use new alloc/free_layout API
>   SQUASHME: pnfs-block: use new commit api
>   SQUASHME: pnfs-block: use new read_pagelist api
>   SQUASHME: pnfs-block: use new write_pagelist api
>   SQUASHME: pnfs-block: apply types rename
>   SQUASHME: pnfs-block: Revert "pnfsblock: expose block_class
>     interface"
>   SQUASHME: pnfsblock: remove obsolete include file from blocklayout.h
>   SQUASHME: pnfsblock: use nfs4_deviceid
>   SQUASHME: pnfsblock: no callback ops
>   SQAUSHME: pnfsblock: no PNFS_NFS_SERVER
>   SQUASHME: pnfsblock: no dev_notify_types
>   SQUASHME: pnfsblock: use new struct pnfs_layout_hdr
>   SQUASHME: pnfs-block: deprecate get_stripesize
>   SQUASHME: pnfs-block: use {set,clear}_layoutdriver
>   SQUASHME: pnfs-block: fixup setup_layoutcommit arguments
>   SQUASHME: pnfs-block: fixup cleanup_layoutcommit arguments
>   SQUASHME: pnfs-block: fixup encode_layoutcommit arguments
>   SQUASHME: pnfs-block: fixup layoutcommit methods args
>   SQUASHME: pnfs-block: use pnfs_layout_hdr field prefix
> 
> Boaz Harrosh (1):
>   SQUASHME: pnfs-block: remove of CONFIG_PNFS fallout
> 
> Fred (1):
>   pnfsblock: find_get_extent
> 
> Fred Isaman (39):
>   pnfs_post_submit: Restore "pnfs: pnfs_do_flush" part 1
>   pnfs_post_submit: Restore the pnfs_write_end part of "pnfs: commit
>     and pnfs_write_end"
>   pnfs: HACK: ask for layout_blksize on mount
>   pnfs: HACK: modify write_end_cleanup
>   HACK: propagate fsdata into nfs_writepage_setup
>   pnfs: HACK: adjust eof handling
>   pnfsblock: define PNFS_BLOCK Kconfig option
>   pnfsblock: blocklayout stub
>   pnfsblock: expose scsi interface
>   pnfsblock: scan scsi devices
>   pnfsblock: call and parse getdevicelist
>   pnfsblock: dm kernel interface
>   pnfsblock: create and destroy dm metadevice
>   pnfsblock: construct and load md table
>   pnfsblock: layout alloc and free
>   pnfsblock: basic extent code
>   pnfsblock: lseg alloc and free
>   pnfsblock: xdr decode pnfs_block_layout4
>   pnfsblock: merge extents
>   pnfsblock: bl_read_pagelist
>   pnfsblock: allow use of PG_owner_priv_1 flag
>   pnfsblock: read path error handling
>   pnfsblock: SPLITME: add extent manipulation functions
>   pnfsblock: write_begin
>   pnfsblock: write_end
>   pnfsblock: write_end_cleanup
>   pnfsblock: bl_write_pagelist support functions
>   pnfsblock: bl_write_pagelist
>   pnfsblock: note written INVAL areas for layoutcommit
>   pnfsblock: bl_setup_layoutcommit
>   pnfsblock: encode_layoutcommit
>   pnfsblock: cleanup_layoutcommit
>   pnfsblock: merge rw extents
>   pnfsblock: debugging dprintks for clist info
>   SQUASHME: pnfsblock: write_begin adjust for removed fields
>   SQUASHME: pnfsblock: write_end adjust for removed ok_to_use_pnfs
>   SQUASHME: pnfsblock: write_end_cleanup adjust for removed
>     ok_to_use_pnfs
>   SQUASHME: pnfsblock: bl_write_pagelist support functions adjust for
>     missing PG_USE_PNFS
>   SQUASHME: pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS
> 
> J. Bruce Fields (1):
>   SQUASHME: pnfs-block: fix compile breakage
> 
> Jim Rees (5):
>   pnfs-block: Add support for simple rpc pipefs
>   pnfs-block: Remove device creation from kernel
>   move include lines out of include file
>   SQUASHME: pnfs-block: Return failure from bl_initialize_mountpoint
>   pnfs-block: fix blocklayoutdev.c for new blkdev_get_by_dev()
> 
> Mike Sager (1):
>   pnfsblock: use the session max response size for getdeviceinfo's
>     maxcount
> 
> Peng Tao (4):
>   pnfs: let layoutcommit code handle multiple segments
>   SQUASHME: pnfs: blocklayout: port block layout code
>   Add configurable prefetch size for layoutget
>   NFS41: do not update isize if inode needs layoutcommit
> 
> Steve Dickson (1):
>   SQUASHME: pnfsblock: compile error in blocklayout code
> 
> Tao Guo (3):
>   SQUASHME: pnfsblock: fix bug when decoding block device info.
>   pnfsblock: expose block_class interface
>   pnfsblock: iterating all local block disks instead of only scsi disks
>     when initializing mount point.
> 
> Zhang Jingwang (7):
>   SQAUSHME: blocklayoutdriver: NULL pointer reference when committing
>     too many extents
>   SQUASHME: pnfsblock: Fix a memory leak
>   SQUASHME: pnfsblock: Wrong extent refcount in block extents list
>   SQUASHME: pnfsblock: Implement release_inval_marks
>   SQUASHME: pnfsblock: Fix missing extent in commit list
>   pnfsblock: Lookup list entry of layouts and tags in reverse order
>   SQUASHME: pnfsblock: set pnfs_blksize before calling
>     set_pnfs_layoutdriver
> 
>  fs/nfs/Kconfig                                   |   10 +
>  fs/nfs/Makefile                                  |    1 +
>  fs/nfs/blocklayout/Makefile                      |    6 +
>  fs/nfs/blocklayout/block-device-discovery-pipe.c |   66 ++
>  fs/nfs/blocklayout/blocklayout.c                 | 1103 ++++++++++++++++++++++
>  fs/nfs/blocklayout/blocklayout.h                 |  297 ++++++
>  fs/nfs/blocklayout/blocklayoutdev.c              |  346 +++++++
>  fs/nfs/blocklayout/blocklayoutdm.c               |  120 +++
>  fs/nfs/blocklayout/extents.c                     |  940 ++++++++++++++++++
>  fs/nfs/client.c                                  |    8 +-
>  fs/nfs/file.c                                    |   26 +-
>  fs/nfs/inode.c                                   |    3 +-
>  fs/nfs/nfs4_fs.h                                 |    2 +-
>  fs/nfs/nfs4proc.c                                |    6 +-
>  fs/nfs/nfs4xdr.c                                 |  104 ++-
>  fs/nfs/pnfs.c                                    |   96 ++-
>  fs/nfs/pnfs.h                                    |  126 +++-
>  fs/nfs/sysctl.c                                  |   10 +
>  fs/nfs/write.c                                   |   12 +-
>  include/linux/nfs_fs.h                           |    3 +-
>  include/linux/nfs_fs_sb.h                        |    4 +-
>  include/linux/nfs_xdr.h                          |    3 +-
>  include/linux/sunrpc/rpc_pipe_fs.h               |    4 +
>  include/linux/sunrpc/simple_rpc_pipefs.h         |  105 ++
>  net/sunrpc/Makefile                              |    2 +-
>  net/sunrpc/simple_rpc_pipefs.c                   |  423 +++++++++
>  26 files changed, 3778 insertions(+), 48 deletions(-)
>  create mode 100644 fs/nfs/blocklayout/Makefile
>  create mode 100644 fs/nfs/blocklayout/block-device-discovery-pipe.c
>  create mode 100644 fs/nfs/blocklayout/blocklayout.c
>  create mode 100644 fs/nfs/blocklayout/blocklayout.h
>  create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c
>  create mode 100644 fs/nfs/blocklayout/blocklayoutdm.c
>  create mode 100644 fs/nfs/blocklayout/extents.c
>  create mode 100644 include/linux/sunrpc/simple_rpc_pipefs.h
>  create mode 100644 net/sunrpc/simple_rpc_pipefs.c
> 

Who is going to SQUASH all the SQUASHMEs and re think the all patch
separation again. To something that makes a more logical progression
and easier on the review. The way it is now I'm not able to review,
sorry, I got lost trying to understand which is which.

Thanks
Boaz

