From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Support "-t nfs,vers=4" mounts in the kernel [take 4]
Date: Wed, 02 Sep 2009 09:51:52 -0400
Message-ID: <20090902135032.3550.23170.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:54758
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752014AbZIBNv7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 09:51:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the repost.  After reading the patch descriptions again, I
thought they needed some clarification.

---

Chuck Lever (4):
      NFS: Allow the "nfs" file system type to support NFSv4
      NFS: Move details of nfs4_get_sb() to a helper
      NFS: Refactor NFSv4 text-based mount option validation
      NFS: Mount option parser should detect missing "port="


 fs/nfs/internal.h    |   10 ++
 fs/nfs/super.c       |  202 +++++++++++++++++++++++++++++++++-----------------
 include/linux/nfs4.h |    1 
 3 files changed, 144 insertions(+), 69 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
