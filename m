Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8049 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437Ab0AYWEI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:08 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM45Z0004794
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:05 -0800 (PST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/8] What's in the 'bugfixes' branch of the NFS client git
 tree
To: linux-nfs@vger.kernel.org
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215734.14716.19614.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've committed the following patches to the 'bugfixes' branch for
merging into mainline before the release of 2.6.33. Please review

Cheers
  Trond

---

David Howells (1):
      NFS: Avoid warnings when CONFIG_NFS_V4=n

H Hartley Sweeten (1):
      NFS: Make nfs_commitdata_release static

Trond Myklebust (6):
      NFS: Ensure that we handle NFS4ERR_STALE_STATEID correctly
      NFSv4.1: Don't call nfs4_schedule_state_recovery() unnecessarily
      NFSv4: Don't allow posix locking against servers that don't support it
      NFSv4: Ensure that the NFSv4 locking can recover from stateid errors
      NFS: Try to commit unstable writes in nfs_release_page()
      NFS: Fix a reference leak in nfs_wb_cancel_page()


 fs/nfs/file.c      |    2 +
 fs/nfs/nfs4_fs.h   |    2 +
 fs/nfs/nfs4proc.c  |   78 +++++++++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4state.c |    2 +
 fs/nfs/sysctl.c    |    2 +
 fs/nfs/write.c     |    3 +-
 6 files changed, 67 insertions(+), 22 deletions(-)

