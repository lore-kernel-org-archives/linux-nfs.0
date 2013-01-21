Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39842 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab3AUUqS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:46:18 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 00/13] Allow NFS to bind to local IP address.
Date: Mon, 21 Jan 2013 12:45:46 -0800
Message-Id: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>


This patch series allows binding the nfs and rpc logic to a specific local
IP address.

Features/Benefits:

*  Allow multiple unique mounts to the same server using unique
   source IP addresses on client system.

   Routing rules can then be created based on the source IP address for
   advanced routing of the NFS traffic.

   This could allow someone to use two 1G interfaces to access a
   server with 10G connectivity and allow aggregate 2Gbps transfer,
   for instance.

   This is also useful for load testing NFS servers as well as the
   client-side NFS logic (note the bugs & fixed found while testing
   this code!)

*  Allow using a specific IP address on multi-homed system.  This could
   increase security in some cases and in general gives the user more
   control over how the services are configured.

This code has been tested under load on 3.7.3 and similar versions have
been tested for many years on previous kernels.

Full implementation of this feature requires patches to mount.nfs,
which were previously agreed to be accepted if the kernel patches are accepted.

Ben Greear (13):
  sunrpc: Don't attempt to bind to AF_UNSPEC address.
  nfs: Two AF_UNSPEC addresses should always match each other.
  nfs: Add srcaddr member to nfs_client.
  nfs: Use request destination addr as callback source addr.
  nfs: Pay attention to srcaddr in v4.1 callback logic.
  nfs: Use srcaddr in nfs_match_client.
  nfs: Pass srcaddr into mount request.
  nfs: Propagate src-addr in client code.
  nfs: Bind to srcaddr in rpcb_create.
  nfs: Support srcaddr= to bind to specific IP address.
  nfs: Add srcaddr to /proc/fs/nfsfs/servers
  lockd: Support binding nlm client to specific address.
  nfs:  Allow up to 5000 NFSv4 connections (instead of 1024).

 fs/lockd/clntlock.c         |    3 +-
 fs/lockd/host.c             |   17 +++++++++++++++-
 fs/nfs/callback.c           |    2 +-
 fs/nfs/callback.h           |    3 ++
 fs/nfs/callback_proc.c      |    3 +-
 fs/nfs/callback_xdr.c       |    3 ++
 fs/nfs/client.c             |   35 ++++++++++++++++++++++++++++++-
 fs/nfs/internal.h           |   14 +++++++++++-
 fs/nfs/mount_clnt.c         |    1 +
 fs/nfs/nfs4client.c         |   32 +++++++++++++++++++++++++++++-
 fs/nfs/super.c              |   33 +++++++++++++++++++++++++++++-
 include/linux/lockd/bind.h  |    1 +
 include/linux/lockd/lockd.h |    1 +
 include/linux/nfs_fs_sb.h   |    4 +++
 include/linux/sunrpc/clnt.h |    2 +
 include/linux/sunrpc/svc.h  |    1 +
 net/sunrpc/rpcb_clnt.c      |   31 ++++++++++++++++++++++++++--
 net/sunrpc/sunrpc.h         |   45 ++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c       |   46 +-----------------------------------------
 19 files changed, 220 insertions(+), 57 deletions(-)

-- 
1.7.3.4

