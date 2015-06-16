Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34772 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756554AbbFPOsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 10:48:47 -0400
Received: by pacgb13 with SMTP id gb13so14267116pac.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 07:48:46 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 00/11] pnfs/flexfiles: layoutstats support
Date: Tue, 16 Jun 2015 22:47:21 +0800
Message-Id: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

The patchsets add LAYOUTSTATS support to flexfiles. LAYOUTSTATS are sent
every minute if IO is still happening upon a file.

One limitation is that at most 4 LAYOUTSTATS calls are permitted in a compound.
Had to send multiple LAYOUTSTATS operations per compound because OP_LAYOUTSTATS
requires stateid and deviceid as its arguments, which makes it a per-file per-deviceid
call.

Cheers,
Tao

Peng Tao (8):
  pNFS: fill in nfs42_layoutstat_ops
  pnfs: add pnfs_report_layoutstat helper function
  pNFS/flexfiles: track when layout is first used
  pnfs/flexfiles: add ff_layout_prepare_layoutstats
  pnfs/flexfiles: encode LAYOUTSTATS flexfiles specific data
  pnfs/flexfiles: reset IO statistics upon LAYOUTSTATS success
  nfs42: serialize LAYOUTSTATS calls of the same file
  pnfs/flexfiles: report layoutstat regularly

Trond Myklebust (3):
  NFSv.2/pnfs Add a LAYOUTSTATS rpc function
  pNFS/flexfiles: Remove unused struct members user_name, group_name
  pNFS/flexfiles: add layoutstats tracking

 fs/nfs/flexfilelayout/flexfilelayout.c | 448 ++++++++++++++++++++++++++++++++-
 fs/nfs/flexfilelayout/flexfilelayout.h |  30 ++-
 fs/nfs/nfs42.h                         |   7 +-
 fs/nfs/nfs42proc.c                     |  81 ++++++
 fs/nfs/nfs42xdr.c                      | 122 +++++++++
 fs/nfs/nfs4_fs.h                       |   1 +
 fs/nfs/nfs4proc.c                      |   4 +-
 fs/nfs/nfs4xdr.c                       |   1 +
 fs/nfs/pnfs.c                          |  56 +++++
 fs/nfs/pnfs.h                          |   3 +
 include/linux/nfs4.h                   |   1 +
 include/linux/nfs_fs.h                 |   1 +
 include/linux/nfs_xdr.h                |  43 ++++
 13 files changed, 782 insertions(+), 16 deletions(-)

-- 
1.8.3.1

