Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:42866 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751539AbeCTUx4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:53:56 -0400
Received: by mail-io0-f196.google.com with SMTP id d5so4043287iob.9
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:53:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] Finer grained attribute checking for NFSv4.x
Date: Tue, 20 Mar 2018 16:53:26 -0400
Message-Id: <20180320205332.94132-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series allows the NFS client to track attribute information
on a more fine grained basis, so that we do not end up worrying about
the validity of the mode, owner, group etc information when asked about
the timestamps.
Basically, this means that the NFSv4 cache consistency data is tracked
separately from the other attribute data, allowing it to be revalidated
by the cache consistency GETATTR operations.

Trond Myklebust (6):
  NFS: Convert NFS_INO_INVALID flags to unsigned long
  NFS: Don't force a revalidation of all attributes if change is missing
  NFS: Don't redirty the attribute cache in nfs_wcc_update_inode()
  NFS: Don't force unnecessary cache invalidation in nfs_update_inode()
  NFS: More fine grained attribute tracking
  NFSv4: Ignore change attribute invalidations if we hold a delegation

 fs/nfs/dir.c           |   4 +-
 fs/nfs/inode.c         | 132 ++++++++++++++++++++++++++++---------------------
 fs/nfs/nfs4proc.c      |   7 ++-
 fs/nfs/write.c         |   7 ++-
 include/linux/nfs_fs.h |  35 ++++++++-----
 5 files changed, 111 insertions(+), 74 deletions(-)

-- 
2.14.3

