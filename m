Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:62330 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965722AbZLHSA3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:29 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] mount.nfs support for netids
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 08 Dec 2009 12:59:09 -0500
Message-ID: <20091208175128.2544.457.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

For 2.6.33, Trond has included Jeff's patch that adds support to the
kernel NFS client for "proto=netid."  Here are the user space changes
we think are necessary to complete this support.  See:

  https://bugzilla.redhat.com/show_bug.cgi?id=479350

This series has seen some light testing here, and Jeff is planning to
do more of his own independent testing.

Note that last patch in the series has a rather full set of updates
to nfs(5) that document NFS client side support for NFS over IPv6,
including support for "proto=netid."

Please have a look and let me know what you think.

---

Chuck Lever (10):
      NFS man page: update nfs(5) with details about IPv6 support
      mount.nfs: Remove nfs_name_to_address()
      mount.nfs: Teach umount.nfs to recognize netids in /etc/mtab
      mount.nfs: proto=netid forces address family when resolving server names
      mount.nfs: Fix sockaddr pointer aliasing in stropts.c
      mount.nfs: Add new API for getting protocol family from netids
      mount.nfs: make nfs_lookup() global
      mount.nfs: support netids in v2/v3 version/transport negotiation
      mount.nfs: support netids in nfs_options2pmap()
      libnfs.a: Provide shared helpers for managing netids


 support/include/nfsrpc.h |   12 ++++
 support/nfs/getport.c    |   92 +++++++++++++++++++++++++++++++--
 utils/mount/network.c    |  128 ++++++++++++++++++++++++++++++----------------
 utils/mount/network.h    |    5 +-
 utils/mount/nfs.man      |  104 ++++++++++++++++++++++++++-----------
 utils/mount/nfsumount.c  |   15 ++++-
 utils/mount/stropts.c    |  114 +++++++++++++++++++++++------------------
 7 files changed, 331 insertions(+), 139 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
