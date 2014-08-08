Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:64975 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbaHHPBJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:01:09 -0400
Received: by mail-ig0-f180.google.com with SMTP id l13so1153169iga.13
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:01:08 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 0/5] nfs_page_group_lock cleanup
Date: Fri,  8 Aug 2014 11:00:52 -0400
Message-Id: <1407510057-6881-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches clean up some issues surrouding nfs_page_group_lock:

 - normalize wait/nonblock argument
 - make nonblocking calls really nonblocking
 - handle errors
 - ensure that we don't call blocking nfs_page_group_lock when holding the
   inode spinlock

This cleanup was inspired by Fengguang Wu's report that we were sleeping with
locks held in nfs_lock_and_join_requests.

Weston Andros Adamson (5):
  nfs: change nfs_page_group_lock argument
  nfs: fix nonblocking calls to nfs_page_group_lock
  nfs: use blocking page_group_lock in add_request
  nfs: fix error handling in lock_and_join_requests
  nfs: don't sleep with inode lock in lock_and_join_requests

 fs/nfs/pagelist.c        | 59 ++++++++++++++++++++++++++++++------------------
 fs/nfs/write.c           | 21 +++++++++++++----
 include/linux/nfs_page.h |  1 +
 3 files changed, 55 insertions(+), 26 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

