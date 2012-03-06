Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893Ab2CFOqw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 09:46:52 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/3] NFS recover from delegation stateid error
Date: Tue,  6 Mar 2012 09:46:42 -0500
Message-Id: <1331045205-3031-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

These patches fix recovery from NFS4ERR_BAD_STATEID, NFS4ERR_ADMIN_REVOKED, and
NFS4ERR_DELEG_REVOKED errors by removing the delegation record, testing the
delegation stateid, and recovering via an OPEN with CLAIM_NULL.

Tested with a pynfs test that removes the pynfs server delegation stateid 
and return NFS4ERR_BAD_STATEID upon a READ.

Andy Adamson (1):
  NFSv4.1 do not clear NFS_DELEAGED_STATE until stateid is tested

Trond Myklebust (2):
  NFSv4.1: Fix the checking of the stateid when returning a delegation
  NFS: Properly handle the case where the delegation is revoked

 fs/nfs/callback_proc.c |    6 +++---
 fs/nfs/delegation.c    |   13 ++++++++++++-
 fs/nfs/delegation.h    |    1 +
 fs/nfs/nfs4_fs.h       |    2 ++
 fs/nfs/nfs4proc.c      |   16 ++++++++++++++--
 fs/nfs/nfs4state.c     |   31 ++++++++++++++++++++++++++++++-
 6 files changed, 62 insertions(+), 7 deletions(-)

-- 
1.7.6.4

