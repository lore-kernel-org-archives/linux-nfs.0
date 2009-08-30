From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Support "-t nfs,vers=4" mounts in the kernel
Date: Sun, 30 Aug 2009 12:34:24 -0400
Message-ID: <20090830162211.3652.14638.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:49877
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753790AbZH3Qea (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 12:34:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update to the patches that allow the "nfs" file system to handle
vers=4.  These patches are for discussion only.

Minor changes to mount.nfs and umount.nfs are required, and will be
posted in a separate thread.  With these changes, mount.nfs passes a
client_address option and skips rpcbind for vers=4 mounts, and
umount.nfs skips the UMNT call for vers=4 mounts.

This series adds proper handling of the default port (0 for v2/v3,
2049 for v4), teaches nfs_kill_super to handle both "nfs" and "nfs4"
file systems, and refactors NFSv4 routines so common code can be
invoked by "nfs" and "nfs4."

Simple mount test succeeds.  /proc/mounts lists the mount as "nfs4"
but /etc/mtab lists it as "nfs".  Thus combining nfs_kill_super and
nfs4_kill_super is probably not necessary.

I have not tried cross mounts or referrals.

---

Chuck Lever (5):
      NFS: Allow the "nfs" file system type to support NFSv4
      NFS: Move details of nfs4_get_sb() to a helper
      NFS: Refactor NFSv4 text-based mount option validation
      NFS: Mount option parser should detect unset port values
      NFS: combine nfs_kill_super() and nfs4_kill_super()


 fs/nfs/internal.h    |   23 ++++-
 fs/nfs/super.c       |  245 +++++++++++++++++++++++++++++++-------------------
 include/linux/nfs4.h |    1 
 3 files changed, 174 insertions(+), 95 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
