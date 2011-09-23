Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37156 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866Ab1IWBuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 21:50:24 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 00/10] pnfsblock fixes for 3.2
Date: Thu, 22 Sep 2011 21:50:07 -0400
Message-Id: <1316742617-14766-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Various pnfs client block layout driver bug fixes and improvements for Linux
3.2.  These are also available on the for-trond branch of my git repo at:
git://citi.umich.edu/projects/linux-pnfs-blk.git

Jim Rees (2):
  pnfsblock: fix return code confusion
  pnfsblock: fix size of upcall message

Peng Tao (8):
  SUNRPC/NFS: make rpc pipe upcall generic
  pnfsblock: add missing rpc_put_mount and path_put
  pnfs: make _set_lo_fail generic
  pnfsblock: init pg_bsize properly
  pnfs: recoalesce when ld write pagelist fails
  pnfs: recoalesce when ld read pagelist fails
  pnfsblock: fix NULL pointer dereference
  pnfsblock: fix writeback deadlock

 fs/nfs/blocklayout/blocklayout.c    |   78 ++++++++++++++++++++++-------------
 fs/nfs/blocklayout/blocklayout.h    |    4 +-
 fs/nfs/blocklayout/blocklayoutdev.c |   35 ++++------------
 fs/nfs/idmap.c                      |   25 +-----------
 fs/nfs/nfs4filelayout.c             |   19 +-------
 fs/nfs/pnfs.c                       |   52 ++++++++++++------------
 fs/nfs/pnfs.h                       |    5 +-
 fs/nfs/read.c                       |   12 +++++-
 fs/nfs/write.c                      |   25 +++++++++++-
 include/linux/sunrpc/rpc_pipe_fs.h  |    2 +
 net/sunrpc/auth_gss/auth_gss.c      |   24 +----------
 net/sunrpc/rpc_pipe.c               |   20 +++++++++
 12 files changed, 150 insertions(+), 151 deletions(-)

-- 
1.7.4.1

