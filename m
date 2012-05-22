Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:41181 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755626Ab2EVCoQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:44:16 -0400
Received: by gglu4 with SMTP id u4so4992272ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:44:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/14 v2] UCS pre-requisites for 3.5
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:44:13 -0400
Message-ID: <20120522022702.1787.45940.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Reposting UCS pre-requisites series, ported to your nfs-for-next branch
after this merge commit:

commit b3f87b98aa3dc22cc58f970140113b270015cddb
Merge: 041245c 1afeaf5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon May 21 10:12:39 2012 -0400

    Merge branch 'bugfixes' into nfs-for-next

While retesting the ported purge-state patch, I noticed that
NFSv4.1's RECLAIM_NOGRACE recovery does not appear to work correctly.
At this point, I think this is an existing problem, and is not
introduced by the purge-state patch itself.  I'll keep looking at this
issue and may post a bug-fix or two at some later time.

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
 fs/nfs/internal.h                   |   10 +-
 fs/nfs/netns.h                      |    5 +
 fs/nfs/nfs4_fs.h                    |    8 -
 fs/nfs/nfs4filelayoutdev.c          |    2 
 fs/nfs/nfs4proc.c                   |   76 +++++++++----
 fs/nfs/nfs4renewd.c                 |    2 
 fs/nfs/nfs4state.c                  |   15 ++-
 fs/nfs/nfs4xdr.c                    |   18 ++-
 fs/nfs/super.c                      |    4 -
 include/linux/nfs_fs.h              |    1 
 include/linux/nfs_fs_sb.h           |   17 ++-
 include/linux/nfs_xdr.h             |   12 +-
 15 files changed, 220 insertions(+), 160 deletions(-)

-- 
Signature
