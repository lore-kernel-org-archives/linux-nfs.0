Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:53311 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1GGQ0M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 12:26:12 -0400
Message-Id: <cover.1310055433.git.rees@umich.edu>
Subject: [PATCH 0/6] pnfs block layout updates
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu,  7 Jul 2011 12:26:06 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch set applies to the pnfs-block branch of your git repo.  Together
with the previous 34 patch set this adds the pnfs block layout client to
pnfs.  I am soliciting comments on this set.  The final patch set will
differ in three small ways:

1. Removal of some debug printks
2. Removal of the DEVONLY patch
3. Fix up some signed-offs

I believe this set addresses the comments since the previous patch set,
including rewriting the I/O path to eliminate write_begin/end and defer
layoutget to flush time.

This set is also available on the for-benny branch of
git://citi.umich.edu/projects/linux-pnfs-blk.git .

Jim Rees (2):
  get rid of deprecated xdr macros
  reindent

Peng Tao (4):
  SQUASHME: pnfs-block: Remove write_begin/end hooks
  SQUASHME: pnfs-block: skip sectors already initialized
  SQUASHME: pnfs: teach layoutcommit handle multiple segments
  pnfs-block: mark IO error with NFS_LAYOUT_{RW|RO}_FAILED

 fs/nfs/blocklayout/blocklayout.c    |  716 ++++++++++++++++-------------------
 fs/nfs/blocklayout/blocklayout.h    |   51 +---
 fs/nfs/blocklayout/blocklayoutdev.c |   30 ++-
 fs/nfs/blocklayout/extents.c        |  115 +++---
 fs/nfs/file.c                       |   26 +--
 fs/nfs/nfs4filelayout.c             |    2 +-
 fs/nfs/nfs4proc.c                   |    8 +-
 fs/nfs/pnfs.c                       |  101 ++----
 fs/nfs/pnfs.h                       |  119 +------
 fs/nfs/write.c                      |   12 +-
 include/linux/nfs_fs.h              |    3 +-
 include/linux/nfs_xdr.h             |    2 +-
 12 files changed, 459 insertions(+), 726 deletions(-)

-- 
1.7.4.1

