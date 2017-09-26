Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35525 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965122AbdIZHQS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Sep 2017 03:16:18 -0400
From: Corentin Labbe <clabbe.montjoie@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 0/3] nfs_common: misc patchs
Date: Tue, 26 Sep 2017 09:14:04 +0200
Message-Id: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello

The origin of this series is a build warning fix.
But reading the code show me two other possible patch.

Regards

Corentin Labbe (3):
  nfs_common: fix build warning in grace.c
  nfs_common: move locks_in_grace comment at the right place
  nfs_common: convert int to bool

 fs/nfs_common/grace.c | 24 ++++++++++++------------
 include/linux/fs.h    |  4 ++--
 2 files changed, 14 insertions(+), 14 deletions(-)

-- 
2.13.5

