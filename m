Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:61585 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaFVAwZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jun 2014 20:52:25 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so4770967qcy.4
        for <linux-nfs@vger.kernel.org>; Sat, 21 Jun 2014 17:52:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] nfsd: fix v4.0 GSSAPI callback channel auth failures
Date: Sat, 21 Jun 2014 20:52:14 -0400
Message-Id: <1403398337-4174-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of the kernel patchset that I sent back in early April
to fix the client's GSSAPI authentication in the v4.0 callback channel.
The userland piece of this has already been merged into nfs-utils.

The only real change here is to move the "stringification" of the
acceptor name out of the rpc_done callback and into the synchronous
caller. As Trond pointed out, we can't do that in rpciod callbacks as it
could recurse into writeback.

The callback now just takes a reference to the rpccred and stores a
pointer to it in the nfs4_setclientid struct. If that's non-NULL after
the call returns, we do the stringification there and then put the cred.

Jeff Layton (3):
  auth_gss: fetch the acceptor name out of the downcall
  sunrpc: add a new "stringify_acceptor" rpc_credop
  nfs4: copy acceptor name from context to nfs_client

 fs/nfs/callback.c               | 12 ++++++
 fs/nfs/client.c                 |  1 +
 fs/nfs/nfs4proc.c               | 33 ++++++++++++++++-
 include/linux/nfs_fs_sb.h       |  1 +
 include/linux/nfs_xdr.h         |  1 +
 include/linux/sunrpc/auth.h     |  2 +
 include/linux/sunrpc/auth_gss.h |  1 +
 net/sunrpc/auth.c               |  9 +++++
 net/sunrpc/auth_gss/auth_gss.c  | 82 +++++++++++++++++++++++++++++------------
 9 files changed, 118 insertions(+), 24 deletions(-)

-- 
1.9.3

