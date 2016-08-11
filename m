Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:21904 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbcHKVlU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 17:41:20 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 8 00/12] pNFS file layout session trunking
Date: Thu, 11 Aug 2016 17:39:22 -0400
Message-ID: <1470951574-18441-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Responded to version-7 comments:

- Removed call to rpc_task_release_client from rpc_task_set_client

- Don't leak the rpc_xprt_switch to the NFS layer
  Added wrappers in net/sunrpc/clnt.c  including a new
  rpc_clnt_add_xprt setup function to call into the NFS
  layer.

- Check if a transport has already been added to the xprt switch
  This is done in rpc_xprt_switch_add_xprt. Also done in the first
  new rpc_clnt_add_xprt setup function to avoid an unnecessary
  EXCHANGE_ID.

- Added rpc_xprt_switch test in nfs_match_client so we find an
  nfs_client that is using an rpc_xprt_switch address.

Also:
- The new rpc_clnt_add_xprt setup function returns 1 and added a
  call to rpc_xprt_switch_add_xprt to the session trunk
  case of nfs4_exchange_id_done.

- Saved the mount exchange id verifier in cl_confirm and use it
  in session trunking exchange id's

Testing: pynfs server configured with pnfs mulitpath data servers
- tested working, unconfigured, and repeated ipv4 multipath
   addresses

Andy Adamson (12):
  NFS setup async exchange_id
  NFS refactor nfs4_match_clientids
  NFS refactor nfs4_check_serverowner_major_id
  NFS detect session trunking
  SUNRPC remove rpc_task_release_client from rpc_task_set_client
  SUNRPC rpc_clnt_xprt_switch_put
  SUNRPC rpc_clnt_xprt_switch_add_xprt
  SUNRPC search xprt switch for sockaddr
  SUNRPC: rpc_clnt_add_xprt setup function for NFS layer
  NFS add xprt switch addrs test to match client
  NFS test session trunking with exchange id
  NFS pnfs data server multipath session trunking

 fs/nfs/client.c                      |   5 +-
 fs/nfs/internal.h                    |   3 +
 fs/nfs/nfs4_fs.h                     |   8 +
 fs/nfs/nfs4client.c                  | 114 ++++++++++++--
 fs/nfs/nfs4proc.c                    | 294 +++++++++++++++++++++++++----------
 fs/nfs/pnfs_nfs.c                    |  56 +++++--
 include/linux/sunrpc/clnt.h          |  17 ++
 include/linux/sunrpc/xprtmultipath.h |   2 +
 net/sunrpc/clnt.c                    |  93 ++++++++++-
 net/sunrpc/xprtmultipath.c           |  24 ++-
 10 files changed, 502 insertions(+), 114 deletions(-)

-- 
1.8.3.1

