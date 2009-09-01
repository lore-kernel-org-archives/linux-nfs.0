From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] mount.nfs changes to support "-t nfs -o vers=4"
Date: Tue, 01 Sep 2009 10:28:47 -0400
Message-ID: <20090901142357.3886.21465.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:56343 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754913AbZIAO3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 10:29:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

These changes accompany kernel support for "-t nfs -o vers=4".  The
changes have been split into separate patches for clarity, and the
stropts.c changes have been reworked to make the text-based logic
more straightforward for "vers=4" and "-t nfs4" mounts.

They are offered contingent upon acceptance of the kernel patches.

---

Chuck Lever (3):
      mount.nfs: Detect "-t nfs -o vers=4" mounts
      umount.nfs: Skip UMNT call for "-t nfs -o vers=4" mounts
      mount.nfs: Support "vers=4" in nfs_nfs_version()


 utils/mount/network.c   |   14 +++++++++-----
 utils/mount/network.h   |    1 +
 utils/mount/nfsumount.c |    4 ++++
 utils/mount/stropts.c   |   10 ++++++++--
 4 files changed, 22 insertions(+), 7 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
