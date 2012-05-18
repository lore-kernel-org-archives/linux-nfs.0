Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:62275 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966112Ab2ERWFS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 18:05:18 -0400
Received: by gglu4 with SMTP id u4so3328926ggl.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2012 15:05:17 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/14] UCS pre-requisites for 3.5
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 May 2012 18:05:15 -0400
Message-ID: <20120518220145.774.53741.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Here is a motley set of patches from the previously posted UCS series
that have been tested to some extent and are ready for mainline.

Unfortunately I was not able to get to the CLID_INUSE recovery
overhaul that we have discussed because of family matters.  The
three or four patches that implement UCS and the "migration"
mount option are not included here, as they depend on proper
CLID_INUSE recovery.

---

Chuck Lever (14):
      NFS: EXCHANGE_ID should save the server major and minor ID
      NFS: Add nfs_client behavior flags
      NFS: Refactor nfs_get_client(): initialize nfs_client
      NFS: Refactor nfs_get_client(): add nfs_found_client()
      NFS: Always use the same SETCLIENTID boot verifier
      NFS: Force server to drop NFSv4 state
      NFS: Add NFSDBG_STATE
      NFS: Don't swap bytes in nfs4_construct_boot_verifier()
      NFS: Remove nfs_unique_id
      NFS: Clean up return code checking in nfs4_proc_exchange_id()
      NFS: Use proper naming conventions for the nfs_client.net field
      NFS: Use proper naming conventions for nfs_client.impl_id field
      NFS: Use proper naming conventions for NFSv4.1 server scope fields
      NFS: Fix comment misspelling in struct nfs_client definition


 fs/nfs/blocklayout/blocklayoutdev.c |    2 
 fs/nfs/client.c                     |  204 +++++++++++++++++++----------------
 fs/nfs/idmap.c                      |    4 -
 fs/nfs/internal.h                   |   17 +--
 fs/nfs/netns.h                      |    5 +
 fs/nfs/nfs4_fs.h                    |    8 -
 fs/nfs/nfs4filelayoutdev.c          |    2 
 fs/nfs/nfs4proc.c                   |   74 ++++++++-----
 fs/nfs/nfs4renewd.c                 |    2 
 fs/nfs/nfs4state.c                  |   15 ++-
 fs/nfs/nfs4xdr.c                    |   18 ++-
 fs/nfs/super.c                      |    4 -
 include/linux/nfs_fs.h              |    1 
 include/linux/nfs_fs_sb.h           |   17 ++-
 include/linux/nfs_xdr.h             |   12 +-
 15 files changed, 222 insertions(+), 163 deletions(-)

-- 
Chuck Lever
