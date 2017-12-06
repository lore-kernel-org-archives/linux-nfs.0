Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39908 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752111AbdLFTBL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Dec 2017 14:01:11 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC][PATCH 0/1] Stop mounts hanging for user lever daemons
Date: Wed,  6 Dec 2017 14:01:07 -0500
Message-Id: <20171206190108.11678-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an RFC patch because I'm not sure if this is
the right way to do this... There might be a better way.

Recently I've had some problems with upcalls, during 
mounts, hanging. The reason the hang is happening is one 
problem but it occurred to me the kernel should not 
hang forever for a daemon that may never come back.

Now a couple thoughts... 

1) How should the mount be failed. If ETIMEDOUT
is used, the mount will be retied via the 
nfs4_discover_server_trunking() code.

But, if the daemon is not responding why keep trying?
We could error out the mount with EPIPE which cause
the mount fail immediately and logging this error 
message
   NFS: nfs4_discover_server_trunking unhandled error 32. Exiting with error EIO

2) Is there a better way to do this? That timeout code
looks a bit crusty :-) 

3) Is the 10 sec timeout to short? Maybe we could bump
it up to a 30 sec timeout? If do that I would suggest 
we error out the mount immediately with EPIPE.

4) Am I missing something? 

Steve Dickson (1):
  auth_rpcgss: Add a timer to the gss upcall.

 net/sunrpc/auth_gss/auth_gss.c | 43 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

-- 
2.14.3

