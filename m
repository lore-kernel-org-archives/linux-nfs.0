Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33765 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752021AbcLAWTZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:25 -0500
Received: by mail-io0-f177.google.com with SMTP id j65so450614692iof.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/26] pNFS updates for v4.10
Date: Thu,  1 Dec 2016 17:18:56 -0500
Message-Id: <20161201221922.15657-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Highlights include:

- Stable patch to fix a deadlock between resends and LAYOUTRETURN
- Stable patch to not clear the layout stateid if LAYOUTRETURN is outstanding
- Stable patch to clear NFS_LAYOUT_RETURN_REQUESTED when invalidating the layout
- Stable patch to not send LAYOUTGET until the layout error has been reported

- Patches to embed LAYOUTRETURN operations in the COMPOUNDs for CLOSE and
  DELEGRETURN. This fixes a set of races for the case where the server
  implements return-on-close, and where the client and server disagree
  on whether or not the layout was returned due to parallel OPEN and CLOSE
  calls.

Trond Myklebust (26):
  pNFS: Fix a deadlock between read resends and layoutreturn
  pNFS: Don't clear the layout stateid if a layout return is outstanding
  pNFS: Clear NFS_LAYOUT_RETURN_REQUESTED when invalidating the layout
    stateid
  pNFS: Force a retry of LAYOUTGET if the stateid doesn't match our
    cache
  pNFS: On error, do not send LAYOUTGET until the LAYOUTRETURN has
    completed
  pNFS: Fix race in pnfs_wait_on_layoutreturn
  pNFS: consolidate the different range intersection tests
  pNFS: Delay getting the layout header in CB_LAYOUTRECALL handlers
  pNFS: Do not free layout segments that are marked for return
  NFSv4: Ignore LAYOUTRETURN result if the layout doesn't match or is
    invalid
  pNFS: Remove spurious wake up in pnfs_layout_remove_lseg()
  pNFS: Skip checking for return-on-close if the layout is invalid
  pNFS: Get rid of unnecessary layout parameter in encode_layoutreturn
    callback
  pNFS: Don't mark layout segments invalid on layoutreturn in pnfs_roc
  NFSv4: Fix missing operation accounting in NFS4_dec_delegreturn_sz
  NFSv4: Add encode/decode of the layoutreturn op in CLOSE
  NFSv4: Add encode/decode of the layoutreturn op in DELEGRETURN
  pNFS: Clean up - add a helper to initialise struct layoutreturn_args
  pNFS: Enable layoutreturn operation for return-on-close
  pNFS: Prevent unnecessary layoutreturns after delegreturn
  pNFS: Clear all layout segment state in
    pnfs_mark_layout_stateid_invalid
  pNFS: Fix bugs in _pnfs_return_layout
  pNFS: Sync the layout state bits in pnfs_cache_lseg_for_layoutreturn
  pNFS: Don't mark the layout as freed if the last lseg is marked for
    return
  pNFS: Wait on outstanding layoutreturns to complete in pnfs_roc()
  pNFS: Skip invalid stateids when doing a bulk destroy

 fs/nfs/callback_proc.c                    |  99 +++++---
 fs/nfs/flexfilelayout/flexfilelayout.c    |   8 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  33 +--
 fs/nfs/nfs4proc.c                         | 134 +++++++----
 fs/nfs/nfs4xdr.c                          |  45 +++-
 fs/nfs/objlayout/objlayout.c              |   4 +-
 fs/nfs/objlayout/objlayout.h              |   1 -
 fs/nfs/pnfs.c                             | 381 ++++++++++++++++++------------
 fs/nfs/pnfs.h                             |  72 ++++--
 include/linux/nfs_xdr.h                   |   6 +
 10 files changed, 506 insertions(+), 277 deletions(-)

-- 
2.9.3

