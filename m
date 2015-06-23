Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36539 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbbFWLw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2015 07:52:26 -0400
Received: by pdcu2 with SMTP id u2so5843672pdc.3
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jun 2015 04:52:26 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH-v2 00/10] pnfs/flexfiles: layoutstats support
Date: Tue, 23 Jun 2015 19:51:54 +0800
Message-Id: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
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

v1->v2 Changelog:
1. don't reset IO statistics upon LAYOUTSTATS reply per latest NFS42 draft.
2. update flexfiles xdr to match latetst flexfiles draft.
3. address Jeff's comments and add his reviewed-by line.

Peng Tao (7):
  pNFS: fill in nfs42_layoutstat_ops
  pnfs: add pnfs_report_layoutstat helper function
  pNFS/flexfiles: track when layout is first used
  pnfs/flexfiles: add ff_layout_prepare_layoutstats
  pnfs/flexfiles: encode LAYOUTSTATS flexfiles specific data
  nfs42: serialize LAYOUTSTATS calls of the same file
  pnfs/flexfiles: report layoutstat regularly

Trond Myklebust (3):
  NFSv.2/pnfs Add a LAYOUTSTATS rpc function
  pNFS/flexfiles: Remove unused struct members user_name, group_name
  pNFS/flexfiles: add layoutstats tracking

 fs/nfs/flexfilelayout/flexfilelayout.c | 459 ++++++++++++++++++++++++++++++++-
 fs/nfs/flexfilelayout/flexfilelayout.h |  30 ++-
 fs/nfs/nfs42.h                         |   9 +-
 fs/nfs/nfs42proc.c                     |  81 ++++++
 fs/nfs/nfs42xdr.c                      | 122 +++++++++
 fs/nfs/nfs4_fs.h                       |   1 +
 fs/nfs/nfs4proc.c                      |   4 +-
 fs/nfs/nfs4xdr.c                       |   1 +
 fs/nfs/pnfs.c                          |  56 ++++
 fs/nfs/pnfs.h                          |   3 +
 include/linux/nfs4.h                   |   1 +
 include/linux/nfs_fs.h                 |   1 +
 include/linux/nfs_xdr.h                |  43 +++
 13 files changed, 795 insertions(+), 16 deletions(-)

-- 
1.8.3.1

