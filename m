Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55120 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759174Ab3HMUhn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 16:37:43 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 0/7] Initial SP4_MACH_CRED implementation
Date: Tue, 13 Aug 2013 16:37:31 -0400
Message-ID: <1376426258-28244-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is version 2 of this patchset including some cleanup, refactoring and
fixes a few build issues with different configs.

I also added a few patches:
 - WRITE and/or COMMIT support - tested on a hacked nfsd
 - map NFS4ERR_WRONG_CRED (an common SP4 error) to EPERM

I meant to include a patch that only uses the machine cred (for 'allow' ops)
when the user cred has expired, but after talking with Andy, I decided to wait
for his cred expiration patchset to be merged as we'd be touching the same
places and possibly duplicating effort.

Weston Andros Adamson (7):
  nfs4.1: Minimal SP4_MACH_CRED implementation
  nfs4.1: Add state protection handler
  nfs4.1: Add SP4_MACH_CRED cleanup support
  nfs4.1: Add SP4_MACH_CRED secinfo support
  nfs4.1: Add SP4_MACH_CRED stateid support
  nfs4.1: Add SP4_MACH_CRED write and commit support
  nfs4: Map NFS4ERR_WRONG_CRED to EPERM

 fs/nfs/nfs4_fs.h          |  67 ++++++++++++++++
 fs/nfs/nfs4proc.c         | 191 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c          |  72 ++++++++++++++---
 fs/nfs/write.c            |   6 ++
 include/linux/nfs_fs_sb.h |   9 +++
 include/linux/nfs_xdr.h   |  19 +++++
 6 files changed, 346 insertions(+), 18 deletions(-)

-- 
1.7.12.4 (Apple Git-37)

