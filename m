From: greearb@candelatech.com
Subject: [PATCH v2 0/6]  nfs-utils:  Support binding to source address.
Date: Fri, 10 Jun 2011 12:41:32 -0700
Message-ID: <1307734898-12860-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42993 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757733Ab1FJTmC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 15:42:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This lets one specify the source IP address for
sockets, allowing users to leverage routing rules
on multi-homed systems.

Kernel patches to RPC and NFS are needed to complete
full functionality.

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
 support/nfs/getport.c      |   37 +++++++++-----
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
 14 files changed, 295 insertions(+), 103 deletions(-)

-- 
1.7.3.4

