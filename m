Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:16757 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932885AbbCPSG2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 14:06:28 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v4 0/2] NFS: ALLOCATE and DEALLOCATE improvemnts
Date: Mon, 16 Mar 2015 14:06:22 -0400
Message-ID: <1426529184-8794-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches make a few tweaks that improve the performance of ALLOCATE
and DEALLOCATE requests.  The first patch attempts to update cache
information after a (DE)ALLOCATE call, rather than clearing the cache and
forcing the client to re-read the file later.  The second patch changes
when we lock the i_mutex to give NFS v4.0 and v4.1 a chance to exit without
taking a lock.

Comments are appreciated!

Anna


Anna Schumaker (2):
  NFS: Don't zap caches on fallocate()
  NFS: Reduce time spent holding the i_mutex during fallocate()

 fs/nfs/inode.c          |  1 -
 fs/nfs/nfs42proc.c      | 31 +++++++++++++++++++++++++++----
 fs/nfs/nfs42xdr.c       | 20 ++++++++++++++++----
 fs/nfs/nfs4file.c       | 10 ++--------
 include/linux/nfs_xdr.h |  4 ++++
 5 files changed, 49 insertions(+), 17 deletions(-)

-- 
2.3.3

