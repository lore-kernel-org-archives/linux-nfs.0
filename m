Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33942 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054AbaEOP5E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2014 11:57:04 -0400
Received: by mail-ie0-f170.google.com with SMTP id ar20so1225735iec.29
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2014 08:57:03 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 00/18] nfs: support multiple requests per page
Date: Thu, 15 May 2014 11:56:39 -0400
Message-Id: <1400169417-28245-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
workloads. 

Changes in V3:
   - rebased to Anna's newest patches, which merges pageio.c into pagelist.c

Upcoming:
   - ~5 patch patchset that cleans up nfs_pgio_header and nfs_pgio_data

I just pushed an updated version of my ‘pgio’ branch to:

 git://git.linux-nfs.org/projects/dros/linux-nfs

The branch has the following patches:

from me (this patchset!):

7d8976b nfs: support page groups in nfs_read_completion
f0d7a82 pnfs: filelayout: support non page aligned layouts
79a9c89 pnfs: allow non page aligned pnfs layout segments
cf25fb9 pnfs: support multiple verfs per direct req
c081af5 nfs: remove data list from pgio header
6313def nfs: use > 1 request to handle bsize < PAGE_SIZE
9f89e40 nfs: chain calls to pg_test
d65d153 nfs: allow coalescing of subpage requests
12cf560 pnfs: clean up filelayout_alloc_commit_info
49fa6d6 nfs: page group support in nfs_mark_uptodate
ba94674 nfs: page group syncing in write path
00ddd94 nfs: page group syncing in read path
d6dec2d nfs: add support for multiple nfs reqs per page
1ea228a nfs: call nfs_can_coalesce_requests for every req
104ab5c nfs: modify pg_test interface to return size_t
27f3d0c nfs: remove unused arg from nfs_create_request
fc9eeaa nfs: clean up PG_* flags
366d632 pnfs: fix race in filelayout commit path

from Anna:

6e35ebf NFS: Create a common nfs_pageio_ops struct
9a0dabd NFS: Create a common generic_pg_pgios()
9a074ee NFS: Create a common multiple_pgios() function
a7c7f54 NFS: Create a common initiate_pgio() function
fd42750 NFS: Create a generic_pgio function
4003d02 NFS: Create a common pgio_error function
c9f494c NFS: Create a common rpcsetup function for reads and writes
1220495 NFS: Create a common rpc_call_ops struct
4e07fcf NFS: Create a common nfs_pgio_result_common function
1986d26 NFS: Create a common pgio_rpc_prepare function
9892bb1 NFS: Create a common rw_header_alloc and rw_header_free function
76c449c NFS: Create a common pgio_alloc and pgio_release function
4fca7e6 NFS: Move the write verifier into the nfs_pgio_header
fd279ad NFS: Create a common read and write header struct
59d6da2 NFS: Create a common read and write data struct
9726903 NFS: Create a common results structure for reads and writes
0ec19c2 NFS: Create a common argument structure for reads and writes

from Christoph:

140c1e0 nfs: remove ->read_pageio_init from rpc ops
75fd2e5 nfs: remove ->write_pageio_init from rpc ops


The diffstat of pgio branch (including patches from Anna and Christoph):

 fs/nfs/blocklayout/blocklayout.c |  38 ++-
 fs/nfs/direct.c                  | 117 +++++++-
 fs/nfs/internal.h                |  33 +--
 fs/nfs/nfs2xdr.c                 |  14 +-
 fs/nfs/nfs3proc.c                |  21 +-
 fs/nfs/nfs3xdr.c                 |  16 +-
 fs/nfs/nfs4_fs.h                 |   4 +-
 fs/nfs/nfs4filelayout.c          | 182 ++++++------
 fs/nfs/nfs4proc.c                |  54 ++--
 fs/nfs/nfs4trace.h               |   8 +-
 fs/nfs/nfs4xdr.c                 |  19 +-
 fs/nfs/objlayout/objio_osd.c     |  24 +-
 fs/nfs/objlayout/objlayout.c     |  16 +-
 fs/nfs/objlayout/objlayout.h     |   8 +-
 fs/nfs/pagelist.c                | 617 ++++++++++++++++++++++++++++++++++++---
 fs/nfs/pnfs.c                    | 146 ++++-----
 fs/nfs/pnfs.h                    |  30 +-
 fs/nfs/proc.c                    |  21 +-
 fs/nfs/read.c                    | 414 +++++---------------------
 fs/nfs/write.c                   | 561 ++++++++++-------------------------
 include/linux/nfs.h              |   5 +-
 include/linux/nfs_fs.h           |   2 -
 include/linux/nfs_page.h         |  46 ++-
 include/linux/nfs_xdr.h          | 106 +++----
 24 files changed, 1276 insertions(+), 1226 deletions(-)

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
  nfs: remove data list from pgio header
  pnfs: support multiple verfs per direct req
  pnfs: allow non page aligned pnfs layout segments
  pnfs: filelayout: support non page aligned layouts
  nfs: support page groups in nfs_read_completion

 fs/nfs/blocklayout/blocklayout.c |  16 +-
 fs/nfs/direct.c                  | 111 ++++++++++-
 fs/nfs/nfs4filelayout.c          | 142 +++++++-------
 fs/nfs/objlayout/objio_osd.c     |  18 +-
 fs/nfs/pagelist.c                | 387 ++++++++++++++++++++++++++-------------
 fs/nfs/pnfs.c                    |  77 ++++----
 fs/nfs/pnfs.h                    |   3 +-
 fs/nfs/read.c                    |  51 ++++--
 fs/nfs/write.c                   | 119 ++++++++++--
 include/linux/nfs.h              |   5 +-
 include/linux/nfs_page.h         |  33 ++--
 include/linux/nfs_xdr.h          |   7 +-
 12 files changed, 666 insertions(+), 303 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

