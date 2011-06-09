Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40204 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550Ab1FIXDL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:03:11 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 00/11] NFS:  Add client ability to bind to specific source-addr.
Date: Thu,  9 Jun 2011 16:02:44 -0700
Message-Id: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

In order to have more control on multi-homed machines, it is
nice to be able to bind to a specific IP address.  This can aid
with interface selection, policy based routing, multiple unique
mounts to the same server, and similar things.

This patch allows srcaddr= option for NFS.  The key 'srcaddr'
was chosen to match the similar patch for cifs.

For NFSv4, if one is specifying clientaddr, it must be the same as
srcaddr or things may not work properly.

NFSv3, NFSv4 over TCP/IPv4 and TCP/IPv6 has been successfully tested.

Usage:
  mount -t nfs4 [2002::1]:/rpool/ben /mnt/foo/ben-1 -o srcaddr=2002::2,clientaddr=2002::2
  mount -t nfs4 192.168.100.3:/foo /mnt/foo/ben-2 -o srcaddr=192.168.100.174

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

