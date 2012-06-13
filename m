Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35089 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab2FMSUQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 14:20:16 -0400
Received: by yenl2 with SMTP id l2so237820yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2012 11:20:16 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Take 2: TEST_STATEID fix-ups
To: linux-nfs@vger.kernel.org
Date: Wed, 13 Jun 2012 14:20:14 -0400
Message-ID: <20120613181831.5910.74030.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For review.

I discovered a few problems with the new TEST_STATEID implementation
while testing nograce recovery.  Review comments have been addressed,
and these have been rebased on 3.5-rc2.

---

Chuck Lever (4):
      NFS: Refactor nfs41_check_expired_stateid()
      NFS: State reclaim clears OPEN and LOCK state
      NFS: Properly sort TEST_STATEID results
      NFS: Clean up TEST_STATEID and FREE_STATEID proc error reporting


 fs/nfs/nfs4proc.c |  146 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 117 insertions(+), 29 deletions(-)

-- 
Chuck Lever
