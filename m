Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58511 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245Ab2AJObK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jan 2012 09:31:10 -0500
Received: by iabz25 with SMTP id z25so964490iab.19
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2012 06:31:09 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu
Subject: [PATCH RESEND 0/9] pnfsblock patches for 3.3 post-rc1
Date: Tue, 10 Jan 2012 22:30:26 +0800
Message-Id: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

These are pnfsblock patches rebased on top of nfs-for-3.3. All patches were sent to list before and merged by Benny.

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

