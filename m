Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:37002 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbaDJUhK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:37:10 -0400
Received: by mail-qa0-f41.google.com with SMTP id j5so4455399qaq.14
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:37:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfs: fix v4.0 callback channel auth failures
Date: Thu, 10 Apr 2014 16:29:48 -0400
Message-Id: <1397161791-29144-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Earlier this week, we had a lively discussion about how to fix the
bogus way that the callback channel tries to authenticate requests
coming in. The consensus was that the right approach is to save off
the acceptor name in a GSSAPI SETCLIENTID call, and then to compare
that to the initiator name in the callback requests.

This patchset is the kernel portion of that change. There is also
a companion patchset for gssd to make it pass the acceptor name
to the kernel in the downcall.

Jeff Layton (3):
  auth_gss: fetch the acceptor name out of the downcall
  sunrpc: add a new "stringify_acceptor" rpc_credop
  nfs4: copy acceptor name from context to nfs_client

 fs/nfs/callback.c               | 12 ++++++
 fs/nfs/client.c                 |  1 +
 fs/nfs/nfs4proc.c               | 30 ++++++++++++++-
 include/linux/nfs_fs_sb.h       |  1 +
 include/linux/nfs_xdr.h         |  1 +
 include/linux/sunrpc/auth.h     |  2 +
 include/linux/sunrpc/auth_gss.h |  1 +
 net/sunrpc/auth.c               |  9 +++++
 net/sunrpc/auth_gss/auth_gss.c  | 82 +++++++++++++++++++++++++++++------------
 9 files changed, 115 insertions(+), 24 deletions(-)

-- 
1.9.0

