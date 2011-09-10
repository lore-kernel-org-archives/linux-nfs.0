Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:51965 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933513Ab1IJRli (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Sep 2011 13:41:38 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 0/3] pnfs private workqueue, and two cleanups
Date: Sat, 10 Sep 2011 13:41:32 -0400
Message-Id: <1315676495-3689-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These have been sent to the list previously, and I believe are
uncontroversial, but have not shown up on your pnfs-all-latest branch.

Peng Tao (3):
  SUNRPC/NFS: make rpc pipe upcall generic
  pNFS: introduce pnfs private workqueue
  pNFS: make _set_lo_fail generic

 fs/nfs/blocklayout/blocklayout.c    |   36 +++++++++-----------
 fs/nfs/blocklayout/blocklayout.h    |    2 -
 fs/nfs/blocklayout/blocklayoutdev.c |   22 ------------
 fs/nfs/idmap.c                      |   25 +-------------
 fs/nfs/nfs4filelayout.c             |   19 ++---------
 fs/nfs/objlayout/objio_osd.c        |    8 ++++
 fs/nfs/objlayout/objlayout.c        |    4 +-
 fs/nfs/pnfs.c                       |   64 ++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                       |    5 +++
 include/linux/sunrpc/rpc_pipe_fs.h  |    2 +
 net/sunrpc/auth_gss/auth_gss.c      |   24 +------------
 net/sunrpc/rpc_pipe.c               |   20 +++++++++++
 12 files changed, 122 insertions(+), 109 deletions(-)

-- 
1.7.4.1

