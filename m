Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:40349 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaEATOh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 15:14:37 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so889075igb.5
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 12:14:37 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 0/3] nfs: get rid of nfs_pgio_data, related cleanup
Date: Thu,  1 May 2014 15:14:50 -0400
Message-Id: <1398971693-82399-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd like to know what people think of this proposed cleanup - it is to be
applied on top of the "pgio" branch at:

 git://git.linux-nfs.org/projects/dros/linux-nfs.git

The basic idea is that we no longer need a separate nfs_pgio_data structure,
because the nfs_pgio_header structure always has one - and only one.

I know this changes a lot of files, but I think now is the time to do this,
as we have to test everything anyways due to my subpage work and Anna's
pgio cleanup.

I should note that there is little chance we'll ever go back to having more
than one nfs_pgio_data per nfs_pgio_header - since the nfs_page subpage
splitting work allows us to describe arbitrary ranges at that level.

I think I can go a bit further by getting rid of the pgio_header refcnt.
I'll look closer at this soon...

 -dros

Weston Andros Adamson (3):
  nfs: move nfs_pgio_data and remove nfs_rw_header
  nfs: rename members of nfs_pgio_data
  nfs: merge nfs_pgio_data into _header

 fs/nfs/blocklayout/blocklayout.c |  99 +++++++++++----------
 fs/nfs/direct.c                  |   8 +-
 fs/nfs/internal.h                |  10 +--
 fs/nfs/nfs3proc.c                |  21 +++--
 fs/nfs/nfs4_fs.h                 |   6 +-
 fs/nfs/nfs4filelayout.c          | 169 +++++++++++++++++------------------
 fs/nfs/nfs4proc.c                | 105 +++++++++++-----------
 fs/nfs/nfs4trace.h               |  28 +++---
 fs/nfs/objlayout/objio_osd.c     |  24 +++--
 fs/nfs/objlayout/objlayout.c     |  81 ++++++++---------
 fs/nfs/objlayout/objlayout.h     |   8 +-
 fs/nfs/pageio.c                  | 186 ++++++++++++++++-----------------------
 fs/nfs/pnfs.c                    |  96 ++++++++------------
 fs/nfs/pnfs.h                    |  10 +--
 fs/nfs/proc.c                    |  27 +++---
 fs/nfs/read.c                    |  48 +++++-----
 fs/nfs/write.c                   |  65 +++++++-------
 include/linux/nfs_fs.h           |   2 +-
 include/linux/nfs_page.h         |  13 +--
 include/linux/nfs_xdr.h          |  31 +++----
 20 files changed, 489 insertions(+), 548 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

