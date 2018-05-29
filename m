Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34981 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935213AbeE2PtB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 11:49:01 -0400
Received: by mail-io0-f193.google.com with SMTP id g1-v6so18168251iob.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 08:49:01 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id y14-v6sm16396515ioc.52.2018.05.29.08.48.59
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 08:48:59 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Various attribute revalidation fixups
Date: Tue, 29 May 2018 11:48:33 -0400
Message-Id: <20180529154838.12903-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A set of short patches to fix up various issues with the attribute
revalidation, particularly when holding a delegation.

Trond Myklebust (5):
  NFS: Fix up sillyrename()
  NFS: Set the force revalidate flag if the inode is not completely
    initialised
  NFS: Ensure we revalidate the inode correctly after remove or rename
  NFS: Ensure we revalidate the inode correctly after setacl
  NFS: Fix up nfs_post_op_update_inode() to force ctime updates

 fs/nfs/dir.c      | 18 ++++++++++++++----
 fs/nfs/inode.c    |  7 ++++++-
 fs/nfs/nfs4proc.c |  3 ++-
 fs/nfs/unlink.c   | 10 ++++++++++
 4 files changed, 32 insertions(+), 6 deletions(-)

-- 
2.17.0

