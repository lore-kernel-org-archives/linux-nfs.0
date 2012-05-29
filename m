Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56796 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab2E2EjL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 00:39:11 -0400
Received: by pbbrp8 with SMTP id rp8so5401164pbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 21:39:11 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH-v2 0/3] pnfsblock: cope with DIO changes
Date: Tue, 29 May 2012 12:38:51 +0800
Message-Id: <1338266334-11490-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

This applies on top of the patch '[PATCH] pnfsblock: bail out partial page IO'
and follows your pg_layout_private suggestion to pass struct blk_plug around
pg_init/pg_doio.

Please see if it is acceptable.

Thanks,
Tao

Peng Tao (3):
  pnfsblock: bail out partial block direct write
  NFS41: add pg_layout_private and moreio fields
  pnfsblock: call blk_plug functions for direct IO

 fs/nfs/blocklayout/blocklayout.c |   62 ++++++++++++++++++++++++++++++++++++--
 fs/nfs/pagelist.c                |    3 ++
 include/linux/nfs_page.h         |    1 +
 include/linux/nfs_xdr.h          |    2 +
 4 files changed, 65 insertions(+), 3 deletions(-)

