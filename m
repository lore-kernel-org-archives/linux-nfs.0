Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37720 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab0LXBc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 20:32:26 -0500
Received: by iyi12 with SMTP id 12so5460337iyi.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Dec 2010 17:32:25 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Refactor data structures to support NFSv4 migration (2)
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 23 Dec 2010 20:32:20 -0500
Message-ID: <20101224012636.2445.41411.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond-

Here are four patches that move fields related to NFSv4 state from the
nfs_client struct to the nfs_server struct.  This change facilitates
the eventual implementation of NFSv4 migration.

This series passes simple tests:  Full Cthon suite passes over NFSv4
against an OpenSolaris 2009.6 NFS server, and a full "allmodconfig"
-j3 kernel build completes on NFSv4 without hangs or lockdep splats
on a two-way client.

Since the first series:

 .  Make the new server->delegations unconditionally compiled in
 .  In fs/nfs/nfs4state.c, where possible, take cl_lock after invoking
    rcu_read_lock() instead of before invoking it

---

Chuck Lever (4):
      NFS: Move cl_delegations to the nfs_server struct
      NFS: Introduce nfs_detach_delegations()
      NFS: Move cl_state_owners and related fields to the nfs_server struct
      NFS: Allow walking nfs_client.cl_superblocks list outside client.c


 fs/nfs/client.c           |   46 +++---
 fs/nfs/delegation.c       |  362 ++++++++++++++++++++++++++++++++-------------
 fs/nfs/delegation.h       |    1 
 fs/nfs/nfs4_fs.h          |    2 
 fs/nfs/nfs4renewd.c       |   11 +
 fs/nfs/nfs4state.c        |  251 ++++++++++++++++++++++---------
 include/linux/nfs_fs_sb.h |   11 +
 7 files changed, 481 insertions(+), 203 deletions(-)

-- 
Chuck Lever
