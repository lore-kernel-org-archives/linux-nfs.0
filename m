From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Support "-t nfs,vers=4" mounts in the kernel [take 3]
Date: Tue, 01 Sep 2009 10:20:58 -0400
Message-ID: <20090901141615.3700.41738.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:51782
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754915AbZIAOVG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 10:21:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update to the patches that allow the "nfs" file system to handle
vers=4.  These patches can be considered for 2.6.32.

I've simplified the changes somewhat, and dropped the nfs_kill_super()
patch.  I've done a little more extensive testing, but I have not
tried cross mounts or referrals, or mounts using the legacy binary
interface.

A refresh of the [u]mount.nfs patches will be posted in a separate
thread.

---

Chuck Lever (4):
      NFS: Allow the "nfs" file system type to support NFSv4
      NFS: Move details of nfs4_get_sb() to a helper
      NFS: Refactor NFSv4 text-based mount option validation
      NFS: Mount option parser should detect unset port values


 fs/nfs/internal.h    |   10 ++
 fs/nfs/super.c       |  202 +++++++++++++++++++++++++++++++++-----------------
 include/linux/nfs4.h |    1 
 3 files changed, 144 insertions(+), 69 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
