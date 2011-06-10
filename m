Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44580 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617Ab1FJVIW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 17:08:22 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v3 0/6] nfs-utils:  Support binding to source address.
Date: Fri, 10 Jun 2011 14:08:10 -0700
Message-Id: <1307740096-19933-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This lets one specify the source IP address for
sockets, allowing users to leverage routing rules
on multi-homed systems.

Kernel patches to RPC and NFS are needed to complete
full functionality.

v5:  Fix compile error with ipv6 enabled.  One minor
       change to patch 1.

v4:  Remove get_socket() modifications: stropt mount doesn't use them.
       (This removed old patch 4, and modified patch 1)
     Remove open-parsing of srcaddr= in mount logic.  Move parsing
       to nfs_validate_options()

Ben Greear (6):
  nfs-utils:  Add structure for passing local binding info.
  nfs-utils:  Add patch to parse srcaddr= option.
  nfs-utils:  Implement srcaddr binding in rpc_socket
  nfs-utils:  Support srcaddr=n option for string mount.
  nfs-utils:  Implement srcaddr=n binding for unmount.
  nfs-utils:  Update man page for srcaddr= option.

 support/include/nfsrpc.h   |   23 ++++++---
 support/include/sockaddr.h |    6 ++
 support/nfs/getport.c      |   39 ++++++++++------
 support/nfs/rpc_socket.c   |   96 +++++++++++++++++++++++++++-----------
 utils/gssd/gssd.h          |    2 +
 utils/gssd/gssd_proc.c     |   33 ++++++++------
 utils/mount/network.c      |  111 ++++++++++++++++++++++++++++++++++----------
 utils/mount/network.h      |   16 ++++--
 utils/mount/nfs.man        |    7 +++
 utils/mount/nfsmount.c     |    2 +-
 utils/mount/nfsumount.c    |   26 +++++++++-
 utils/mount/stropts.c      |   29 ++++++++++--
 utils/mount/utils.c        |    6 ++-
 utils/mount/utils.h        |    4 +-
 14 files changed, 296 insertions(+), 104 deletions(-)

-- 
1.7.3.4

