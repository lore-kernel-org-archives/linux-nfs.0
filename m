Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:54256 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbaDXSPf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:15:35 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so2632604iec.8
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:15:35 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 00/18 v2] nfs: support multiple requests per page
Date: Thu, 24 Apr 2014 14:15:10 -0400
Message-Id: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset changes the read and write paths to be more flexible in dealing
with requests that are not page aligned. Until now there was a 1:1 mapping
of struct nfs_page (referred to as "nfs requests") to struct page, which
limited the client to page aligned I/O in several pNFS scenarios.

This patchset allows multiple requests per page, loosely following
the approach taken with struct buffer_head (part of kernel bio interface).

With this patchset the client now supports:
 - non-page-aligned O_DIRECT I/O to DSes (instead of reverting to MDS)
 - arbitrary pnfs layout segment boundaries
 - arbitrary pnfs filelayout stripe sizes

This patchset also includes a lot of cleanup - notably we no longer need
a separate code path to support rsize/wsize < PAGE_SIZE.

This new approach opens the door to many optimizations, such as not having to
flush a page on a non-contiguous write, but for the time being we are focusing
on correctness -- this patchset touches the read and write path for *all*
versions of NFS!

This has been tested against v2, v3, v4.0 and v4.1 (no pnfs) servers with
different rsize/wsize settings, and against pynfs filelayout servers hacked to
have non page aligned stripe sizes.

I had some code review already (with changes applied) and we've been testing
this pretty extensively for the last month+ - focusing mostly on v2, v3, v4.x
(no pnfs).

The patchset applies against Trond's testing branch, but should also include
the fix I posted earlier today: "pnfs: fix race in filelayout commit path"
as the race seems to be easier to hit with this patchset applied.

I'm pretty sure I didn't break anything in the object and block layouts, but
some extra attention there would be helpful.

I plan on sharing some performance numbers once I'm able to run some nfsometer
workloads. Expect them soon.

Changes in V2:
 - now includes "pnfs: fix race in filelayout commit path" which was posted
   separately, but is needed for testing

 - applied fixup to "nfs: add support for multiple nfs reqs per page"
   to fix ref counting issues.

 - fixed "pnfs: support multiple verfs per direct req" to set dreq->flag
   to _RESCHED_WRITES, just as before

 - applied comment from Boaz to "nfs: modify pg_test interface to return size_t"   and "nfs: chain calls to pg_test"

 - I also rebased on top of trond's testing branch with recent pgio patches
   from Christoph and Anna applied first. the patches are:

    % git log --oneline HEAD~37..HEAD~18
    c1dac13 NFS: Create a common nfs_pageio_ops struct
    a9f5822 NFS: Create a common generic_pg_pgios()
    aab1abe NFS: Create a common multiple_pgios() function
    60695af NFS: Create a common initiate_pgio() function
    3e2e4ad NFS: Create a generic_pgio function
    741d1af NFS: Create a common pgio_error function
    087f8d8 NFS: Create a common rpcsetup function for reads and writes
    fce97cb NFS: Create a common rpc_call_ops struct
    c4c63d7 NFS: Create a common nfs_pgio_result_common function
    fcc4ad0 NFS: Create a common pgio_rpc_prepare function
    06a5f36 NFS: Create a common rw_header_alloc and rw_header_free function
    d4aca41 NFS: Create a common pgio_alloc and pgio_release function
    80afdb2 NFS: Move the write verifier into the nfs_pgio_header
    4f1abf9 NFS: Create a common read and write header struct
    fc7a26b NFS: Create a common read and write data struct
    81ae1c0 NFS: Create a common results structure for reads and writes
    f824d97 NFS: Create a common argument structure for reads and writes
    0d08e1b nfs: remove ->read_pageio_init from rpc ops
    9c4bc08 nfs: remove ->write_pageio_init from rpc ops

    This can be found on my (new) public repo at:

    git://git.linux-nfs.org/projects/dros/linux-nfs

    on the branch "pgio".

 -dros



Weston Andros Adamson (18):
  pnfs: fix race in filelayout commit path
  nfs: clean up PG_* flags
  nfs: remove unused arg from nfs_create_request
  nfs: modify pg_test interface to return size_t
  nfs: call nfs_can_coalesce_requests for every req
  nfs: add support for multiple nfs reqs per page
  nfs: page group syncing in read path
  nfs: page group syncing in write path
  nfs: page group support in nfs_mark_uptodate
  pnfs: clean up filelayout_alloc_commit_info
  nfs: allow coalescing of subpage requests
  nfs: chain calls to pg_test
  nfs: use > 1 request to handle bsize < PAGE_SIZE
  nfs: remove list of [rw]data from pgio header
  pnfs: support multiple verfs per direct req
  pnfs: allow non page aligned pnfs layout segments
  pnfs: filelayout: support non page aligned layouts
  nfs: support page groups in nfs_read_completion

 fs/nfs/blocklayout/blocklayout.c |  16 ++-
 fs/nfs/direct.c                  | 107 +++++++++++++--
 fs/nfs/nfs4filelayout.c          | 142 ++++++++++---------
 fs/nfs/objlayout/objio_osd.c     |  18 ++-
 fs/nfs/pageio.c                  |  91 +-----------
 fs/nfs/pagelist.c                | 290 +++++++++++++++++++++++++++++++++------
 fs/nfs/pnfs.c                    |  77 +++++------
 fs/nfs/pnfs.h                    |   3 +-
 fs/nfs/read.c                    |  51 +++++--
 fs/nfs/write.c                   | 119 +++++++++++++---
 include/linux/nfs.h              |   5 +-
 include/linux/nfs_page.h         |  33 +++--
 include/linux/nfs_xdr.h          |   6 +-
 13 files changed, 659 insertions(+), 299 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

