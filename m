Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:41983 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbaCEOHf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 09:07:35 -0500
Received: by mail-ig0-f180.google.com with SMTP id hl1so4369852igb.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 06:07:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/4] NFSv4 fix nfs4_stateid_is_current processing
Date: Wed,  5 Mar 2014 09:07:28 -0500
Message-Id: <1394028452-15956-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
References: <1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added a patch to fall through and recover when the stateid is invalid.

Andy Adamson (1):
  NFSv4.1 Fail data server I/O if stateid represents a lost lock

Trond Myklebust (3):
  NFSv4: nfs4_stateid_is_current should return 'true' for an invalid
    stateid
  NFSv4: Fix the return value of nfs4_select_rw_stateid
  NFSv4: Fail the truncate() if the lock/open stateid is invalid

 fs/nfs/nfs4filelayout.c | 10 ++++++----
 fs/nfs/nfs4proc.c       | 13 ++++++++-----
 fs/nfs/nfs4state.c      |  6 ------
 3 files changed, 14 insertions(+), 15 deletions(-)

-- 
1.8.5.3

