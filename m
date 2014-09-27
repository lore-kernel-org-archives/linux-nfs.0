Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:40854 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbaI0WUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 18:20:25 -0400
Received: by mail-ie0-f177.google.com with SMTP id x19so17014837ier.8
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 15:20:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Fix NFS client state recovery
Date: Sat, 27 Sep 2014 18:20:13 -0400
Message-Id: <1411856415-4472-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Fix up client to work with NFSv4/v4.1 all or nothing reboot recovery
- Fix open/state recovery error handling


Trond Myklebust (2):
  NFSv4: Don't convert unreclaimed locks on STALE_CLIENTID
  NFSv4: fix open/lock state recovery error handling

 fs/nfs/nfs4state.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

-- 
1.9.3

