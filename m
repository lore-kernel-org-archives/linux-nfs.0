Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53550 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757793Ab1FJSJ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 14:09:58 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 0/7] nfs-utils:  Support binding to source address.
Date: Fri, 10 Jun 2011 11:09:32 -0700
Message-Id: <1307729379-7702-1-git-send-email-greearb@candelatech.com>
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


v3:  Break into smaller patches for easier review.
     Remove srcaddr support from non-stropts API.

Ben Greear (7):
  nfs-utils:  Add structure for passing local binding info.
  nfs-utils:  Add patch to parse srcaddr= option.
  nfs-utils:  Implement srcaddr binding in rpc_socket
  nfs-utils:  Implement srcaddr binding in network.c
  nfs-utils:  Support srcaddr=n option for string mount.
  nfs-utils:  Implement srcaddr=n binding for unmount.
  nfs-utils:  Update man page for srcaddr= option.

 support/include/nfsrpc.h   |   23 +++++--
 support/include/sockaddr.h |    6 ++
 support/nfs/getport.c      |   37 +++++++----
 support/nfs/rpc_socket.c   |   96 ++++++++++++++++++++--------
 utils/gssd/gssd.h          |    2 +
 utils/gssd/gssd_proc.c     |   33 ++++++----
 utils/mount/network.c      |  149 +++++++++++++++++++++++++++++++++----------
 utils/mount/network.h      |   20 ++++--
 utils/mount/nfs.man        |    7 ++
 utils/mount/nfs4mount.c    |    3 +-
 utils/mount/nfsmount.c     |    6 +-
 utils/mount/nfsumount.c    |   26 +++++++-
 utils/mount/stropts.c      |   35 +++++++++-
 utils/mount/utils.c        |    6 +-
 utils/mount/utils.h        |    4 +-
 15 files changed, 335 insertions(+), 118 deletions(-)

-- 
1.7.3.4

