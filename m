Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757943Ab2FTTyG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:06 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/10] NFS: Create new RPC operations
Date: Wed, 20 Jun 2012 15:53:39 -0400
Message-Id: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These patches begin splitting out various NFS features from the generic
client.  Most of the time I create a new {rpc, file, super} operation
pointing to an NFS version specific implementation, such as NFS v4
delegation functions which don't need to do as much in the v2 or v3 case.

These patches are a prerequisite for my modularization patches.  The idea
is that each NFS module can have its own self-contained implementation for
each feature.

Questions and comments are appreciated!

- Bryan

Bryan Schumaker (10):
  NFS: set_pnfs_layoutdriver() from nfs4_proc_fsinfo()
  NFS: Use nfs4_destroy_server() to clean up NFS v4
  NFS: Create a v4-specific fsync function
  NFS: Create a have_delegation rpc_op
  NFS: Create a return_delegation rpc op
  NFS: Create a free_client rpc_op
  NFS: Create an alloc_client rpc_op
  NFS: Create an read_pageio_init() function
  NFS: Create an write_pageio_init() function
  NFS: Create custom NFS v4 write_inode() function

 fs/nfs/client.c         | 62 +++++++++++++++++++++++++++++--------------------
 fs/nfs/delegation.c     |  7 +++---
 fs/nfs/delegation.h     | 19 ++++-----------
 fs/nfs/dir.c            | 10 ++++----
 fs/nfs/file.c           | 46 +++++++++++++++++++++++++++---------
 fs/nfs/inode.c          |  4 ++--
 fs/nfs/internal.h       |  6 +++--
 fs/nfs/nfs3proc.c       | 17 ++++++++++++++
 fs/nfs/nfs4_fs.h        |  7 ++++++
 fs/nfs/nfs4proc.c       | 24 ++++++++++++++-----
 fs/nfs/pnfs.c           | 22 ++++++++----------
 fs/nfs/pnfs.h           | 12 +++++-----
 fs/nfs/proc.c           | 17 ++++++++++++++
 fs/nfs/read.c           | 16 +++----------
 fs/nfs/super.c          | 25 +++++---------------
 fs/nfs/unlink.c         |  2 +-
 fs/nfs/write.c          | 31 +++++++++++++------------
 include/linux/nfs_xdr.h | 10 ++++++++
 18 files changed, 201 insertions(+), 136 deletions(-)

-- 
1.7.11

