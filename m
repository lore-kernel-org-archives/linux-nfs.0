Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46795 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752130AbdDGSPo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:44 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/34] dprintk() cleanup (part 1)
Date: Fri, 7 Apr 2017 14:14:54 -0400
Message-ID: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

We have around 750 dprintk()s in the NFS client alone, and many of these
simply tell us when we're entering or leaving a function (usually both).
This can create a lot of noise when you're trying to debug a single issues,
and I think many dprintk()s can be cut out in favor of tracepoints or dynamic
tracing through SystemTap.

This patch set does just that. I went through some of our files one by one
and removed dprintk()s that seemed to be unnecessary. Occasionally this
allowed me to refactor the surrounding code, so I tried to make individual
patches for each function I refactored.

These patches make changes to the following files:
    - callback_proc.c
    - callback_xdr.c
    - client.c
    - direct.c
    - namespace.c
    - nfs42proc.c
    - nfs4client.c
    - nfs4getroot.c
    - nfs4namespace.c
    - nfs4proc.c

What does everybody think?  Are any of these dprintk()s worth holding on to?

Thanks,
Anna


Anna Schumaker (34):
  NFS: Clean up do_callback_layoutrecall()
  NFS: Clean up nfs4_callback_layoutrecall()
  NFS: Remove extra dprintk()s from callback_proc.c
  NFS: Clean up decode_getattr_args()
  NFS: Clean up decode_recall_args()
  NFS: Clean up decode_layoutrecall_args()
  NFS: Clean up decode_cb_sequence_args()
  NFS: Clean up decode_notify_lock_args()
  NFS: Clean up encode_cb_sequence_res()
  NFS: Remove extra dprintk()s from callback_xdr.c
  NFS: Clean up nfs_init_client()
  NFS: Clean up extra dprintk()s in client.c
  NFS: Remove nfs_direct_readpage_release()
  NFS: Clean up nfs_direct_commit_complete()
  NFS: Remove extra dprintk()s from namespace.c
  NFS: Clean up nfs42_layoutstat_done()
  NFS: Clean up nfs4_match_clientids()
  NFS: Clean up nfs4_check_serverowner_minor_id()
  NFS: Create a common nfs4_match_client() function
  NFS: Clean up nfs4_check_serverowner_major_id()
  NFS: Clean up nfs4_check_server_scope()
  NFS: Clean up nfs4_set_client()
  NFS: Clean up nfs4_init_server()
  NFS: Remove extra dprintk()s from nfs4client.c
  NFS: Clean up nfs4_get_rootfh()
  NFS: Remove extra dprintk()s from nfs4namespace.c
  NFS: Clean up nfs4_proc_bind_one_conn_to_session()
  NFS: Clean up _nfs4_proc_exchange_id()
  NFS: Clean up nfs4_proc_get_lease_time()
  NFS: Clean up nfs41_proc_async_sequence()
  NFS: Clean up nfs4_proc_sequence()
  NFS: Clean up nfs41_proc_reclaim_complete()
  NFS: Clean up nfs4_layoutget_handle_exception()
  NFS: Remove extra dprintk()s from nfs4proc.c

 fs/nfs/callback_proc.c |  41 +------
 fs/nfs/callback_xdr.c  | 109 +++++--------------
 fs/nfs/client.c        |  65 ++----------
 fs/nfs/direct.c        |  21 +---
 fs/nfs/namespace.c     |  34 ++----
 fs/nfs/nfs42proc.c     |   2 -
 fs/nfs/nfs4client.c    | 283 ++++++++++++++-----------------------------------
 fs/nfs/nfs4getroot.c   |   3 -
 fs/nfs/nfs4namespace.c |   7 +-
 fs/nfs/nfs4proc.c      | 274 +++++++----------------------------------------
 10 files changed, 167 insertions(+), 672 deletions(-)

-- 
2.12.2

