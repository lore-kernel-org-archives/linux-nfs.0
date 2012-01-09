Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:39350 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153Ab2AIQCw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 11:02:52 -0500
Received: by ggdk6 with SMTP id k6so1614395ggd.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jan 2012 08:02:52 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu
Subject: [PATCH 0/9] pnfsblock: patches for 3.3
Date: Tue, 10 Jan 2012 00:02:10 +0800
Message-Id: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

These are blocklayout patches for 3.3. All have been sent to list before and merged by Benny.

Patches can also be found at http://github.com/bergwolf/linux.git for-trond-3.3

Thanks,
Tao

Peng Tao (9):
  pnfsblock: cleanup bl_mark_sectors_init
  pnfsblock: acquire im_lock in _preload_range
  pnfsblock: move find lock page logic out of bl_write_pagelist
  pnfsblock: set read/write tk_status to pnfs_error
  pnfsblock: remove rpc_call_ops from struct parallel_io
  pnfsblock: clean up _add_entry
  pnfsblock: alloc short extent before submit bio
  pnfsblock: don't spinlock when freeing block_dev
  pnfsblock: limit bio page count

 fs/nfs/blocklayout/blocklayout.c |  202 ++++++++++++++++++++++++-------------
 fs/nfs/blocklayout/blocklayout.h |   12 ++-
 fs/nfs/blocklayout/extents.c     |  176 ++++++++++++++-------------------
 3 files changed, 215 insertions(+), 175 deletions(-)

