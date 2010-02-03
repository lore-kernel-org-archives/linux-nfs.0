Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932905Ab0BDUdL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 15:33:11 -0500
From: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 0/6] nfs: renewd fixes
Date: Tue,  2 Feb 2010 16:06:10 -0800
Message-Id: <1265155576-7618-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This set of patches is yet another attempt to fix a couple of issues with renewd.
Patch 1/6 makes sure that renewd is synchronously killed before sending a destroy_session to the server.
Patch 2/6 schedules new renewd request only if a previous one returns (error or success).
Patch 3-4/6 fix the umount race by forcing renewd to take/put a client reference, so access to nfs_free_client is serialized.
Patch 5/6 sets a timeout (similar to timeo) for the nfs_client->rpcclient that equals the server advertised lease_time. This ensures that NFS requests fail (so they can be retried) within a lease period.
Patch 6/6 makes the internal timeouts of the RPC layer sensitive to the major timeout value; IOW there is no point in sleeping waiting for an event for longer than the remaining time before a major timeout.


Alexandros Batsakis (6):
  nfs: kill renewd before clearing client minor version
  nfs: prevent backlogging of renewd requests
  nfs41: fix race between umount and renewd sequence operations
  nfs4: fix race between umount and renewd renew operations
  nfs4: adjust rpc timeout for nfs_client rpc client based on the
    lease_time
  RPC: adjust timeout for connect, bind, restablish so that they
    sensitive to the major time out value

 fs/nfs/client.c       |   45 +++++++++++++++++++++----------------------
 fs/nfs/nfs4proc.c     |   50 +++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4renewd.c   |   19 ++++++-----------
 net/sunrpc/clnt.c     |    2 +-
 net/sunrpc/sunrpc.h   |    2 +
 net/sunrpc/xprt.c     |   18 ++++++++++++++--
 net/sunrpc/xprtsock.c |   12 +++++++++-
 7 files changed, 105 insertions(+), 43 deletions(-)

