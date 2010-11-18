Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:34696 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798Ab0KRKyP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 05:54:15 -0500
From: Peng Tao <lkml.bergwolf@gmail.com>
Date: Thu, 18 Nov 2010 18:53:54 +0800
Message-ID: <AANLkTimavN8px1k_Y65mFqsAsiLjgCh6vos22ZnZm+3Z@mail.gmail.com>
Subject: Question about nfs_page_async_flush assertion
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, all,

nfs_writepages calls into
write_cache_pages()->nfs_writepages_callback()->nfs_do_writepage()->nfs_page_async_flush(),
where it asserts BUG_ON(test_bit(PG_CLEAN, &req->wb_flags)).
My question is: how do we guarantee the request has PG_CLEAN flag set?

nfs_writepages calls:
 356         nfs_pageio_init_write(&pgio, inode, wb_priority(wbc));
 357         err = write_cache_pages(mapping, wbc,
nfs_writepages_callback, &pgio);
 358         nfs_pageio_complete(&pgio);

IIUC, the request will only be issued in nfs_pageio_complete() and
there nfs_write_rpcsetup() will call
nfs_writeback_release_full()->nfs_mark_request_commit() to set the
PG_CLEAN flag. If the request has not ever been issued before entering
nfs_writepages, the PG_CLEAN flag will not be set and the BUG_ON will
be triggered. Am I missing something?

-- 
Thanks,
-Bergwolf
