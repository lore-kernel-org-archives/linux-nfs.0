Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36201 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752480AbdBHQsi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 11:48:38 -0500
Received: by mail-io0-f193.google.com with SMTP id q20so16375689ioi.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 08:48:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] Match TCP connection timeouts to the lease period
Date: Wed,  8 Feb 2017 11:17:51 -0500
Message-Id: <20170208161755.3614-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the current default TCP connection timeout being set at around
3 minutes, and most server vendors setting the lease period at
values significantly lower than that, we can end up losing the lease
while waiting for the TCP layer to discover that we need to break the
connection.
This patch series sets up an interface to allow the NFSv4 client to
adjust thsee timeout values down once it has obtained a value for
the lease period from the server.

Trond Myklebust (4):
  SUNRPC: Remove unused function rpc_get_timeout()
  SUNRPC: Refactor TCP socket timeout code into a helper function
  SUNRPC: Allow changing of the TCP timeout parameters on the fly
  NFSv4: Set the connection timeout to match the lease period

 fs/nfs/nfs4renewd.c             |  2 +-
 include/linux/sunrpc/clnt.h     |  6 +--
 include/linux/sunrpc/xprt.h     |  4 ++
 include/linux/sunrpc/xprtsock.h |  3 ++
 net/sunrpc/clnt.c               | 51 +++++++++++++-----------
 net/sunrpc/xprtsock.c           | 88 ++++++++++++++++++++++++++++++++---------
 6 files changed, 107 insertions(+), 47 deletions(-)

-- 
2.9.3

