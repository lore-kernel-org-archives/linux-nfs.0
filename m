Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:20318
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753256AbbIMM0C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Sep 2015 08:26:02 -0400
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: iommu@lists.linux-foundation.org, dccp@vger.kernel.org,
        dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
        ecryptfs@vger.kernel.org, dmaengine@vger.kernel.org
Cc: sergey.senozhatsky@gmail.com, kernel-janitors@vger.kernel.org,
        Dan Williams <dan.j.williams@intel.com>, cluster-devel@redhat.com,
        intel-wired-lan@lists.osuosl.org,
        Mitch Williams <mitch.a.williams@intel.com>,
        John Ronciak <john.ronciak@intel.com>,
        Matthew Vick <matthew.vick@intel.com>,
        Don Skidmore <donald.c.skidmore@intel.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Shannon Nelson <shannon.nelson@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
        netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
        linux-btrfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
        linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-rdma@vger.kernel.org, devel@driverdev.osuosl.org,
        HPDD-discuss@ml01.01.org, linux-bcache@vger.kernel.org,
        drbd-user@lists.linbit.com, ocfs2-devel@oss.oracle.com,
        kvm@vger.kernel.org, ceph-devel@vger.kernel.org,
        Chao Yu <chao2.yu@samsung.com>, linux-f2fs-devel@lists.sourceforge.net
Subject: [PATCH 00/39] drop null test before destroy functions
Date: Sun, 13 Sep 2015 14:14:53 +0200
Message-Id: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent commits to kernel/git/torvalds/linux.git have made the following
functions able to tolerate NULL arguments:

kmem_cache_destroy (commit 3942d29918522)
mempool_destroy (commit 4e3ca3e033d1)
dma_pool_destroy (commit 44d7175da6ea)

These patches remove the associated NULL tests for the files that I found
easy to compile test.  If these changes are OK, I will address the
remainder later.

---

 arch/x86/kvm/mmu.c                                 |    6 --
 block/bio-integrity.c                              |    7 --
 block/bio.c                                        |    7 --
 block/blk-core.c                                   |    3 -
 block/elevator.c                                   |    3 -
 drivers/atm/he.c                                   |    7 --
 drivers/block/aoe/aoedev.c                         |    3 -
 drivers/block/drbd/drbd_main.c                     |   21 ++-----
 drivers/block/pktcdvd.c                            |    3 -
 drivers/block/rbd.c                                |    6 --
 drivers/dma/dmaengine.c                            |    6 --
 drivers/firmware/google/gsmi.c                     |    3 -
 drivers/gpu/drm/i915/i915_dma.c                    |   19 ++----
 drivers/iommu/amd_iommu_init.c                     |    7 --
 drivers/md/bcache/bset.c                           |    3 -
 drivers/md/bcache/request.c                        |    3 -
 drivers/md/bcache/super.c                          |    9 +--
 drivers/md/dm-bufio.c                              |    3 -
 drivers/md/dm-cache-target.c                       |    3 -
 drivers/md/dm-crypt.c                              |    6 --
 drivers/md/dm-io.c                                 |    3 -
 drivers/md/dm-log-userspace-base.c                 |    3 -
 drivers/md/dm-region-hash.c                        |    4 -
 drivers/md/dm.c                                    |   13 +---
 drivers/md/multipath.c                             |    3 -
 drivers/md/raid1.c                                 |    6 --
 drivers/md/raid10.c                                |    9 +--
 drivers/md/raid5.c                                 |    3 -
 drivers/mtd/nand/nandsim.c                         |    3 -
 drivers/mtd/ubi/attach.c                           |    4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    3 -
 drivers/staging/lustre/lustre/llite/super25.c      |   16 +----
 drivers/staging/lustre/lustre/obdclass/genops.c    |   24 ++------
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    6 --
 drivers/staging/rdma/hfi1/user_sdma.c              |    3 -
 drivers/thunderbolt/ctl.c                          |    3 -
 drivers/usb/gadget/udc/bdc/bdc_core.c              |    3 -
 drivers/usb/gadget/udc/gr_udc.c                    |    3 -
 drivers/usb/gadget/udc/mv_u3d_core.c               |    3 -
 drivers/usb/gadget/udc/mv_udc_core.c               |    3 -
 drivers/usb/host/fotg210-hcd.c                     |   12 +---
 drivers/usb/host/fusbh200-hcd.c                    |   12 +---
 drivers/usb/host/whci/init.c                       |    3 -
 drivers/usb/host/xhci-mem.c                        |   12 +---
 fs/btrfs/backref.c                                 |    3 -
 fs/btrfs/delayed-inode.c                           |    3 -
 fs/btrfs/delayed-ref.c                             |   12 +---
 fs/btrfs/disk-io.c                                 |    3 -
 fs/btrfs/extent_io.c                               |    6 --
 fs/btrfs/extent_map.c                              |    3 -
 fs/btrfs/file.c                                    |    3 -
 fs/btrfs/inode.c                                   |   18 ++----
 fs/btrfs/ordered-data.c                            |    3 -
 fs/dlm/memory.c                                    |    6 --
 fs/ecryptfs/main.c                                 |    3 -
 fs/ext4/crypto.c                                   |    9 +--
 fs/ext4/extents_status.c                           |    3 -
 fs/ext4/mballoc.c                                  |    3 -
 fs/f2fs/crypto.c                                   |    9 +--
 fs/gfs2/main.c                                     |   29 ++--------
 fs/jbd2/journal.c                                  |   15 +----
 fs/jbd2/revoke.c                                   |   12 +---
 fs/jbd2/transaction.c                              |    6 --
 fs/jffs2/malloc.c                                  |   27 +++------
 fs/nfsd/nfscache.c                                 |    6 --
 fs/nilfs2/super.c                                  |   12 +---
 fs/ocfs2/dlm/dlmlock.c                             |    3 -
 fs/ocfs2/dlm/dlmmaster.c                           |   16 +----
 fs/ocfs2/super.c                                   |   18 ++----
 fs/ocfs2/uptodate.c                                |    3 -
 lib/debugobjects.c                                 |    3 -
 net/core/sock.c                                    |   12 +---
 net/dccp/ackvec.c                                  |   12 +---
 net/dccp/ccid.c                                    |    3 -
 net/sunrpc/sched.c                                 |   12 +---
 75 files changed, 180 insertions(+), 381 deletions(-)
