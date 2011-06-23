Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43985 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932729Ab1FWT3z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 15:29:55 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v2 00/12] NFS: Support binding to source address
Date: Thu, 23 Jun 2011 12:29:34 -0700
Message-Id: <1308857388-12243-1-git-send-email-greearb@candelatech.com>
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

v2:  Add patch 11 to bind the NLM client to the proper
     source address as well.

Ben Greear (12):
  sunrpc: Don't attempt to bind to AF_UNSPEC address.
  nfs: Two AF_UNSPEC addresses should always match each other.
  nfs: Add srcaddr member to nfs_client.
  nfs: Use request destination addr as callback source addr.
  nfs: Pay attention to srcaddr in v4.1 callback logic.
  nfs: Use srcaddr in nfs_match_client.
  nfs: Add srcaddr to /proc/fs/nfsfs/servers
  nfs: Pass srcaddr into mount request.
  nfs: Propagate src-addr in client code.
  nfs: Bind to srcaddr in rpcb_create.
  lockd:  Support binding nlm client to specific address.
  nfs: Support srcaddr= to bind to specific IP address.

 fs/lockd/clntlock.c         |    3 +-
 fs/lockd/host.c             |   17 +++++++++-
 fs/nfs/callback.h           |    3 ++
 fs/nfs/callback_proc.c      |    3 +-
 fs/nfs/callback_xdr.c       |    3 ++
 fs/nfs/client.c             |   73 ++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h           |   10 +++++-
 fs/nfs/mount_clnt.c         |    1 +
 fs/nfs/super.c              |   33 +++++++++++++++++++-
 include/linux/lockd/bind.h  |    1 +
 include/linux/lockd/lockd.h |    1 +
 include/linux/nfs_fs_sb.h   |    4 ++
 include/linux/sunrpc/clnt.h |    2 +
 include/linux/sunrpc/svc.h  |    5 +++
 net/sunrpc/rpcb_clnt.c      |   28 +++++++++++++++-
 net/sunrpc/sunrpc.h         |   45 ++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c       |   47 +--------------------------
 17 files changed, 223 insertions(+), 56 deletions(-)

-- 
1.7.3.4

