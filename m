Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2751 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757034Ab2DXR4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 13:56:19 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 0/8] Fix SECINFO procedure
Date: Tue, 24 Apr 2012 13:56:04 -0400
Message-Id: <1335290172-1532-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

My initial SECINFO implementation was merged in 2.6.39, but accidentally
got disabled in 3.0.  These patches re-enable SECINFO as part of LOOKUP
and push it down to the v4 layer, instead of existing as an rpc_op (I
create a "submount" rpc_op instead, see patch 5).

I also noticed that SECINFO_NO_NAME was never run with the current xdr
decoding logic.  Patch 6 fixes this problem.

Changes in version 3:
- Don't define decode_secinfo_no_name() if CONFIG_NFS_V4_1 isn't set
- Move around function declerations in header files

Changes in version 2:
- Reorder the patches so I'm not doing cleanup in the beginning
- Don't pre-clone an rpc_clnt for nfs_clone_server, instead fix passing an
  rpc_authflavor_t through the nfs_clone_mount data.

Comments are appreciated!

- Bryan

Bryan Schumaker (8):
  NFS: Fix SECINFO_NO_NAME
  NFS: Handle exceptions coming out of nfs4_proc_fs_locations()
  NFS: Do secinfo as part of lookup
  NFS: Remove secinfo knowledge out of the generic client
  NFS: Create a submount rpc_op
  NFS: Fix following referral mount points with different security
  NFS: Honor the authflavor set in the clone mount data
  NFS: Remove extra rpc_clnt argument to proc_lookup

 fs/nfs/client.c         |    5 +-
 fs/nfs/dir.c            |    6 +-
 fs/nfs/internal.h       |   22 ++------
 fs/nfs/namespace.c      |  140 ++++++-----------------------------------------
 fs/nfs/nfs3proc.c       |    3 +-
 fs/nfs/nfs4_fs.h        |   13 ++++-
 fs/nfs/nfs4namespace.c  |  107 +++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c       |  111 +++++++++++++++++++++++++++++--------
 fs/nfs/nfs4xdr.c        |   26 ++++++---
 fs/nfs/proc.c           |    3 +-
 fs/nfs/super.c          |    4 +-
 include/linux/nfs_xdr.h |    5 +-
 12 files changed, 261 insertions(+), 184 deletions(-)

-- 
1.7.10

