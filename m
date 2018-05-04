Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:44876 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbeEDUW6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 16:22:58 -0400
Received: by mail-qt0-f193.google.com with SMTP id d3-v6so28982269qtp.11
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2018 13:22:58 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] NFS: A few small NFSv4 cleanups
Date: Fri,  4 May 2018 16:22:47 -0400
Message-Id: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches are a few cleanups I noticed while poking through the
code.  The first two move calls to nfs4_state_protect() into the v4
module and the last three are cleanups to the nfs4_call_sync() process.

Thoughts?
Anna

Anna Schumaker (5):
  NFS: Move call to nfs4_state_protect_write() to nfs4_write_setup()
  NFS: Move call to nfs4_state_protect() to nfs4_commit_setup()
  NFS: Pass "privileged" value to nfs4_init_sequence()
  NFS: Pass "privileged" value to nfs4_call_sync()
  NFS: Combine nfs4_call_sync() with nfs4_call_sync_sequence()

 fs/nfs/nfs3proc.c       |   6 +-
 fs/nfs/nfs42proc.c      |  10 +--
 fs/nfs/nfs4_fs.h        |   4 +-
 fs/nfs/nfs4proc.c       | 174 +++++++++++++++++-----------------------
 fs/nfs/proc.c           |   6 +-
 fs/nfs/write.c          |  10 +--
 include/linux/nfs_xdr.h |   6 +-
 7 files changed, 94 insertions(+), 122 deletions(-)

-- 
2.17.0

