Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33390 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752373AbdEPNge (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 May 2017 09:36:34 -0400
Received: by mail-io0-f196.google.com with SMTP id m4so14442537ioe.0
        for <linux-nfs@vger.kernel.org>; Tue, 16 May 2017 06:36:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Improvements to page writeback commit policy
Date: Tue, 16 May 2017 09:36:25 -0400
Message-Id: <20170516133628.16525-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches are intended to smooth out the page writeback
performance by ensuring that we commit the data earlier on the server.

We assume that if something is starting writeback on the pages, then
that process wants to commit the data as soon as possible, whether it
is an application or just the background flush process.
We also assume that for streaming type processes, we don't want to pause
the I/O in order to commit, so we don't want to rely on a counter of
in-flight I/O to the entire inode going to zero.

We therefore set up a monitor that counts the number of in-flight
writes for each call to nfs_writepages(). Once all the writes to that
call to nfs_writepages has completed, we send the commit. Note that this
mirrors the behaviour for O_DIRECT writes, where we similarly track the
in-flight writes on a per-call basis.

Trond Myklebust (3):
  NFS: Remove unused fields in the page I/O structures
  NFS: Ensure we commit after writeback is complete
  NFS: Fix commit policy for non-blocking calls to nfs_write_inode()

 fs/nfs/pagelist.c        |  5 ++--
 fs/nfs/write.c           | 59 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_page.h |  2 +-
 include/linux/nfs_xdr.h  |  3 ++-
 4 files changed, 64 insertions(+), 5 deletions(-)

-- 
2.9.4

