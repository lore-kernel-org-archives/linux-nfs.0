Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:32893 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbaHHPO5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:14:57 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so6358182ier.6
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:14:56 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 0/5] more pgio cleanup
Date: Fri,  8 Aug 2014 11:13:31 -0400
Message-Id: <1407510816-7002-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There was a mixup and this patchset was posted to Trond, but not the list -
and they've already made it to his testing branch. Oops!

"nfs: check wait_on_bit_lock err in page_group_lock" does not handle blocking
calls correctly and is fixed by a patch in patchset I just posted: 

  [PATCH 2/5] nfs: fix nonblocking calls to nfs_page_group_lock

I don't know if we want to apply it as a fixup or leave them as separate
patches..

Sorry, I did not intend to bypass the list! Have at them and I'll address
any issues ASAP.

Thanks,

 -dros


Weston Andros Adamson (5):
  nfs: check wait_on_bit_lock err in page_group_lock
  nfs: fix comment and add warn_on for PG_INODE_REF
  pnfs: find swapped pages on pnfs commit lists too
  pnfs: add pnfs_put_lseg_async
  nfs: clear_request_commit while holding i_lock

 fs/nfs/filelayout/filelayout.c | 36 +++++++++++++++++++--
 fs/nfs/pagelist.c              | 29 +++++++++++++----
 fs/nfs/pnfs.c                  | 17 ++++++++++
 fs/nfs/pnfs.h                  | 27 ++++++++++++++++
 fs/nfs/write.c                 | 72 +++++++++++++++++++++++++++---------------
 include/linux/nfs_page.h       |  4 +--
 6 files changed, 149 insertions(+), 36 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

