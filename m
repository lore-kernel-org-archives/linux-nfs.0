Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:37920 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaKLWcL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 17:32:11 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so14705233iec.3
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 14:32:10 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] Fix up delegation reclaim and recovery issues
Date: Wed, 12 Nov 2014 17:31:49 -0500
Message-Id: <1415831514-47005-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main change w.r.t. the first iteration of these patches is that
we no longer trust the NFS_DELEGATED_STATE flag to tell us when we need
to test and/or discard the delegation. Instead, we just assume that
if we have a delegation then it is part of the recovery process.

Trond Myklebust (5):
  NFSv4: Ensure that we remove NFSv4.0 delegations when state has
    expired
  NFSv4.1: nfs41_clear_delegation_stateid shouldn't trust
    NFS_DELEGATED_STATE
  NFSv4: Fix races between nfs_remove_bad_delegation() and delegation
    return
  NFSv4: Ensure that we call FREE_STATEID when NFSv4.x stateids are
    revoked
  NFS: Don't try to reclaim delegation open state if recovery failed

 fs/nfs/delegation.c            | 25 ++++++++++++--
 fs/nfs/delegation.h            |  1 +
 fs/nfs/filelayout/filelayout.c |  3 --
 fs/nfs/nfs4proc.c              | 76 +++++++++++++++++++++++-------------------
 4 files changed, 65 insertions(+), 40 deletions(-)

-- 
1.9.3

