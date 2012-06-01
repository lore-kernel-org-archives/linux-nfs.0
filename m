Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:62088 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab2FAPh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 11:37:59 -0400
Received: by gglu4 with SMTP id u4so1852045ggl.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2012 08:37:59 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Address several issues with TEST_STATEID
To: linux-nfs@vger.kernel.org
Date: Fri, 01 Jun 2012 11:37:57 -0400
Message-ID: <20120601153231.5626.89559.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

While testing the recently introduced PURGE_STATE logic, I found some
issues with the error handling logic under nfs41_open_expired().

After fixing these issues, I am able to get Connectathon basic,
general, and special tests to pass with a server rigged to assert
SEQ4_STATUS_ADMIN_STATE_REVOKED at regular intervals.  The
Connectathon lock tests encounter a deadlock, which I've already
reported, that appears to pre-date PURGE_STATE.

---

Chuck Lever (4):
      NFS: Refactor nfs41_check_expired_stateid()
      NFS: state reclaim clears OPEN state
      NFS: Properly sort TEST_STATEID results
      NFS: Clean up TEST_STATEID and FREE_STATEID proc error reporting


 fs/nfs/nfs4proc.c |  144 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 115 insertions(+), 29 deletions(-)

-- 
Chuck Lever
