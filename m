Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36216 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935007AbdDZPzb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 11:55:31 -0400
Received: by mail-it0-f65.google.com with SMTP id x188so1011373itb.3
        for <linux-nfs@vger.kernel.org>; Wed, 26 Apr 2017 08:55:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 0/2] Fix the NFSv4 client callback channel shutdown
Date: Wed, 26 Apr 2017 11:55:25 -0400
Message-Id: <20170426155527.92213-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the problem reported by Kinglong, whereby the callback channel was
failing to shut down properly on umount.

Trond Myklebust (2):
  SUNRPC: Refactor svc_set_num_threads()
  NFSv4: Fix callback server shutdown

 fs/nfs/callback.c          |  24 +++++---
 include/linux/sunrpc/svc.h |   1 +
 net/sunrpc/svc.c           | 134 ++++++++++++++++++++++++++++++++-------------
 3 files changed, 113 insertions(+), 46 deletions(-)

-- 
2.9.3

