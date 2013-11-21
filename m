Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:54051 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab3KUCOF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 21:14:05 -0500
From: mark.doffman@codethink.co.uk
To: ceph-devel@vger.kernel.org
Cc: Mark Doffman <mark.doffman@codethink.co.uk>, sage@inktank.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, rob.taylor@codethink.co.uk
Subject: [PATCH 0/4] Add ceph root filesystem functionality and documentation.
Date: Wed, 20 Nov 2013 20:13:40 -0600
Message-Id: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mark Doffman <mark.doffman@codethink.co.uk>

Hi All,

The following patch series adds the ability to use a ceph distributed
file system as the root device. The functionality is similar to
NFS root but for the ceph filesystem.

The patch series adds a new root device option '/dev/ceph'.
Configuration is passed either via a new kernel parameter 'cephroot'
or DHCP option 17.

The patch series applies to v3.12-10714-gd085eb6

Thanks

Mark

Mark Doffman (3):
  init: Add a new root device option, the Ceph file system
  cephroot: Add DHCP option 17 configuration to ceph root fs.
  Reuse root_nfs_parse_addr() for NFS and CEPH

Rob Taylor (1):
  Documentation: Document the cephroot functionality

 Documentation/filesystems/{ => ceph}/ceph.txt |   0
 Documentation/filesystems/ceph/cephroot.txt   |  85 +++++++++++++
 fs/ceph/Kconfig                               |  10 ++
 fs/ceph/Makefile                              |   1 +
 fs/ceph/root.c                                | 165 ++++++++++++++++++++++++++
 fs/nfs/nfsroot.c                              |   4 +-
 include/linux/ceph/ceph_root.h                |  10 ++
 include/linux/nfs_fs.h                        |   2 +-
 include/linux/root_dev.h                      |   1 +
 init/do_mounts.c                              |  32 ++++-
 net/ipv4/ipconfig.c                           |  16 ++-
 11 files changed, 317 insertions(+), 9 deletions(-)
 rename Documentation/filesystems/{ => ceph}/ceph.txt (100%)
 create mode 100644 Documentation/filesystems/ceph/cephroot.txt
 create mode 100644 fs/ceph/root.c
 create mode 100644 include/linux/ceph/ceph_root.h

-- 
1.8.4

