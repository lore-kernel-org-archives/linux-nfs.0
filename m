Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35773 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcLBOVj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 09:21:39 -0500
Received: by mail-io0-f196.google.com with SMTP id h133so8811751ioe.2
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 06:21:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] Readdirplus performance improvements for 4.10
Date: Fri,  2 Dec 2016 09:21:32 -0500
Message-Id: <20161202142135.11515-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up the regression introduced by commit 311324ad1713, and then
improve the READDIRPLUS hinting.

Trond Myklebust (3):
  NFS: Fix a performance regression in readdir
  NFS: Be more targeted about readdirplus use when doing
    lookup/revalidation
  NFS: Allow getattr to also report readdirplus cache hits

 fs/nfs/dir.c      | 46 +++++++++++++++++++++-------------------------
 fs/nfs/inode.c    | 21 +++++++++++++++++----
 fs/nfs/internal.h |  1 +
 3 files changed, 39 insertions(+), 29 deletions(-)

-- 
2.9.3

