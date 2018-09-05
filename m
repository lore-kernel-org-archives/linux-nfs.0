Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36393 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727575AbeIEX4d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:33 -0400
Received: by mail-it0-f66.google.com with SMTP id u13-v6so10990758iti.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:24:59 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.24.52
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:24:52 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] Misc NFS + pNFS performance enhancements
Date: Wed,  5 Sep 2018 15:23:53 -0400
Message-Id: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fallout from a bunch of flame graphs...

Trond Myklebust (7):
  pNFS: Don't zero out the array in nfs4_alloc_pages()
  pNFS: Don't allocate more pages than we need to fit a layoutget
    response
  NFS: Convert lookups of the lock context to RCU
  NFS: Simplify internal check for whether file is open for write
  NFS: Convert lookups of the open context to RCU
  NFSv4: Convert open state lookup to use RCU
  NFSv4: Convert struct nfs4_state to use refcount_t

 fs/nfs/delegation.c                    | 11 ++--
 fs/nfs/filelayout/filelayout.c         |  1 +
 fs/nfs/flexfilelayout/flexfilelayout.c |  1 +
 fs/nfs/inode.c                         | 70 +++++++++++---------------
 fs/nfs/nfs4_fs.h                       |  3 +-
 fs/nfs/nfs4proc.c                      | 38 ++++++++++----
 fs/nfs/nfs4state.c                     | 32 ++++++------
 fs/nfs/pnfs.c                          | 16 ++++--
 fs/nfs/pnfs.h                          |  1 +
 include/linux/nfs_fs.h                 |  2 +
 10 files changed, 98 insertions(+), 77 deletions(-)

-- 
2.17.1
