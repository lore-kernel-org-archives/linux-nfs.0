Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35265 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754882AbdDTVWf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 17:22:35 -0400
Received: by mail-io0-f196.google.com with SMTP id d203so21019693iof.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Apr 2017 14:22:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Cleanups after object layout driver removal
Date: Thu, 20 Apr 2017 17:22:29 -0400
Message-Id: <20170420212232.88086-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following cleanups apply on top of Christoph's patch to remove
the object layout driver.

Trond Myklebust (3):
  pNFS: Remove unused layout driver callbacks
  pNFS: Unexport pnfs_put_lseg_locked and _pnfs_return_layout
  pNFS: unexport nfs4_pnfs_v3_ds_connect_unload

 fs/nfs/nfs4xdr.c  | 17 ++++-------------
 fs/nfs/pnfs.c     |  2 --
 fs/nfs/pnfs.h     |  5 -----
 fs/nfs/pnfs_nfs.c |  1 -
 4 files changed, 4 insertions(+), 21 deletions(-)

-- 
2.9.3

