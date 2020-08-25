Return-Path: <SRS0=UJvk=CD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D52EC433E1
	for <linux-nfs@archiver.kernel.org>; Tue, 25 Aug 2020 05:03:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 530DC20706
	for <linux-nfs@archiver.kernel.org>; Tue, 25 Aug 2020 05:03:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728496AbgHYFDB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 Aug 2020 01:03:01 -0400
Received: from smtprelay0191.hostedemail.com ([216.40.44.191]:45466 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1728377AbgHYFDB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2020 01:03:01 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave01.hostedemail.com (Postfix) with ESMTP id AE13F18024CF4;
        Tue, 25 Aug 2020 04:56:49 +0000 (UTC)
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay04.hostedemail.com (Postfix) with ESMTP id B846B180A9F54;
        Tue, 25 Aug 2020 04:56:42 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: chalk60_631385f27059
X-Filterd-Recvd-Size: 5825
Received: from joe-laptop.perches.com (unknown [47.151.133.149])
        (Authenticated sender: joe@perches.com)
        by omf08.hostedemail.com (Postfix) with ESMTPA;
        Tue, 25 Aug 2020 04:56:38 +0000 (UTC)
From:   Joe Perches <joe@perches.com>
To:     Jiri Kosina <trivial@kernel.org>, oprofile-list@lists.sf.net,
        linux-ide@vger.kernel.org, drbd-dev@lists.linbit.com,
        linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linaro-mm-sig@lists.linaro.org, intel-gfx@lists.freedesktop.org,
        linux-hwmon@vger.kernel.org, linux-input@vger.kernel.org,
        linux-bcache@vger.kernel.org, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        linux-arm-kernel@lists.infradead.org,
        linux-fsdevel@vger.kernel.org, reiserfs-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc:     linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-block@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-s390@vger.kernel.org,
        linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org,
        linux-fbdev@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Subject: [PATCH 00/29] treewide: Convert comma separated statements
Date:   Mon, 24 Aug 2020 21:55:57 -0700
Message-Id: <cover.1598331148.git.joe@perches.com>
X-Mailer: git-send-email 2.26.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There are many comma separated statements in the kernel.
See:https://lore.kernel.org/lkml/alpine.DEB.2.22.394.2008201856110.2524@hadrien/

Convert the comma separated statements that are in if/do/while blocks
to use braces and semicolons.

Many comma separated statements still exist but those are changes for
another day.

Joe Perches (29):
  coding-style.rst: Avoid comma statements
  alpha: Avoid comma separated statements
  ia64: Avoid comma separated statements
  sparc: Avoid comma separated statements
  ata: Avoid comma separated statements
  drbd: Avoid comma separated statements
  lp: Avoid comma separated statements
  dma-buf: Avoid comma separated statements
  drm/gma500: Avoid comma separated statements
  drm/i915: Avoid comma separated statements
  hwmon: (scmi-hwmon): Avoid comma separated statements
  Input: MT - Avoid comma separated statements
  bcache: Avoid comma separated statements
  media: Avoid comma separated statements
  mtd: Avoid comma separated statements
  8390: Avoid comma separated statements
  fs_enet: Avoid comma separated statements
  wan: sbni: Avoid comma separated statements
  s390/tty3270: Avoid comma separated statements
  scai/arm: Avoid comma separated statements
  media: atomisp: Avoid comma separated statements
  video: fbdev: Avoid comma separated statements
  fuse: Avoid comma separated statements
  reiserfs: Avoid comma separated statements
  lib/zlib: Avoid comma separated statements
  lib: zstd: Avoid comma separated statements
  ipv6: fib6: Avoid comma separated statements
  sunrpc: Avoid comma separated statements
  tools: Avoid comma separated statements

 Documentation/process/coding-style.rst        |  17 +
 arch/alpha/kernel/pci_iommu.c                 |   8 +-
 arch/alpha/oprofile/op_model_ev4.c            |  22 +-
 arch/alpha/oprofile/op_model_ev5.c            |   8 +-
 arch/ia64/kernel/smpboot.c                    |   7 +-
 arch/sparc/kernel/smp_64.c                    |   7 +-
 drivers/ata/pata_icside.c                     |  21 +-
 drivers/block/drbd/drbd_receiver.c            |   6 +-
 drivers/char/lp.c                             |   6 +-
 drivers/dma-buf/st-dma-fence.c                |   7 +-
 drivers/gpu/drm/gma500/mdfld_intel_display.c  |  44 ++-
 drivers/gpu/drm/i915/gt/gen8_ppgtt.c          |   8 +-
 drivers/gpu/drm/i915/gt/intel_gt_requests.c   |   6 +-
 .../gpu/drm/i915/gt/selftest_workarounds.c    |   6 +-
 drivers/gpu/drm/i915/intel_runtime_pm.c       |   6 +-
 drivers/hwmon/scmi-hwmon.c                    |   6 +-
 drivers/input/input-mt.c                      |  11 +-
 drivers/md/bcache/bset.c                      |  12 +-
 drivers/md/bcache/sysfs.c                     |   6 +-
 drivers/media/i2c/msp3400-kthreads.c          |  12 +-
 drivers/media/pci/bt8xx/bttv-cards.c          |   6 +-
 drivers/media/pci/saa7134/saa7134-video.c     |   7 +-
 drivers/mtd/devices/lart.c                    |  10 +-
 drivers/net/ethernet/8390/axnet_cs.c          |  19 +-
 drivers/net/ethernet/8390/lib8390.c           |  14 +-
 drivers/net/ethernet/8390/pcnet_cs.c          |   6 +-
 .../ethernet/freescale/fs_enet/fs_enet-main.c |  11 +-
 drivers/net/wan/sbni.c                        | 101 +++---
 drivers/s390/char/tty3270.c                   |   6 +-
 drivers/scsi/arm/cumana_2.c                   |  19 +-
 drivers/scsi/arm/eesox.c                      |   9 +-
 drivers/scsi/arm/powertec.c                   |   9 +-
 .../media/atomisp/pci/atomisp_subdev.c        |   6 +-
 drivers/video/fbdev/tgafb.c                   |  12 +-
 fs/fuse/dir.c                                 |  24 +-
 fs/reiserfs/fix_node.c                        |  36 ++-
 lib/zlib_deflate/deftree.c                    |  49 ++-
 lib/zstd/compress.c                           | 120 ++++---
 lib/zstd/fse_compress.c                       |  24 +-
 lib/zstd/huf_compress.c                       |   6 +-
 net/ipv6/ip6_fib.c                            |  12 +-
 net/sunrpc/sysctl.c                           |   6 +-
 tools/lib/subcmd/help.c                       |  10 +-
 tools/power/cpupower/utils/cpufreq-set.c      |  14 +-
 tools/testing/selftests/vm/gup_benchmark.c    |  18 +-
 tools/testing/selftests/vm/userfaultfd.c      | 296 +++++++++++-------
 46 files changed, 694 insertions(+), 382 deletions(-)

-- 
2.26.0

