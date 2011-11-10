Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60574 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933924Ab1KJP0H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 10:26:07 -0500
Received: by eye27 with SMTP id 27so2495734eye.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 07:26:05 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com
Subject: [PATCH-v2 0/7] pnfsblock cleanup and fixes
Date: Thu, 10 Nov 2011 07:25:21 -0800
Message-Id: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Trond and Benny,

These are updated v2 of the pnfsblock patches and all Benny's comments are addressed.

Thanks,
Tao

Peng Tao (8):
  pnfsblock: cleanup bl_mark_sectors_init
  pnfsblock: acquire im_lock in _preload_range
  pnfsblock: move find lock page logic out of bl_write_pagelist
  pnfsblock: set read/write tk_status to pnfs_error
  pnfsblock: remove rpc_call_ops from struct parallel_io
  pnfsblock: clean up _add_entry
  pnfsblock: alloc short extent before submit bio
  pnfsblock: release lock when freeing block_dev

 fs/nfs/blocklayout/blocklayout.c |  176 +++++++++++++++++++++++++-------------
 fs/nfs/blocklayout/blocklayout.h |   12 ++-
 fs/nfs/blocklayout/extents.c     |  157 ++++++++++++++--------------------
 3 files changed, 192 insertions(+), 153 deletions(-)

