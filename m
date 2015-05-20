Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0068.hostedemail.com ([216.40.44.68]:43063 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751472AbbETBqA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2015 21:46:00 -0400
From: Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-bcache@vger.kernel.org, netdev@vger.kernel.org,
        linux-scsi@vger.kernel.org, logfs@logfs.org
Cc: dmaengine@vger.kernel.org, linux-raid@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 00/12] treewide: Use DECLARE_BITMAP
Date: Tue, 19 May 2015 18:37:48 -0700
Message-Id: <cover.1432085659.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the standard method to declare a bitmap array.

Joe Perches (12):
  ARM: mach-imx: iomux-imx31: Use DECLARE_BITMAP
  dmaengine: rcar-dmac: Use DECLARE_BITMAP
  drm/amdkfd: Use DECLARE_BITMAP
  drm/radeon: Use DECLARE_BITMAP
  IB/ehca: Use DECLARE_BITMAP
  bcache: Use DECLARE_BITMAP
  spider_net: Use DECLARE_BITMAP
  s390/sclp: Use DECLARE_BITMAP
  [SCSI] qla4xxx: Use DECLARE_BITMAP
  scsi: Use DECLARE_BITMAP
  logfs: Use DECLARE_BITMAP
  sunrpc: Use DECLARE_BITMAP

 arch/arm/mach-imx/iomux-imx31.c           | 2 +-
 drivers/dma/sh/rcar-dmac.c                | 2 +-
 drivers/gpu/drm/amd/amdkfd/kfd_priv.h     | 5 ++---
 drivers/gpu/drm/radeon/radeon.h           | 2 +-
 drivers/infiniband/hw/ehca/ipz_pt_fn.h    | 2 +-
 drivers/md/bcache/journal.c               | 2 +-
 drivers/net/ethernet/toshiba/spider_net.c | 3 +--
 drivers/s390/char/sclp_cmd.c              | 2 +-
 drivers/scsi/qla4xxx/ql4_def.h            | 2 +-
 drivers/scsi/sr.c                         | 2 +-
 fs/logfs/logfs.h                          | 2 +-
 net/sunrpc/auth_gss/svcauth_gss.c         | 2 +-
 12 files changed, 13 insertions(+), 15 deletions(-)

-- 
2.1.2

