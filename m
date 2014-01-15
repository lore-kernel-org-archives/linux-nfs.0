Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:60898 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbaAOR04 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jan 2014 12:26:56 -0500
From: mark.doffman@codethink.co.uk
To: ceph-devel@vger.kernel.org
Cc: Mark Doffman <mark.doffman@codethink.co.uk>, sage@inktank.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, rob.taylor@codethink.co.uk
Subject: [PATCH v2 0/2] Add ceph root filesystem functionality and documentation.
Date: Wed, 15 Jan 2014 11:26:27 -0600
Message-Id: <cover.1389806186.git.mark.doffman@codethink.co.uk>
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mark Doffman <mark.doffman@codethink.co.uk>

Hi All,

The following is a second version of a patch series that adds the ability to use
a ceph distributed file system as the root device.

Changes from version 1

fs/ceph/root.c:

The parsing code that takes the DHCP option 17 and kernel command line
parameters has been extensively altered.

The parsing now accepts multiple monitor addresses and ipv6 addresses.

The monitors listed in DHCP option 17 are now concatenated with those
listed on the kernel command line.

The patch series applies to v3.13-rc8-7-g3539717

Thanks

Mark

Mark Doffman (1):
  init: Add a new root device option, the Ceph file system

Rob Taylor (1):
  Documentation: Document the cephroot functionality

 Documentation/filesystems/{ => ceph}/ceph.txt |   0
 Documentation/filesystems/ceph/cephroot.txt   |  86 +++++++++++++
 fs/ceph/Kconfig                               |  10 ++
 fs/ceph/Makefile                              |   1 +
 fs/ceph/root.c                                | 176 ++++++++++++++++++++++++++
 include/linux/ceph/ceph_root.h                |  10 ++
 include/linux/root_dev.h                      |   1 +
 init/do_mounts.c                              |  32 ++++-
 net/ipv4/ipconfig.c                           |  10 +-
 9 files changed, 323 insertions(+), 3 deletions(-)
 rename Documentation/filesystems/{ => ceph}/ceph.txt (100%)
 create mode 100644 Documentation/filesystems/ceph/cephroot.txt
 create mode 100644 fs/ceph/root.c
 create mode 100644 include/linux/ceph/ceph_root.h

-- 
1.8.4

