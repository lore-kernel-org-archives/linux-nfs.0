Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:38816 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755526AbcH3AEg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 20:04:36 -0400
Received: by mail-it0-f48.google.com with SMTP id g62so11917695ith.1
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 17:04:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] NFSv4 backchannel improvements
Date: Mon, 29 Aug 2016 20:03:46 -0400
Message-Id: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add functionality to allow multiple client backchannel threads and
allow tuning of the advertised backchannel slot table size.

Note: the very first patch is actually a fix for an existing Oopsable
condition, and so should probably be pushed into Linux 4.8...

Trond Myklebust (6):
  NFSv4.x: Fix a refcount leak in nfs_callback_up_net
  NFSv4.x: Set up struct svc_serv_ops for the callback channel
  SUNRPC: Initialise struct svc_serv backchannel fields during
    __svc_create()
  NFSv4.x: Fix up the global tracking of the callback server
  NFSv4.x: Switch to using svc_set_num_threads() to manage the callback
    threads
  NFSv4.x: Add kernel parameter to control the callback server

 Documentation/kernel-parameters.txt |  12 ++++
 fs/nfs/callback.c                   | 137 +++++++++++++++---------------------
 fs/nfs/callback.h                   |   3 +
 fs/nfs/nfs4_fs.h                    |   1 +
 fs/nfs/nfs4proc.c                   |   7 +-
 fs/nfs/nfs4session.h                |   1 +
 fs/nfs/super.c                      |  10 +++
 net/sunrpc/svc.c                    |  17 +++++
 8 files changed, 102 insertions(+), 86 deletions(-)

-- 
2.7.4

