Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:40063 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727999AbeGaTGH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2018 15:06:07 -0400
Received: by mail-io0-f177.google.com with SMTP id l14-v6so13684550iob.7
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 10:24:49 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] Fix mkdir/rmdir() in NFSv4
Date: Tue, 31 Jul 2018 13:24:23 -0400
Message-Id: <20180731172426.6491-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v1:
  - bump/drop the nlink count on the parent dir when we mkdir/rmdir
v2:
  - Fix nlink changes on cross-directory renames
  - Mark the inode change attribute up to date in update_changeattr()

Trond Myklebust (3):
  NFSv4: bump/drop the nlink count on the parent dir when we mkdir/rmdir
  NFSv4: Detect nlink changes on cross-directory renames too
  NFSv4: Mark the inode change attribute up to date in
    update_changeattr()

 fs/nfs/nfs4proc.c | 80 +++++++++++++++++++++++++++++++++++++----------
 1 file changed, 63 insertions(+), 17 deletions(-)

-- 
2.17.1

