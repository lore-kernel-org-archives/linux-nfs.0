Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54104 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756986Ab3HMVsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 17:48:00 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 0/3] Use the MDS nfs_server authflavor for pNFS data server connections
Date: Tue, 13 Aug 2013 17:47:46 -0400
Message-ID: <1376430469-3773-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Differences from Version 4
- added NFSv4 Remove unused LIPKEY and SPKM enums
- shared GSS context caches when possible via shared rpc_clnt structs
- DS conections use the shared rpc_clnts

Andy Adamson (3):
  NFSv4 Remove unused LIPKEY and SPKM enums
  NFS Share RPC_AUTH_GSS rpc clients
  NFSv4.1 Use the shared nfs_client rpc_clnts for pNFS data server
    connections

 fs/nfs/client.c                 | 80 ++++++++++++++++++++++++++++++++++++++---
 fs/nfs/internal.h               |  4 +++
 fs/nfs/nfs4filelayout.c         | 69 +++++++++++++++++++++++++++++------
 fs/nfs/nfs4filelayout.h         |  3 ++
 fs/nfs/nfs4filelayoutdev.c      |  4 ++-
 fs/nfs/nfs4namespace.c          |  5 +--
 fs/nfs/nfs4proc.c               |  9 +++--
 fs/nfs/nfs4state.c              |  4 +--
 fs/nfs/super.c                  | 34 ------------------
 include/linux/nfs_fs_sb.h       |  1 +
 include/linux/sunrpc/msg_prot.h |  9 ++---
 11 files changed, 158 insertions(+), 64 deletions(-)

-- 
1.8.3.1

