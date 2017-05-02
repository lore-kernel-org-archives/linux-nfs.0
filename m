Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34279 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdEBQiQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:38:16 -0400
Received: by mail-it0-f65.google.com with SMTP id c26so3208040itd.1
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:38:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Fix up a couple of issues around layout handling
Date: Tue,  2 May 2017 12:38:04 -0400
Message-Id: <20170502163812.6211-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main issue to be dealt with is a deadlock that can occur due to
an ABBA-type of situation between layoutget and layoutreturn.

Trond Myklebust (3):
  pNFS: Don't clear the layout return info if there are segments to
    return
  pNFS: Fix a deadlock when coalescing writes and returning the layout
  pNFS: Fix a typo in pnfs_generic_alloc_ds_commits

 fs/nfs/pnfs.c     | 10 +++++++---
 fs/nfs/pnfs_nfs.c |  2 +-
 2 files changed, 8 insertions(+), 4 deletions(-)

-- 
2.9.3

