From: Jim Rees <rees@umich.edu>
Subject: [PATCH v1 00/25] add block layout driver to pnfs client
Date: Sun, 17 Jul 2011 19:58:47 -0400
Message-ID: <1310947152-12255-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37533 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045Ab1GQX7R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2011 19:59:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set adds a block layout driver to the pNFS client.  It passes
Connectathon tests and is bisectable.  It requires an updated version of
nfs-utils, and patches for that will be sent separately to the nfs-utils
maintainer.

This patch set is also available on the for-trond branch of the git repo at
git://citi.umich.edu/projects/linux-pnfs-blk.git

 fs/nfs/Kconfig                      |    8 +-
 fs/nfs/Makefile                     |    1 +
 fs/nfs/blocklayout/Makefile         |    5 +
 fs/nfs/blocklayout/blocklayout.c    | 1064 +++++++++++++++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h    |  252 +++++++++
 fs/nfs/blocklayout/blocklayoutdev.c |  403 +++++++++++++
 fs/nfs/blocklayout/blocklayoutdm.c  |  111 ++++
 fs/nfs/blocklayout/extents.c        |  941 +++++++++++++++++++++++++++++++
 fs/nfs/client.c                     |   11 +-
 fs/nfs/nfs4_fs.h                    |    2 +-
 fs/nfs/nfs4filelayout.c             |    2 +-
 fs/nfs/nfs4proc.c                   |   62 ++-
 fs/nfs/nfs4xdr.c                    |  230 +++++++-
 fs/nfs/pnfs.c                       |   80 ++-
 fs/nfs/pnfs.h                       |   31 +-
 include/linux/nfs.h                 |    2 +
 include/linux/nfs4.h                |    1 +
 include/linux/nfs_fs_sb.h           |    4 +-
 include/linux/nfs_xdr.h             |   17 +-
 19 files changed, 3164 insertions(+), 63 deletions(-)

72eab7c3 pnfsblock: write_pagelist handle zero invalid extents
a299838d pnfsblock: use pageio_ops api
0b641c6 pnfsblock: Implement release_inval_marks
b564392 pnfsblock: note written INVAL areas for layoutcommit
63df052 pnfsblock: bl_write_pagelist
6618fbd pnfsblock: bl_read_pagelist
bf89874 pnfsblock: cleanup_layoutcommit
6894342 pnfsblock: encode_layoutcommit
11ffa70 pnfsblock: merge rw extents
073a04e pnfsblock: add extent manipulation functions
fab2550 pnfsblock: bl_find_get_extent
70caae7 pnfsblock: xdr decode pnfs_block_layout4
e43ad3c pnfsblock: call and parse getdevicelist
86fed52 pnfsblock: merge extents
e7c3c57 pnfsblock: lseg alloc and free
dbaa0e2 pnfsblock: remove device operations
dc0492c pnfsblock: add device operations
91d6a72 pnfsblock: basic extent code
ca24bf5 pnfsblock: add blocklayout Kconfig option, Makefile, and stubs
176d4ac pnfs: cleanup_layoutcommit
566ebcf pnfs: ask for layout_blksize and save it in nfs_server
48f1156 NFS41: save layoutcommit cred after first successful layoutget
026d3ed NFS41: Let layoutcommit handle multiple segments
64de43a pnfs: add set-clear layoutdriver interface
7af880d pnfs: GETDEVICELIST

