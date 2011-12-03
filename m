Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41985 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab1K2QDm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 11:03:42 -0500
Received: by vbbfc26 with SMTP id fc26so4872183vbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 08:03:41 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] pnfsblock patches
Date: Fri,  2 Dec 2011 20:46:14 -0800
Message-Id: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Trond,

Following are some bugfix and improvements for blocklayout driver. All have been
sent to the list before and have been tested for several weeks.

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

