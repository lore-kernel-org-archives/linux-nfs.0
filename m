Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:64447 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757929AbaDVV25 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:28:57 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so3547692igc.1
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:28:56 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 00/17] nfs: support multiple requests per page
Date: Tue, 22 Apr 2014 17:29:08 -0400
Message-Id: <1398202165-78897-1-git-send-email-dros@primarydata.com>
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

 -dros

Weston Andros Adamson (17):
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
 fs/nfs/direct.c                  |  93 ++++++++++---
 fs/nfs/nfs4filelayout.c          | 121 +++++++++--------
 fs/nfs/objlayout/objio_osd.c     |  20 ++-
 fs/nfs/pagelist.c                | 284 +++++++++++++++++++++++++++++++++------
 fs/nfs/pnfs.c                    |  77 +++++------
 fs/nfs/pnfs.h                    |   3 +-
 fs/nfs/read.c                    | 149 +++++++-------------
 fs/nfs/write.c                   | 217 +++++++++++++++---------------
 include/linux/nfs.h              |   5 +-
 include/linux/nfs_page.h         |  32 +++--
 include/linux/nfs_xdr.h          |  37 ++---
 12 files changed, 650 insertions(+), 404 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

