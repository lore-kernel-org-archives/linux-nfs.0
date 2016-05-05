Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33402 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbcEESYz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 14:24:55 -0400
Received: by mail-qk0-f170.google.com with SMTP id n63so47743555qkf.0
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2016 11:24:55 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: hch@lst.de, Anna.Schumaker@netapp.com
Subject: [RFC PATCH 0/6] nfs: pnfs layout pipelining
Date: Thu,  5 May 2016 14:24:42 -0400
Message-Id: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

Jeff Layton (6):
  nfs: don't merge new ff lsegs with ones that have LAYOUTRETURN bit set
  nfs: record sequence in pnfs_layout_segment when it's created
  nfs: keep track of the return sequence number in pnfs_layout_hdr
  nfs4: only tear down lsegs that precede seqid in LAYOUTRETURN args
  nfs4: remove pointless setting of NFS_LAYOUT_RETURN_REQUESTED in
    flexfiles code
  nfs4: add kerneldoc header to nfs4_ff_layout_prepare_ds

 fs/nfs/callback_proc.c                    |  3 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    |  6 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 26 +++++++----
 fs/nfs/nfs42proc.c                        |  2 +-
 fs/nfs/nfs4proc.c                         |  5 ++-
 fs/nfs/pnfs.c                             | 71 +++++++++++++++++++++----------
 fs/nfs/pnfs.h                             |  5 ++-
 7 files changed, 78 insertions(+), 40 deletions(-)

-- 
2.5.5

