Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:4156 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbbGMSCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 14:02:01 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 00/10] NFS: Clean up unnecessary functions 
Date: Mon, 13 Jul 2015 14:01:23 -0400
Message-ID: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I went searching for functions that simply pass their arguments to another
function without really adding anything useful.  I figure we can just call
the other function directly instead.

Changes in v2:
- Add rpc_cmp_addr_port() for comparing sockaddr addresses and port numbers.
- Add missing changes to include/linux/nfs_fs.h in patch 10 (NFS: Remove nfs_release())

Let me know what you all think!
Anna


Anna Schumaker (10):
  NFS: Remove unused variable "pages_ptr"
  NFS: Rename nfs_readdir_free_pagearray() and nfs_readdir_large_page()
  SUNRPC: Drop double-underscores from rpc_cmp_addr{4|6}()
  SUNRPC: Add an rpc_cmp_addr_port() function
  NFS: Use RPC functions for matching sockaddrs
  NFS: Combine nfs_idmap_{init|quit}() and
    nfs_idmap_{init|quit}_keyring()
  NFS: Remove nfs4_match_stateid()
  NFS: Remove nfs41_server_notify_{target|highest}_slotid_update()
  NFS: Rename nfs_commit_unstable_pages() to nfs_write_inode()
  NFS: Remove nfs_release()

 fs/nfs/callback_proc.c      |   2 +-
 fs/nfs/client.c             | 113 +-------------------------------------------
 fs/nfs/dir.c                |  20 +++-----
 fs/nfs/file.c               |   3 +-
 fs/nfs/inode.c              |   8 +---
 fs/nfs/internal.h           |   4 --
 fs/nfs/nfs4_fs.h            |   4 +-
 fs/nfs/nfs4client.c         |   5 +-
 fs/nfs/nfs4idmap.c          |  14 +-----
 fs/nfs/nfs4proc.c           |  10 +---
 fs/nfs/nfs4state.c          |  12 +----
 fs/nfs/write.c              |   7 +--
 include/linux/nfs_fs.h      |   2 +-
 include/linux/sunrpc/addr.h |  25 +++++++---
 14 files changed, 40 insertions(+), 189 deletions(-)

-- 
2.4.5

