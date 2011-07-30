Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:56435 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab1G3RIw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 13:08:52 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v6 00/26] add block layout driver to pnfs client
Date: Sat, 30 Jul 2011 13:08:23 -0400
Message-Id: <1312045729-27554-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch set adds a block layout driver to the pNFS client.  It passes
Connectathon tests and is bisectable.  It requires an updated version of
nfs-utils, and patches for that have been sent separately to the nfs-utils
maintainer.

This patch set is also available on the for-trond branch of the git repo at
git://citi.umich.edu/projects/linux-pnfs-blk.git

This is version 6 of this patch set.  Changes since version 5:

- rearrange layoutcommit lwb and cred patches per Boaz
  "[PATCHSET 0/6] Patches needed for Stable" 29 Jul 2011 23:19:52 -0700
  and put these patches first
- add prefix to exported symbols, or make them static

Changes since version 4:

- rm inode and pnfs_layout_hdr args from cleanup_layoutcommit()

Changes since version 3:

- Rebase to trond/nfs-for-3.1 (commit ed1e6211a0).
- Change return value NFS4ERR_REP_TOO_BIG to EIO in decode_getdevicelist.
- fix error message in set_pnfs_layoutdriver.
- remove dont_like_caller from read_pagelist and write_pagelist.
- rename mark_for_commit to bl_mark_for_commit
- split the patch "NFS41: Let layoutcommit handle multiple segments" into 4
  patches each does one task only.
- fix race in saving cred in layout header.
- move the patch "NFS41: save layoutcommit cred after first successful
  layoutget" to an earlier place.
- "[PATCH v3 25/25] NFS41: Drop lseg ref before fallthru to MDS" is dropped.   
- move GETDEVICELIST to end of nfs4_procedures[]

Changes since version 2:

- Rebase to trond/nfs-for-next (commit ed1e6211a0).
- Fix Fred's and Benny's email addresses.
- Use FIXME to flag code that needs more work.
- Remove obsolete comments.
- Minor patch re-orgs per reviewer comments.

Changes since version 1:

NFS41: Drop lseg ref before fallthru to MDS
SQUASHME: pnfsblock: get rid of vmap and deviceid->area structure
SQUASHME: pnfsblock: define module alias
SQUASHME: pnfsblock: bl_find_get_extent optimization: mv break clause to end of loop
SQUASHME: pnfsblock: test debug bit once for multiple dprintks
SQUASHME: pnfsblock: typo
SQUASHME: pnfsblock: get rid of unused leftovers from device mapping removal

Andy Adamson (2):
  pnfs: GETDEVICELIST
  pnfs: cleanup_layoutcommit

Benny Halevy (2):
  pnfs: add set-clear layoutdriver interface
  pnfsblock: use pageio_ops api

Fred Isaman (15):
  pnfs: ask for layout_blksize and save it in nfs_server
  pnfsblock: add blocklayout Kconfig option, Makefile, and stubs
  pnfsblock: basic extent code
  pnfsblock: lseg alloc and free
  pnfsblock: merge extents
  pnfsblock: call and parse getdevicelist
  pnfsblock: xdr decode pnfs_block_layout4
  pnfsblock: bl_find_get_extent
  pnfsblock: add extent manipulation functions
  pnfsblock: merge rw extents
  pnfsblock: encode_layoutcommit
  pnfsblock: cleanup_layoutcommit
  pnfsblock: bl_read_pagelist
  pnfsblock: bl_write_pagelist
  pnfsblock: note written INVAL areas for layoutcommit

Jim Rees (2):
  pnfsblock: add device operations
  pnfsblock: remove device operations

Peng Tao (5):
  pnfs: save layoutcommit lwb at layout header
  pnfs: save layoutcommit cred at layout header init
  pnfs: let layoutcommit handle a list of lseg
  pnfs: use lwb as layoutcommit length
  pnfsblock: write_pagelist handle zero invalid extents

 fs/nfs/Kconfig                      |    8 +-
 fs/nfs/Makefile                     |    1 +
 fs/nfs/blocklayout/Makefile         |    5 +
 fs/nfs/blocklayout/blocklayout.c    | 1019 +++++++++++++++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h    |  207 +++++++
 fs/nfs/blocklayout/blocklayoutdev.c |  410 ++++++++++++++
 fs/nfs/blocklayout/blocklayoutdm.c  |  111 ++++
 fs/nfs/blocklayout/extents.c        |  935 ++++++++++++++++++++++++++++++++
 fs/nfs/client.c                     |   11 +-
 fs/nfs/nfs4_fs.h                    |    2 +-
 fs/nfs/nfs4filelayout.c             |    2 +-
 fs/nfs/nfs4proc.c                   |   62 ++-
 fs/nfs/nfs4xdr.c                    |  233 ++++++++-
 fs/nfs/pnfs.c                       |   86 ++--
 fs/nfs/pnfs.h                       |   28 +-
 include/linux/nfs.h                 |    2 +
 include/linux/nfs4.h                |    1 +
 include/linux/nfs_fs_sb.h           |    4 +-
 include/linux/nfs_xdr.h             |   17 +-
 19 files changed, 3077 insertions(+), 67 deletions(-)
 create mode 100644 fs/nfs/blocklayout/Makefile
 create mode 100644 fs/nfs/blocklayout/blocklayout.c
 create mode 100644 fs/nfs/blocklayout/blocklayout.h
 create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c
 create mode 100644 fs/nfs/blocklayout/blocklayoutdm.c
 create mode 100644 fs/nfs/blocklayout/extents.c

-- 
1.7.4.1

