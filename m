Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:49074 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754360AbcIAPqj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Sep 2016 11:46:39 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 RESEND 00/12] pNFS file layout session trunking
Date: Thu, 1 Sep 2016 11:44:41 -0400
Message-ID: <1472744693-124241-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RESEND: added put_rpccred to to _nfs4_pnfs_v4_ds_connect in 
"NFS pnfs data server multipath session trunking"

Responded to Version-8 comments

- renamed rpc_clnt_xprt_switch_find_addr
- spelling nits
- moved rpc_cnt_xprt_switch_add_xprt into
  nfs4_detect_session_trunking
 

*** BLURB HERE ***

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
 fs/nfs/nfs4client.c                  | 117 ++++++++++++--
 fs/nfs/nfs4proc.c                    | 287 ++++++++++++++++++++++++-----------
 fs/nfs/pnfs_nfs.c                    |  58 +++++--
 include/linux/sunrpc/clnt.h          |  17 +++
 include/linux/sunrpc/xprtmultipath.h |   2 +
 net/sunrpc/clnt.c                    |  93 +++++++++++-
 net/sunrpc/xprtmultipath.c           |  24 ++-
 10 files changed, 500 insertions(+), 114 deletions(-)

-- 
1.8.3.1

