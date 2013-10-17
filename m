Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22551 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758031Ab3JQSMN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:13 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICCZW012380
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:13 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICCo3004075
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:12 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/21] Basic NFSv4 migration support
Date: Thu, 17 Oct 2013 14:12:11 -0400
Message-Id: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are the remaining patches required to support basic forms of
NFSv4 migration.  These apply on and have been tested with 3.12-rc5.

NFSv4.1 migration support remains provisional.

There are still some nits to work out about what happens to an
nfs_client once all its nfs_server's are migrated away.

---

Chuck Lever (20):
      SUNRPC: Modify synopsis of rpc_client_register()
      NFS: Add nfs4_update_server
      NFS: Add functions to swap transports during migration recovery
      NFS: Introduce a vector of migration recovery ops
      NFS: Export _nfs_display_fhandle()
      NFS: Add method to retrieve fs_locations during migration recovery
      NFS: Add a super_block backpointer to the nfs_server struct
      NFS: Add basic migration support to state manager thread
      NFS: Re-use exit code in nfs4_async_handle_error()
      NFS: Rename "stateid_invalid" label
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Handle NFS4ERR_MOVED during delegation recall
      NFS: Add method to detect whether an FSID is still on the server
      NFS: Support NFS4ERR_LEASE_MOVED recovery in state manager
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Migration support for RELEASE_LOCKOWNER
      NFS: Handle NFS4ERR_LEASE_MOVED during async RENEW
      NFS: Handle SEQ4_STATUS_LEASE_MOVED
      NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR
      NFS: Fix possible endless state recovery wait

Trond Myklebust (1):
      SUNRPC: Add a helper to switch the transport of an rpc_clnt


 fs/nfs/Kconfig              |   11 +
 fs/nfs/client.c             |    3 
 fs/nfs/inode.c              |    2 
 fs/nfs/internal.h           |    3 
 fs/nfs/nfs4_fs.h            |   16 ++
 fs/nfs/nfs4client.c         |  111 +++++++++++++
 fs/nfs/nfs4namespace.c      |  101 ++++++++++++
 fs/nfs/nfs4proc.c           |  372 +++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4state.c          |  249 ++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c            |  113 ++++++++++++-
 fs/nfs/super.c              |    1 
 include/linux/nfs4.h        |    1 
 include/linux/nfs_fs_sb.h   |    8 +
 include/linux/nfs_xdr.h     |   17 ++
 include/linux/sunrpc/clnt.h |    4 
 net/sunrpc/clnt.c           |  120 ++++++++++++--
 16 files changed, 1081 insertions(+), 51 deletions(-)

-- 
Chuck Lever
