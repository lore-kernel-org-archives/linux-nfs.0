Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:61627 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbaI1DzD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 23:55:03 -0400
Received: by mail-ie0-f180.google.com with SMTP id ar1so15190445iec.11
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 20:55:02 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/2] Fix NFS client state recovery
Date: Sat, 27 Sep 2014 23:54:56 -0400
Message-Id: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Client should not declare unreclaimed locks to be stale just because
  SETCLIENTID_CONFIRM or CREATE_SESSION fail with NFS4ERR_STALE_CLIENTID
- Fix open/state recovery error handling

Trond Myklebust (2):
  NFSv4: Fix lock recovery when CREATE_SESSION/SETCLIENTID_CONFIRM fails
  NFSv4: fix open/lock state recovery error handling

 fs/nfs/nfs4state.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

-- 
1.9.3

