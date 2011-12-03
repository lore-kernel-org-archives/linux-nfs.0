Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:37048 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab1K2QJm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 11:09:42 -0500
Received: by qyk4 with SMTP id 4so1716521qyk.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 08:09:41 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com
Subject: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
Date: Fri,  2 Dec 2011 20:52:41 -0800
Message-Id: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Issuing layoutget at .pg_init will drop the IO size information and ask for 4KB
layout every time. However, the IO size information is very valuable for MDS to
determine how much layout it should return to client.

The patchset try to allow LD not to send layoutget at .pg_init but instead at
pnfs_do_multiple_writes. So that real IO size is preserved and sent to MDS.

Tests against a server that does not aggressively pre-allocate layout, shows
that the IO size informantion is really useful to block layout MDS.

The generic pnfs layer changes are trival to file layout and object as long as
they still send layoutget at .pg_init.

iozone cmd:
./iozone -r 1m -s 4G -w -W -c -t 10 -i 0 -F /mnt/iozone.data.1 /mnt/iozone.data.2 /mnt/iozone.data.3 /mnt/iozone.data.4 /mnt/iozone.data.5 /mnt/iozone.data.6 /mnt/iozone.data.7 /mnt/iozone.data.8 /mnt/iozone.data.9 /mnt/iozone.data.10

Befor patch: around 12MB/s throughput
After patch: around 72MB/s throughput

Peng Tao (4):
  nfsv41: export pnfs_find_alloc_layout
  nfsv41: add and export pnfs_find_get_layout_locked
  nfsv41: get lseg before issue LD IO if pgio doesn't carry lseg
  pnfsblock: do ask for layout in pg_init

 fs/nfs/blocklayout/blocklayout.c |   54 ++++++++++++++++++++++++++-
 fs/nfs/pnfs.c                    |   74 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                    |    9 +++++
 3 files changed, 134 insertions(+), 3 deletions(-)

