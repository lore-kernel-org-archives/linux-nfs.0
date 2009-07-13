From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] NFS mount-related commits for 2.6.32
Date: Mon, 13 Jul 2009 15:17:09 -0400
Message-ID: <20090713191417.1951.75470.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45014
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751737AbZGMTRV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2009 15:17:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Let's start the ball rolling... Here's a first attempt at introducing
proper kernel-level support for processing MNT's authentication flavor
list for NFSv2/v3 mounts.

I've also included the minorversion option fix-up since you didn't
respond when I posted it a couple of weeks ago.

---

Chuck Lever (5):
      NFS: Use the authentication flavor list returned by mountd
      NFS: Fix auth flavor len accounting
      NFS: Add ability to send MOUNTPROC_UMNT to the kernel's mountd client
      NFS: Refactor nfs_mount() to move rpc_create() to helper
      NFS: Fix up new minorversion= option


 fs/nfs/internal.h   |    1 
 fs/nfs/mount_clnt.c |  111 +++++++++++++++++++++++++++++++++++++++++----------
 fs/nfs/super.c      |   94 ++++++++++++++++++++++++++++++-------------
 3 files changed, 157 insertions(+), 49 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
