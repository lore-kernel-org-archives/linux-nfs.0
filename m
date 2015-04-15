Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:57042 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756361AbbDORAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2015 13:00:19 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 0/3] NFS: Various idmap cleanups
Date: Wed, 15 Apr 2015 13:00:03 -0400
Message-ID: <1429117206-13671-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches are some cleanups I noticed while looking for unnecessary
checks of CONFIG_NFS_V4, and the first patch is exactly the same as the
one I sent out yesterday.  The second patch moves nfs_idmap.h into the NFS
directory, as Christoph suggested.

My third patch renames idmap.c to nfs4idmap.c.  I dream of a world where all
files built into the NFS v4 module are prefixed with "nfs4", so this patch
takes one small step while I'm in the area.  I'm willing to drop it if there
are any objections!

Thanks,
Anna


Anna Schumaker (3):
  NFS: Remove CONFIG_NFS_V4 checks from nfs_idmap.h
  NFS: Move nfs_idmap.h into fs/nfs/
  NFS: Rename idmap.c to nfs4idmap.c

 fs/nfs/Makefile                                 |  2 +-
 fs/nfs/client.c                                 |  1 -
 fs/nfs/flexfilelayout/flexfilelayout.c          |  2 +-
 fs/nfs/nfs4client.c                             |  2 +-
 fs/nfs/{idmap.c => nfs4idmap.c}                 |  2 +-
 include/linux/nfs_idmap.h => fs/nfs/nfs4idmap.h | 13 +------------
 fs/nfs/nfs4proc.c                               |  2 +-
 fs/nfs/nfs4state.c                              |  2 +-
 fs/nfs/nfs4super.c                              |  2 +-
 fs/nfs/nfs4sysctl.c                             |  2 +-
 fs/nfs/nfs4xdr.c                                |  2 +-
 fs/nfs/super.c                                  |  1 -
 include/uapi/linux/nfs_idmap.h                  |  2 +-
 13 files changed, 11 insertions(+), 24 deletions(-)
 rename fs/nfs/{idmap.c => nfs4idmap.c} (99%)
 rename include/linux/nfs_idmap.h => fs/nfs/nfs4idmap.h (94%)

-- 
2.3.5

