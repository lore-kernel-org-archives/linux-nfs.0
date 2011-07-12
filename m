Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55415 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107Ab1GLTaF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/8] pNFS read/write cleanup
Date: Tue, 12 Jul 2011 15:29:46 -0400
Message-Id: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following cleanups apply on top of the nfs-for-next branch, and is
designed to allow the objects and blocks code to use different read/write
block sizes than the write-through-MDS.

It also pushes a lot of the pNFS code back down into pnfs.c where it
belongs...

Cheers
  Trond

Trond Myklebust (8):
  NFS: Clean up nfs_read_rpcsetup and nfs_write_rpcsetup
  NFS: Clean up: split out the RPC transmission from
    nfs_pagein_multi/one
  NFS: Cache rpc_ops in struct nfs_pageio_descriptor
  NFS: Use the nfs_pageio_descriptor->pg_bsize in the read/write
    request
  NFS: Allow the nfs_pageio_descriptor to signal that a re-coalesce is
    needed
  NFS: Move the pnfs read code into pnfs.c
  NFS: Move the pnfs write code into pnfs.c
  NFS: Clean up - simplify the switch to read/write-through-MDS

 fs/nfs/internal.h            |   12 +++--
 fs/nfs/nfs4filelayout.c      |    9 ++--
 fs/nfs/objlayout/objio_osd.c |    4 +-
 fs/nfs/pagelist.c            |   57 +++++++++++++++++++-
 fs/nfs/pnfs.c                |  118 ++++++++++++++++++++++++++++++++++++++--
 fs/nfs/pnfs.h                |   20 +------
 fs/nfs/read.c                |  121 ++++++++++++++++++++++--------------------
 fs/nfs/write.c               |  119 +++++++++++++++++++++++------------------
 include/linux/nfs_page.h     |    8 +--
 include/linux/nfs_xdr.h      |    2 +
 10 files changed, 317 insertions(+), 153 deletions(-)

-- 
1.7.6

