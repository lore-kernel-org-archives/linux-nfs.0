Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f67.google.com ([209.85.160.67]:39957 "EHLO
        mail-pl0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725896AbeHMG0x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2018 02:26:53 -0400
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [BUG] fs: nfs: pnfs_nfs: a possible sleep-in-atomic-context bug in
 pnfs_generic_recover_commit_reqs()
Message-ID: <6e0b1c99-bfe5-29a9-51b1-1c71fe0b91b4@gmail.com>
Date: Mon, 13 Aug 2018 11:46:28 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel may sleep with holding a spinlock.

The function call paths (from bottom to top) in Linux-4.16 are:

[FUNC] mutex_lock_nested
fs/nfs/write.c, 1045: mutex_lock_nested in nfs_scan_commit_list
fs/nfs/pnfs_nfs.c, 145: nfs_scan_commit_list in 
pnfs_generic_recover_commit_reqs
fs/nfs/pnfs_nfs.c, 154: spin_lock in pnfs_generic_recover_commit_reqs

I do not find a good way to fix, so I only report.
This is found by my static analysis tool (DSAC).


Thanks,
Jia-Ju Bai
