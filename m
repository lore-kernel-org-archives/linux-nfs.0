Return-Path: <SRS0=1lUO=RV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 597C9C4360F
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 17:00:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3574E205F4
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 17:00:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727540AbfCRRAg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Mar 2019 13:00:36 -0400
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:37872 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727142AbfCRRAf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Mar 2019 13:00:35 -0400
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4B3F01650;
        Mon, 18 Mar 2019 10:00:35 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id E7E473F614;
        Mon, 18 Mar 2019 10:00:33 -0700 (PDT)
From:   Catalin Marinas <catalin.marinas@arm.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-kernel@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, stable@vger.kernel.org,
        NeilBrown <neilb@suse.com>
Subject: [PATCH] NFS: Fix nfs4_lock_state refcounting in nfs4_alloc_{lock,unlock}data()
Date:   Mon, 18 Mar 2019 17:00:28 +0000
Message-Id: <20190318170028.61423-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit 7b587e1a5a6c ("NFS: use locks_copy_lock() to copy locks.")
changed the lock copying from memcpy() to the dedicated
locks_copy_lock() function. The latter correctly increments the
nfs4_lock_state.ls_count via nfs4_fl_copy_lock(), however, this refcount
has already been incremented in the nfs4_alloc_{lock,unlock}data().
Kmemleak subsequently reports an unreferenced nfs4_lock_state object as
below (arm64 platform):

unreferenced object 0xffff8000fce0b000 (size 256):
  comm "systemd-sysuser", pid 1608, jiffies 4294892825 (age 32.348s)
  hex dump (first 32 bytes):
    20 57 4c fb 00 80 ff ff 20 57 4c fb 00 80 ff ff   WL..... WL.....
    00 57 4c fb 00 80 ff ff 01 00 00 00 00 00 00 00  .WL.............
  backtrace:
    [<000000000d15010d>] kmem_cache_alloc+0x178/0x208
    [<00000000d7c1d264>] nfs4_set_lock_state+0x124/0x1f0
    [<000000009c867628>] nfs4_proc_lock+0x90/0x478
    [<000000001686bd74>] do_setlk+0x64/0xe8
    [<00000000e01500d4>] nfs_lock+0xe8/0x1f0
    [<000000004f387d8d>] vfs_lock_file+0x18/0x40
    [<00000000656ab79b>] do_lock_file_wait+0x68/0xf8
    [<00000000f17c4a4b>] fcntl_setlk+0x224/0x280
    [<0000000052a242c6>] do_fcntl+0x418/0x730
    [<000000004f47291a>] __arm64_sys_fcntl+0x84/0xd0
    [<00000000d6856e01>] el0_svc_common+0x80/0xf0
    [<000000009c4bd1df>] el0_svc_handler+0x2c/0x80
    [<00000000b1a0d479>] el0_svc+0x8/0xc
    [<0000000056c62a0f>] 0xffffffffffffffff

This patch removes the original refcount_inc(&lsp->ls_count) that was
paired with the memcpy() lock copying.

Fixes: 7b587e1a5a6c ("NFS: use locks_copy_lock() to copy locks.")
Cc: <stable@vger.kernel.org> # 5.0.x-
Cc: NeilBrown <neilb@suse.com>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 fs/nfs/nfs4proc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4dbb0ee23432..6d2812a39287 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6301,7 +6301,6 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.seqid = seqid;
 	p->res.seqid = seqid;
 	p->lsp = lsp;
-	refcount_inc(&lsp->ls_count);
 	/* Ensure we don't close file until we're done freeing locks! */
 	p->ctx = get_nfs_open_context(ctx);
 	p->l_ctx = nfs_get_lock_context(ctx);
@@ -6526,7 +6525,6 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->lsp = lsp;
 	p->server = server;
-	refcount_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
 	locks_init_lock(&p->fl);
 	locks_copy_lock(&p->fl, fl);
