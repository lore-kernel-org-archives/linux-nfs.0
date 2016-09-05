Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35717 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932294AbcIENqp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 09:46:45 -0400
Received: by mail-it0-f47.google.com with SMTP id e124so146841714ith.0
        for <linux-nfs@vger.kernel.org>; Mon, 05 Sep 2016 06:46:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] Fix LAYOUTGET/LAYOUTRETURN races
Date: Mon,  5 Sep 2016 09:45:58 -0400
Message-Id: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust (4):
  pNFS: Ensure LAYOUTGET and LAYOUTRETURN are properly serialised
  pNFS: Fix pnfs_set_layout_stateid() to clear NFS_LAYOUT_INVALID_STID
  pNFS: Clear out all layout segments if the server unsets
    lrp->res.lrs_present
  pNFS: Don't forget the layout stateid if there are outstanding
    LAYOUTGETs

 fs/nfs/nfs4proc.c |  9 ++++++---
 fs/nfs/pnfs.c     | 42 ++++++++++++++++++++++++------------------
 2 files changed, 30 insertions(+), 21 deletions(-)

-- 
2.7.4

