Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:23965 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751139AbdAQUcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:51 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 00/10] Various cleanups to nfs4proc.c
Date: Tue, 17 Jan 2017 15:31:55 -0500
Message-ID: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

I skimmed through the file and cleaned up a few things that stuck out to me.

Thoughts?
Anna

Anna Schumaker (10):
  NFS: Fix inconsistent indentation in nfs4proc.c
  NFS: Clean up _nfs4_is_integrity_protected()
  NFS: Remove nfs4_wait_for_completion_rpc_task()
  NFS: Return errors directly in _nfs4_opendata_reclaim_to_nfs4_state()
  NFS: Remove an extra if in _nfs4_recover_proc_open()
  NFS: Remove nfs4_recover_expired_lease()
  NFS: Remove unnecessary goto in nfs4_lookup_root_sec()
  NFS: No need to set and return status in nfs41_lock_expired()
  NFS: Clean up nfs41_same_server_scope()
  NFS: Return the comparison result directly in nfs41_match_stateid()

 fs/nfs/nfs4proc.c | 132 ++++++++++++++++++++----------------------------------
 1 file changed, 48 insertions(+), 84 deletions(-)

-- 
2.11.0

