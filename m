Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015Ab2DRRqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:46:30 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 0/6] Fix SECINFO procedure
Date: Wed, 18 Apr 2012 13:46:19 -0400
Message-Id: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

My initial SECINFO implementation was merged in 2.6.39, but accidentally
got disabled in 3.0.  These patches re-enable SECINFO as part of LOOKUP
and push it down to the v4 layer, instead of existing as an rpc_op (I
create a "submount" rpc_op instead, see patch 3).

I also noticed that SECINFO_NO_NAME was never run with the current xdr
decoding logic.  Patch 6 fixes this problem.

Comments are appreciated!

- Bryan

Bryan Schumaker (6):
  NFS: pre-clone the rpc_clnt
  NFS: Pass alternate rpc_clnt to fs_locations()
  NFS: Create a submount rpc_op
  NFS: Do secinfo as part of lookup
  NFS: Remove extra rpc_clnt argument to proc_lookup
  NFS: Fix SECINFO_NO_NAME

 fs/nfs/client.c         |   50 ++++++++-------
 fs/nfs/dir.c            |    6 +-
 fs/nfs/internal.h       |   22 ++-----
 fs/nfs/namespace.c      |  154 +++++++++--------------------------------------
 fs/nfs/nfs3proc.c       |    3 +-
 fs/nfs/nfs4_fs.h        |   12 +++-
 fs/nfs/nfs4namespace.c  |  110 ++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c       |   93 ++++++++++++++++++++--------
 fs/nfs/nfs4xdr.c        |   26 +++++---
 fs/nfs/proc.c           |    3 +-
 fs/nfs/super.c          |    4 +-
 include/linux/nfs_xdr.h |    6 +-
 12 files changed, 282 insertions(+), 207 deletions(-)

-- 
1.7.10

