Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35904 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031957AbdD2Sst (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Apr 2017 14:48:49 -0400
Received: by mail-io0-f194.google.com with SMTP id x86so15957638ioe.3
        for <linux-nfs@vger.kernel.org>; Sat, 29 Apr 2017 11:48:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] pNFS writeback fixes
Date: Sat, 29 Apr 2017 14:48:42 -0400
Message-Id: <20170429184845.58057-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up the pNFS flexfiles writeback code to respect the flag
FF_FLAGS_NO_IO_THRU_MDS.

Fix up the client to clear out requests that are queued for commit
if we are told the layout has been revoked or otherwise lost.

Trond Myklebust (3):
  pNFS/flexfiles: Fix up the ff_layout_write_pagelist failure path
  pNFS: Don't send COMMITs to the DSes if the server invalidated our
    layout
  pNFS: Ensure we commit the layout if it has been invalidated

 fs/nfs/flexfilelayout/flexfilelayout.c | 11 ++++++++---
 fs/nfs/nfs42proc.c                     |  1 +
 fs/nfs/nfs4proc.c                      |  1 +
 fs/nfs/pnfs.c                          | 17 ++++++++++++++++-
 fs/nfs/pnfs_nfs.c                      |  7 +++++++
 5 files changed, 33 insertions(+), 4 deletions(-)

-- 
2.9.3

