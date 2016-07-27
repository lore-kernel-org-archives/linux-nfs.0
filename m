Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:55629 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757928AbcG0SpE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2016 14:45:04 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 7 0/8] pNFS file layout session trunking
Date: Wed, 27 Jul 2016 14:43:12 -0400
Message-ID: <1469645000-19791-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This patch set differs from previous session trunking patch sets in that it
only addresses pNFS filelayout data server session trunking.

Andy Adamson (8):
  NFS setup async exchange_id
  NFS refactor nfs4_match_clientids
  NFS refactor nfs4_check_serverowner_major_id
  NFS detect session trunking
  SUNRPC add remove xprt flag to rpc_task_release_client
  SUNRPC add an RPC null call to test session trunking connection
  NFS test session trunking with exchange id
  NFS pnfs data server multipath session trunking

 fs/nfs/nfs4_fs.h            |   9 ++
 fs/nfs/nfs4client.c         | 114 ++++++++++++++--
 fs/nfs/nfs4proc.c           | 310 ++++++++++++++++++++++++++++++++------------
 fs/nfs/pnfs_nfs.c           |  52 ++++++--
 include/linux/sunrpc/clnt.h |   4 +-
 net/sunrpc/clnt.c           |  25 +++-
 net/sunrpc/sched.c          |   2 +-
 net/sunrpc/xprtmultipath.c  |   2 +
 8 files changed, 402 insertions(+), 116 deletions(-)

-- 
1.8.3.1

