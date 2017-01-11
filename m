Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46892 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751480AbdAKSzH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:07 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/11] Create a single nfs4_setup_sequence() function
Date: Wed, 11 Jan 2017 13:54:43 -0500
Message-ID: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

I noticed that NFS v4.0 and v4.1 have different setup_sequence() functions
that are very, very similar.  I think we should try to share as much code
as possible whenever possible, so these patches merge together both versions
of this function using the presence of a session to decide if we need to do
a little extra work in some cases.

I broke this change into several logical steps that (hopefully) make it easier
to follow what I did.

Questions? Comments? Thoughts?
Anna


Anna Schumaker (11):
  NFS: Move nfs4_get_session() into nfs4_session.h
  NFS: Change nfs4_get_session() to take an nfs_client structure
  NFS: Change nfs4_setup_sequence() to take an nfs_client structure
  NFS: Use nfs4_setup_sequence() everywhere
  NFS: Create a single nfs4_setup_sequence() function
  NFS: Move slot-already-allocated check into nfs_setup_sequence()
  NFS: Lock the slot table from a single place during setup sequence
  NFS: Handle setup sequence task rescheduling in a single place
  NFS: Check if the slot table is draining from nfs4_setup_sequence()
  NFS: Merge the remaining setup_sequence functions
  NFS: Make trace_nfs4_setup_sequence() available to NFS v4.0

 fs/nfs/filelayout/filelayout.c         |   6 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |  40 ++----
 fs/nfs/nfs42proc.c                     |   6 +-
 fs/nfs/nfs4_fs.h                       |  15 +-
 fs/nfs/nfs4proc.c                      | 244 +++++++++++----------------------
 fs/nfs/nfs4session.h                   |   7 +
 fs/nfs/nfs4trace.h                     |  64 ++++-----
 7 files changed, 139 insertions(+), 243 deletions(-)

-- 
2.11.0

