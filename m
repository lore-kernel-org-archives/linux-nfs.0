Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37829 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbaCESaP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 13:30:15 -0500
Received: by mail-ig0-f172.google.com with SMTP id uq10so8449472igb.5
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 10:30:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/4] NFSv4 fix nfs4_stateid_is_current processing
Date: Wed,  5 Mar 2014 13:30:07 -0500
Message-Id: <1394044211-22302-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1394028452-15956-1-git-send-email-trond.myklebust@primarydata.com>
References: <1394028452-15956-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Final tweaks:
- Remove the redundant return value in nfs4_copy_lock_stateid.
- Add comments


Andy Adamson (1):
  NFSv4.1 Fail data server I/O if stateid represents a lost lock

Trond Myklebust (3):
  NFSv4: nfs4_stateid_is_current should return 'true' for an invalid
    stateid
  NFSv4: Fix the return value of nfs4_select_rw_stateid
  NFSv4: Fail the truncate() if the lock/open stateid is invalid

 fs/nfs/nfs4filelayout.c | 10 ++++++----
 fs/nfs/nfs4proc.c       | 14 +++++++++-----
 fs/nfs/nfs4state.c      | 14 +++-----------
 3 files changed, 18 insertions(+), 20 deletions(-)

-- 
1.8.5.3

