Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52860 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755403Ab0DVUuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 16:50:24 -0400
Received: from localhost.localdomain (kmanoj02-lxp.hq.netapp.com [10.58.60.82] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3MKoMJ5026155
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 13:50:22 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Please review bugfixes for mainline
Date: Thu, 22 Apr 2010 16:50:16 -0400
Message-Id: <1271969421-7443-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches have been queued up in the 'bugfixes' branch on
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

Cheers
  Trond

Chuck Lever (1):
  NFS: rsize and wsize settings ignored on v4 mounts

Dan Carpenter (1):
  nfs: testing for null instead of ERR_PTR()

Trond Myklebust (3):
  SUNRPC: Fix a bug in rpcauth_prune_expired
  NFSv4: Don't attempt an atomic open if the file is a mountpoint
  NFS: Fix an unstable write data integrity race

 fs/nfs/client.c        |    2 ++
 fs/nfs/dir.c           |    2 +-
 fs/nfs/super.c         |    2 +-
 fs/nfs/write.c         |   36 ++++++++++++++++++++++++++++++++----
 include/linux/nfs_fs.h |    1 +
 net/sunrpc/auth.c      |    2 +-
 6 files changed, 38 insertions(+), 7 deletions(-)

