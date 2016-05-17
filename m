Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34414 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818AbcEQQ25 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 12:28:57 -0400
Received: by mail-qk0-f193.google.com with SMTP id i7so1933290qkd.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2016 09:28:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Thomas Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        hch@lst.de
Subject: [PATCH v4 00/13] pnfs: layout pipelining and related fixes
Date: Tue, 17 May 2016 12:28:35 -0400
Message-Id: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4:
- fix error handling in send_layoutget/pnfs_update_layout

v3:
- move more of the LAYOUTGET error handling out of the state machine
- better tracepoints
- cleanup and fixes in pnfs_layout_process
- patches to prevent client from flipping to in-band I/O
- bugfixes

v2:
- rework of LAYOUTGET retry handling.

v4 for the set, a fix for the error handling bug that Trond spotted in
send_layoutget. Also fix a minor comment typo that Tom spotted.

Original cover letter from the RFC patchset follows:

--------------------------[snip]----------------------------

At Primary Data, one of the things we're most interested in is data
mobility. IOW, we want to be able to change the layout for an inode
seamlessly, with little interruption to I/O patterns.

The problem we have now is that CB_LAYOUTRECALLs interrupt I/O. When one
comes in, most pNFS servers refuse to hand out new layouts until the
recalled ones have been returned (or the client indicates that it no
longer knows about them). It doesn't have to be this way though. RFC5661
allows for concurrent LAYOUTGET and LAYOUTRETURN calls.

Furthermore, servers are expected to deal with old stateids in
LAYOUTRETURN. From RFC5661, section 18.44.3:

   If the client returns the layout in response to a CB_LAYOUTRECALL
   where the lor_recalltype field of the clora_recall field was
   LAYOUTRECALL4_FILE, the client should use the lor_stateid value from
   CB_LAYOUTRECALL as the value for lrf_stateid.  Otherwise, it should
   use logr_stateid (from a previous LAYOUTGET result) or lorr_stateid
   (from a previous LAYRETURN result).  This is done to indicate the
   point in time (in terms of layout stateid transitions) when the
   recall was sent.

The way I'm interpreting this is that we can treat a LAYOUTRETURN with
an old stateid as returning all layouts that matched the given iomode,
at the time that that seqid was current.

With that, we can allow a LAYOUTGET on the same fh to proceed even when
there are still recalled layouts outstanding. This should allow the
client to pivot to a new layout while it's still draining I/Os
that are pinning the ones to be returned.

This patchset is a first draft of the client side piece that allows
this.  Basically whenever we get a new layout segment, we'll tag it with
the seqid that was in the LAYOUTGET stateid that grants it.

When a CB_LAYOUTRECALL comes in, we tag the return seqid in the layout
header with the one that was in the request. When we do a LAYOUTRETURN
in response to a CB_LAYOUTRECALL, we craft the seqid such that we're
only returning the layouts that were recalled. Nothing that has been 
granted since then will be returned.

I think I've done this in a way that the existing behavior is preserved
in the case where the server enforces the serialization of these
operations, but please do have a look and let me know if you see any
potential problems here. Testing this is still a WIP...

Jeff Layton (10):
  pnfs: don't merge new ff lsegs with ones that have LAYOUTRETURN bit
    set
  pnfs: record sequence in pnfs_layout_segment when it's created
  pnfs: keep track of the return sequence number in pnfs_layout_hdr
  pnfs: only tear down lsegs that precede seqid in LAYOUTRETURN args
  flexfiles: remove pointless setting of NFS_LAYOUT_RETURN_REQUESTED
  flexfiles: add kerneldoc header to nfs4_ff_layout_prepare_ds
  pnfs: fix bad error handling in send_layoutget
  pnfs: lift retry logic from send_layoutget to pnfs_update_layout
  pnfs: rework LAYOUTGET retry handling
  pnfs: make pnfs_layout_process more robust

Tom Haynes (2):
  pNFS/flexfiles: When checking for available DSes, conditionally check
    for MDS io
  pNFS/flexfiles: When initing reads or writes, we might have to retry
    connecting to DSes

Trond Myklebust (1):
  pNFS/flexfile: Fix erroneous fall back to read/write through the MDS

 fs/nfs/callback_proc.c                    |   3 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    |  63 ++++---
 fs/nfs/flexfilelayout/flexfilelayout.h    |   1 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  32 +++-
 fs/nfs/nfs42proc.c                        |   2 +-
 fs/nfs/nfs4proc.c                         | 120 +++++-------
 fs/nfs/nfs4trace.h                        |  10 +-
 fs/nfs/pnfs.c                             | 300 +++++++++++++++++-------------
 fs/nfs/pnfs.h                             |  14 +-
 include/linux/errno.h                     |   1 +
 include/linux/nfs4.h                      |   2 +
 include/linux/nfs_xdr.h                   |   2 -
 12 files changed, 299 insertions(+), 251 deletions(-)

-- 
2.5.5

