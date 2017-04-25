Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37436 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951210AbdDYUer (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Apr 2017 16:34:47 -0400
Received: by mail-it0-f43.google.com with SMTP id x188so83652570itb.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 13:34:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] pNFS bugfixes
Date: Tue, 25 Apr 2017 16:34:41 -0400
Message-Id: <20170425203443.37006-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2 patches fo fix issues with pNFS.

Trond Myklebust (2):
  pNFS: Ensure we check layout segment validity in the pg_init()
    callback
  pNFS: Fix use after free issues in pnfs_do_read()

 fs/nfs/filelayout/filelayout.c         |  2 ++
 fs/nfs/flexfilelayout/flexfilelayout.c |  2 ++
 fs/nfs/pnfs.c                          | 29 ++++++++++++++++++++++++++---
 fs/nfs/pnfs.h                          |  1 +
 4 files changed, 31 insertions(+), 3 deletions(-)

-- 
2.9.3

