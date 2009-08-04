Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:50538
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752879AbZHDN6m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 09:58:42 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] NFS mount-related commits for 2.6.32, take 2
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Tue, 04 Aug 2009 09:58:34 -0400
Message-ID: <20090804135425.2287.3313.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

Here's a second crack at introducing proper kernel-level support for
processing MNT's authentication flavor list for NFSv2/v3 mounts.
These patches should replace the five patches I sent you July 13th.

---

Chuck Lever (4):
      NFS: Use the authentication flavor list returned by mountd
      NFS: Fix auth flavor len accounting
      NFS: Add ability to send MOUNTPROC_UMNT to the kernel's mountd client
      NFS: Fix up new minorversion= option


 fs/nfs/internal.h   |    1 +
 fs/nfs/mount_clnt.c |   80 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/super.c      |   93 ++++++++++++++++++++++++++++++++++++---------------
 3 files changed, 146 insertions(+), 28 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
