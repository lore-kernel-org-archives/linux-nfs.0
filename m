Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:61755 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701AbcBXR4x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:53 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/8] NFSV4.1,2 session trunking
Date: Wed, 24 Feb 2016 12:56:19 -0500
Message-ID: <1456336587-17374-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This patch set requires changes to mount.nfs in the
"Add multihostname support for NFSv4.1,2" nfs-utils patchset.

Note: I did not call EXCHANGE_ID on the mulihostnames in the state
manager, as they are synchronous RPC calls that occur directly after
the nfs_client->cl_rpcclient has been established.  I can change this
if needed.

Also note that I do not have code to call BIND_CONN_TO_SESSION if
sp4_how is not SP4_NONE. I can add this in the next version.


Andy Adamson (8):
  NFS parse multiple hostnames
  NFS default callback ops
  NFS refactor nfs4_match_clientids
  NFS refactor nfs4_check_serverowner_major_id
  NFS detect session trunking
  NFS refactor _nfs4_proc_exchange_id for session trunking
  SUNRPC add flag to rpc_task_release_client
  NFS test and add multi-addrs for session trunking

 fs/nfs/internal.h           |  21 +++++++++
 fs/nfs/nfs4_fs.h            |   9 ++++
 fs/nfs/nfs4client.c         | 110 ++++++++++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4proc.c           |  78 +++++++++++++++++++++++++++----
 fs/nfs/super.c              |  40 ++++++++++++++++
 include/linux/sunrpc/clnt.h |   2 +-
 net/sunrpc/clnt.c           |   6 +--
 net/sunrpc/sched.c          |   2 +-
 net/sunrpc/xprtmultipath.c  |   3 ++
 9 files changed, 246 insertions(+), 25 deletions(-)

-- 
1.8.3.1

