Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61083 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab1KSQxm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Nov 2011 11:53:42 -0500
Received: by ywt32 with SMTP id 32so3475125ywt.19
        for <linux-nfs@vger.kernel.org>; Sat, 19 Nov 2011 08:53:41 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com
Subject: [PATCH RFC 0/4] nfsv41/pnfsblock: allow block client not to layoutget in pg_init
Date: Sat, 19 Nov 2011 08:53:12 -0800
Message-Id: <1321721596-3293-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Asking for layout in pg_init will always let client ask for only 4KB
layout in every layoutget. This way, client drops the IO size information.

In such case, server needs to pre-allocate layout to allow better performance.
However, IO size information is very useful for MDS to determine how much layout
it gives client. This is more important for block layout MDS because it needs to
pre-allocate disk for layoutget that extends file size.

Initial tests against a server that does not aggressively pre-allocate layout,
shows that passing IO size information to server helps to improve performance
quite a lot.

The generic pnfs layer changes are trival to file layout and object.

iozone cmd:
./iozone -r 1m -s 4G -w -W -c -t 10 -i 0 -F /mnt/iozone.data.1 /mnt/iozone.data.2 /mnt/iozone.data.3 /mnt/iozone.data.4 /mnt/iozone.data.5 /mnt/iozone.data.6 /mnt/iozone.data.7 /mnt/iozone.data.8 /mnt/iozone.data.9 /mnt/iozone.data.10

Befor patch: around 12MB/s throughput
After patch: around 72MB/s throughput

Peng Tao (4):
  nfsv41: export pnfs_find_alloc_layout
  nfsv41: add and export pnfs_find_get_layout_locked
  nfsv41: get lseg before issue LD IO if pgio doesn't carry one
  pnfsblock: do not ask for layout in pg_init

 fs/nfs/blocklayout/blocklayout.c |   54 +++++++++++++++++++++++++++-
 fs/nfs/pnfs.c                    |   73 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                    |    9 +++++
 3 files changed, 133 insertions(+), 3 deletions(-)

