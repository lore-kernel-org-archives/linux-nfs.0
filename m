Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33964 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbdGLXLF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 19:11:05 -0400
Received: by mail-it0-f66.google.com with SMTP id o202so4451940itc.1
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 16:11:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] pNFS/NFS COMMIT fixups
Date: Wed, 12 Jul 2017 19:10:55 -0400
Message-Id: <20170712231059.32293-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2: Fix a bug in "NFS: Fix another COMMIT race in pNFS"

Trond Myklebust (4):
  NFS: Fix a COMMIT race in pNFS
  NFS: Fix another COMMIT race in pNFS
  pNFS/flexfiles: Handle expired layout segments in
    ff_layout_initiate_commit()
  Revert commit 722f0b891198 ("pNFS: Don't send COMMITs to the DSes
    if...")

 fs/nfs/flexfilelayout/flexfilelayout.c |  4 ++++
 fs/nfs/pnfs_nfs.c                      | 24 +++++++++++++-----------
 2 files changed, 17 insertions(+), 11 deletions(-)

-- 
2.13.0

