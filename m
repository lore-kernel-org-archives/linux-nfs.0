Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35783 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbeCTUnn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:43 -0400
Received: by mail-io0-f194.google.com with SMTP id e7so4015290iof.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/8] Don't return delegations unnecessarily in NFSv4.1
Date: Tue, 20 Mar 2018 16:43:12 -0400
Message-Id: <20180320204320.93656-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following is a patch series that fixes up the delegation code so
that the NFSv4.1 client will attempt to hold on to a write delegation
across link(), rename() and sillyrename() operations, as well as
across chown, chmod and setacl.

The behaviour of the NFSv4.0 client should remain unchanged. Ditto
for the behaviour of the NFSv4.1 client concerning read delegations.

Trond Myklebust (8):
  NFSv4: Fix nfs4_return_incompatible_delegation
  NFS: Move the delegation return down into nfs4_proc_link()
  NFS: Move the delegation return down into nfs4_proc_remove()
  NFS: Move delegation recall into the NFSv4 callback for rename_setup()
  NFS: Add a delegation return into nfs4_proc_unlink_setup()
  NFS: Move the delegation return down into _nfs4_do_setattr()
  NFS: Remove the unused return_delegation() callback
  NFSv4: Don't return the delegation when not needed by NFSv4.x (x>0)

 fs/nfs/delegation.c     | 17 +++++++++++++++
 fs/nfs/delegation.h     |  1 +
 fs/nfs/dir.c            | 11 ++--------
 fs/nfs/inode.c          |  5 -----
 fs/nfs/nfs3proc.c       | 19 ++++++----------
 fs/nfs/nfs4proc.c       | 58 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/proc.c           | 19 ++++++----------
 fs/nfs/unlink.c         |  7 ++----
 include/linux/nfs_xdr.h |  9 ++++----
 9 files changed, 89 insertions(+), 57 deletions(-)

-- 
2.14.3

