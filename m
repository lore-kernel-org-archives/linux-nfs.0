Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21799 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116Ab2BQSFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 13:05:46 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/2]  NFSv4.1: Fix a NFSv4.1 session initialisation regression
Date: Fri, 17 Feb 2012 13:05:21 -0500
Message-Id: <1329501923-3999-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Tronds patch to fix the regression with one change - the slot table 
highest_used_slotid needs to be initialized in nfs4_alloc_session so that
nfs41_init_clientid doesn't wait forever in nfs4_wait_on_slot_tbl  (called
by nfs4_begin_drain_session).

Also a patch to use NFS4_NO_SLOT in nfs4_wait_on_slot_tbl.

Tested CB_RECALL_SLOT and session reset using pynfs. Passed Cthon tests
against Linux NFSv4.1 server.

Compiled against Trond's 3.3-rc2 nfs-for-next tree.

Andy Adamson (1):
  NFSv4.1 set highest_used_slotid to NFS4_NO_SLOT

Trond Myklebust (1):
  NFSv4.1: Fix a NFSv4.1 session initialisation regression

 fs/nfs/nfs4proc.c  |  111 ++++++++++++++++++++-------------------------------
 fs/nfs/nfs4state.c |    2 +-
 2 files changed, 45 insertions(+), 68 deletions(-)

-- 
1.7.6.4

