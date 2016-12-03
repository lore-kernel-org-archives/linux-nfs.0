Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33358 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f172.google.com with SMTP id j65so538238092iof.0
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:29 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/10] Add layoutstats to the flexfiles layoutreturn
Date: Sat,  3 Dec 2016 15:57:15 -0500
Message-Id: <20161203205725.12961-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patchset applies on top of my current linux-next branch,
and contains updates to allow the client to piggyback layoutstats in
the flexfiles layoutreturn (as per spec).
This is mainly useful when running workloads that do I/O on lots of
small or medium sized files, which are rarely kept open for long
enough to send a standalone layoutstat.

Trond Myklebust (10):
  pNFS/flexfiles: Don't attempt to send layoutstats if there are no
    entries
  pNFS/flexfiles: Only send layoutstats updates for mirrors that were
    updated
  NFSv4: Add a generic structure for managing layout-private information
  pNFS: Allow layout drivers to manage private data in struct
    nfs4_layoutreturn
  pNFS: Add a layoutreturn callback to performa layout-private setup
  pNFS/flexfiles: Refactor encoding of the layoutreturn payload
  pNFS/flexfiles: Clean up layoutstats
  NFS: Fix up read of mirror stats
  pNFS/flexfiles: Minor refactoring before adding iostats to
    layoutreturn
  pNFS/flexfiles: Support sending layoutstats in layoutreturn

 fs/nfs/flexfilelayout/flexfilelayout.c    | 236 ++++++++++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  20 ++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  78 ++++++++--
 fs/nfs/nfs42proc.c                        |   9 +-
 fs/nfs/nfs42xdr.c                         |   5 +-
 fs/nfs/nfs4proc.c                         |   6 +
 fs/nfs/nfs4xdr.c                          |   4 +-
 fs/nfs/pnfs.c                             |  15 +-
 fs/nfs/pnfs.h                             |   2 +-
 include/linux/nfs_xdr.h                   |  19 ++-
 10 files changed, 306 insertions(+), 88 deletions(-)

-- 
2.9.3

