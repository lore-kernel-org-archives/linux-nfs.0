Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33493 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368AbaIOSOp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:14:45 -0400
Received: by mail-ie0-f177.google.com with SMTP id rd18so4829250iec.8
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:14:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 00/14] Stable fixes for NFS client read/write code in 3.16.x
Date: Mon, 15 Sep 2014 14:14:31 -0400
Message-Id: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Greg,

The following patches are needed in order to fix the NFS read/write code
in 3.16.x (and only 3.16.x). As it stands, that code will Oops badly if
you mount using the rsize=1024 or wsize=1024 (or anything < page size).

Unfortunately, the upstream patches required me to pull in a few
cleanups on which there were dependencies, so the first 4 patches are
needed in order to support the fixes that follow.

Cheers
  Trond

Weston Andros Adamson (14):
  nfs: move nfs_pgio_data and remove nfs_rw_header
  nfs: rename members of nfs_pgio_data
  nfs: merge nfs_pgio_data into _header
  nfs: remove pgio_header refcount, related cleanup
  nfs: check wait_on_bit_lock err in page_group_lock
  pnfs: add pnfs_put_lseg_async
  nfs: clear_request_commit while holding i_lock
  nfs: change nfs_page_group_lock argument
  nfs: fix nonblocking calls to nfs_page_group_lock
  nfs: use blocking page_group_lock in add_request
  nfs: fix error handling in lock_and_join_requests
  nfs: don't sleep with inode lock in lock_and_join_requests
  nfs: disallow duplicate pages in pgio page vectors
  nfs: can_coalesce_requests must enforce contiguity

 fs/nfs/blocklayout/blocklayout.c |  99 +++++++-------
 fs/nfs/direct.c                  |   8 +-
 fs/nfs/filelayout/filelayout.c   | 175 ++++++++++++------------
 fs/nfs/internal.h                |  10 +-
 fs/nfs/nfs3proc.c                |  21 +--
 fs/nfs/nfs4_fs.h                 |   6 +-
 fs/nfs/nfs4proc.c                | 105 ++++++++-------
 fs/nfs/nfs4trace.h               |  28 ++--
 fs/nfs/objlayout/objio_osd.c     |  24 ++--
 fs/nfs/objlayout/objlayout.c     |  81 ++++++-----
 fs/nfs/objlayout/objlayout.h     |   8 +-
 fs/nfs/pagelist.c                | 284 +++++++++++++++++++--------------------
 fs/nfs/pnfs.c                    | 119 ++++++++--------
 fs/nfs/pnfs.h                    |  17 ++-
 fs/nfs/proc.c                    |  27 ++--
 fs/nfs/read.c                    |  48 +++----
 fs/nfs/write.c                   |  99 ++++++++------
 include/linux/nfs_page.h         |  16 ++-
 include/linux/nfs_xdr.h          |  32 ++---
 19 files changed, 602 insertions(+), 605 deletions(-)

-- 
1.9.3

