Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36154 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbcHFUil (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2016 16:38:41 -0400
Received: by mail-io0-f193.google.com with SMTP id y34so26434195ioi.3
        for <linux-nfs@vger.kernel.org>; Sat, 06 Aug 2016 13:38:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] Client reconnection fixes
Date: Fri,  5 Aug 2016 19:37:32 -0400
Message-Id: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v1: Cap the backoff timer to the max RPC message timeout
v2: Add a cap at 1/2 NFSv4 lease period to ensure we don't miss lease renewal

Trond Myklebust (3):
  SUNRPC: Limit the reconnect backoff timer to the max RPC message
    timeout
  NFSv4: Cleanup the setting of the nfs4 lease period
  NFSv4: Cap the transport reconnection timer at 1/2 lease period

 fs/nfs/nfs4_fs.h            |  4 ++++
 fs/nfs/nfs4proc.c           |  9 +++------
 fs/nfs/nfs4renewd.c         | 20 ++++++++++++++++++++
 fs/nfs/nfs4state.c          |  9 +++------
 include/linux/sunrpc/clnt.h |  2 ++
 include/linux/sunrpc/xprt.h |  3 ++-
 net/sunrpc/clnt.c           | 24 ++++++++++++++++++++++++
 net/sunrpc/xprtsock.c       | 18 ++++++++++++------
 8 files changed, 70 insertions(+), 19 deletions(-)

-- 
2.7.4

