Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60980 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753088AbdLHRxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Dec 2017 12:53:00 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 0/3] pNFS blocklayout handling for transient devices
Date: Fri,  8 Dec 2017 12:52:56 -0500
Message-Id: <cover.1512748321.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This set improves the blocklayoutdriver's handling of layouts when devices
are not present on the a client, or become unavailable.  Ideally, clients
should not continually spam a server with LAYOUTGET for known layouts, and
GETDEVINFO for known devices, since it may be a common scenario to have some
clients that have access to the block devices, and some clients that do not.

In addition to better handling situations where devices are unavailable,
patches 2 and 3 fix crashes if SCSI devices do not exist or are already have
existing reservations.

Benjamin Coddington (3):
  pnfs/blocklayout: set PNFS_LAYOUTRETURN_ON_ERROR
  pnfs/blocklayout: Revalidate SCSI disks after registration
  pnfs/blocklayout: handle transient devices

 fs/nfs/blocklayout/blocklayout.c | 84 +++++++++++++++++++++++++++++++++++++---
 fs/nfs/blocklayout/dev.c         | 15 ++++---
 fs/nfs/pnfs.c                    |  2 +-
 fs/nfs/pnfs.h                    |  6 ++-
 fs/nfs/pnfs_dev.c                |  1 -
 5 files changed, 94 insertions(+), 14 deletions(-)

-- 
2.9.3

