Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33945 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760246AbdACSW6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jan 2017 13:22:58 -0500
Received: by mail-pg0-f65.google.com with SMTP id b1so34257945pgc.1
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jan 2017 10:22:50 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 0/2] wake_up_page cleanups
Date: Wed,  4 Jan 2017 04:22:32 +1000
Message-Id: <20170103182234.30141-1-npiggin@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I suggest getting acks for the nfs patch and merging these via
Andrew's tree.

Nicholas Piggin (2):
  nfs: no PG_private waiters remain, remove waker
  mm: un-export wake_up_page functions

 fs/nfs/write.c          |  2 --
 include/linux/pagemap.h | 12 ++----------
 mm/filemap.c            | 10 ++++++++--
 3 files changed, 10 insertions(+), 14 deletions(-)

-- 
2.11.0

