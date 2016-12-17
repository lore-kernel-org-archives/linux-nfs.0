Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33032 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbcLQS1P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:15 -0500
Received: by mail-io0-f175.google.com with SMTP id d9so123315893ioe.0
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:15 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] NFS client attribute cache performance improvements
Date: Sat, 17 Dec 2016 13:27:02 -0500
Message-Id: <20161217182711.10643-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patchset makes the largest difference w.r.t. NFSv4, where
we don't always ask for the full set of attributes from the server, however
there are also some tidbits for NFSv3.

With this patchset, running xfstests over NFSv4.1 shows the following
improvement in execution times:

Generic/074 now 264s, was 344s
Generic/075 now 15s was 26s
Generic/089 now 178s was 236s
Generic/112 now 14s was 25s
Generic/113 now 14s was 20s
Generic/127 now 206s was 223s
Generic/133 now 85s was 118s
Generic/247 now 27s was 43s

I saw no statistically significant performance regressions (and no functional
regressions).

For nfsstats, the client shows a significant decrease in % GETATTR and
% LOOKUP calls on the same workloads.

For 2 runs of xfstests, the numbers are:
GETATTR: now 1456511, was 2168740
LOOKUP: now 301073, was 545571
ACCESS: now 137211 was 139447


Trond Myklebust (9):
  NFSv4: Don't invalidate the directory twice
  NFSv4: Update the attribute cache info in update_changeattr
  NFSv4: Don't discard the attributes returned by asynchronous
    DELEGRETURN
  NFS: Don't revalidate the file on close if we hold a delegation
  NFS: Clean up cache validity checking
  NFS: Only look at the change attribute cache state in
    nfs_weak_revalidate()
  NFS: Fix and clean up the access cache validity checking
  NFS: Remove unused function nfs_revalidate_inode_rcu()
  NFS: Clean up nfs_attribute_timeout()

 fs/nfs/dir.c           | 23 +++++++++--------
 fs/nfs/file.c          | 12 +--------
 fs/nfs/inode.c         | 68 ++++++++++++++++++++++++++++++--------------------
 fs/nfs/internal.h      |  1 +
 fs/nfs/nfs4proc.c      | 17 +++++++++----
 include/linux/nfs_fs.h |  2 --
 6 files changed, 67 insertions(+), 56 deletions(-)

-- 
2.9.3

