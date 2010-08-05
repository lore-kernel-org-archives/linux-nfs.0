Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759160Ab0HEOSA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 10:18:00 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Committed to the nfs-for-2.6.36 branch
Date: Thu,  5 Aug 2010 10:17:47 -0400
Message-Id: <1281017872-6043-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi,

The following patches have been committed to the nfs-for-2.6.36 branch,
which I plan on sending to Linus this weekend.

Cheers
  Trond

Bryan Schumaker (1):
  NFS: Fix /proc/mount for legacy binary interface

Trond Myklebust (4):
  NFSv4: Remember to clear NFS_DELEGATED_STATE in
    nfs_delegation_claim_opens
  NFS: Fix the locking in nfs4_callback_getattr
  NFS: NFS_V4 is no longer an EXPERIMENTAL feature
  NFS: NFSv4.1 is no longer a "developer only" feature

 fs/nfs/Kconfig            |   10 +++++-----
 fs/nfs/callback_proc.c    |    6 +++---
 fs/nfs/delegation.c       |    1 +
 fs/nfs/super.c            |    4 ++++
 include/linux/nfs_mount.h |    1 +
 5 files changed, 14 insertions(+), 8 deletions(-)

-- 
1.7.2

