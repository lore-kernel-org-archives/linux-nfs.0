Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f42.google.com ([209.85.210.42]:42067 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab1KIPQz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2011 10:16:55 -0500
Received: by pzk2 with SMTP id 2so1945050pzk.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2011 07:16:54 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com
Subject: [PATCH 0/8] pnfsblock cleanup and fixes
Date: Wed,  9 Nov 2011 07:15:58 -0800
Message-Id: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Trond and Benny,

Bellow are some pnfsblock patches that I have tested for days. Most of them
are cleanup and small improvements. Only
[PATCH 2/8] pnfsblock: acquire im_lock in _preload_range
needs to go into stable.

Thanks,
Tao

Peng Tao (8):
  pnfsblock: cleanup bl_mark_sectors_init
  pnfsblock: acquire im_lock in _preload_range
  pnfsblock: move find lock page logic out of bl_write_pagelist
  pnfsblock: set read/write tk_status to pnfs_error
  pnfsblock: remove rpc_call_ops from struct parallel_io
  pnfsblock: clean up _add_entry
  pnfsblock: add im_extents to pnfs_inval_markings
  pnfsblock: alloc short extent before submit bio

 fs/nfs/blocklayout/blocklayout.c |  176 +++++++++++++++++++++++++-------------
 fs/nfs/blocklayout/blocklayout.h |   11 ++-
 fs/nfs/blocklayout/extents.c     |  146 ++++++++++++--------------------
 3 files changed, 180 insertions(+), 153 deletions(-)

