Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f193.google.com ([209.85.222.193]:47028 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726405AbeI2C2n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2018 22:28:43 -0400
Received: by mail-qk1-f193.google.com with SMTP id q12-v6so4594501qkl.13
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2018 13:03:23 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Stan Hu <stanhu@gmail.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Fix NFSv4 lookup revalidation
Date: Fri, 28 Sep 2018 16:02:55 -0400
Message-Id: <20180928200258.68552-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch series attempts to address the issues raised by
Stan Hu around NFSv4 lookup revalidation.

The first patch in the series should, in principle suffice to address
the exact issue raised by Stan, however when looking at the
implementation of nfs4_lookup_revalidate(), it becomes clear that we're
not doing enough to revalidate the dentry itself when performing NFSv4.1
opens either.

Trond Myklebust (3):
  NFS: Fix dentry revalidation on NFSv4 lookup
  NFS: Refactor nfs_lookup_revalidate()
  NFSv4: Fix lookup revalidate of regular files

 fs/nfs/dir.c      | 295 +++++++++++++++++++++++++---------------------
 fs/nfs/nfs4proc.c |  15 ++-
 2 files changed, 174 insertions(+), 136 deletions(-)

-- 
2.17.1
