Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50591 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758920Ab1FVVhJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 17:37:09 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 00/11] NFS: Support binding to source address
Date: Wed, 22 Jun 2011 14:36:40 -0700
Message-Id: <1308778611-9370-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This lets one specify the source IP address for
sockets, allowing users to leverage routing rules
on multi-homed systems.

Patches are also needed to nfs-utils.  These have been
posted and will be accepted if the kernel support is
accepted.

Ben Greear (11):
  sunrpc:  Don't attempt to bind to AF_UNSPEC address.
  nfs:  Two AF_UNSPEC addresses should always match each other.
  nfs:  Add srcaddr member to nfs_client.
  nfs:  Use request destination addr as callback source addr.
  nfs:  Pay attention to srcaddr in v4.1 callback logic.
  nfs:  Use srcaddr in nfs_match_client.
  nfs:  Add srcaddr to /proc/fs/nfsfs/servers
  nfs:  Pass srcaddr into mount request.
  nfs:  Propagate src-addr in client code.
  nfs: Bind to srcaddr in rpcb_create.
  nfs: Support srcaddr= to bind to specific IP address.

 fs/nfs/callback.h          |    3 ++
 fs/nfs/callback_proc.c     |    3 +-
 fs/nfs/callback_xdr.c      |    3 ++
 fs/nfs/client.c            |   72 +++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h          |   10 +++++-
 fs/nfs/mount_clnt.c        |    1 +
 fs/nfs/super.c             |   33 +++++++++++++++++++-
 include/linux/nfs_fs_sb.h  |    4 ++
 include/linux/sunrpc/svc.h |    5 +++
 net/sunrpc/rpcb_clnt.c     |   28 ++++++++++++++++-
 net/sunrpc/sunrpc.h        |   45 +++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c      |   47 +---------------------------
 12 files changed, 200 insertions(+), 54 deletions(-)

-- 
1.7.3.4

