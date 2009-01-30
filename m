From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] Address kernel bugzilla 12256
Date: Fri, 30 Jan 2009 15:10:32 -0500
Message-ID: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:21761 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbZA3UK7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 15:10:59 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Updated patch series to remove the SUNRPC_REGISTER_V4 kernel build
option.  These address kernel bugzilla 12256 ("RPC: failed to contact
local rpcbind server (errno 5)." if CONFIG_SUNRPC_REGISTER_V4 is set
to Y").  Please include them in your for-2.6.30 branch, replacing
any previous version of this patch series.

There may be some problems applying this patch set to linux-next, as
that may have recent patches that split up fs/Kconfig.

Steve Dickson also reports this related problem:

------ cut here ------

On a 2.6.29 kernel that has IPv6 turned off by

  1) adding 'blacklist ipv6' to /etc/modprobe.d/blacklist
  2) Adding NETWORKING_IPV6=no to /etc/sysconfig/network
  (note: not clear how much of this is effective since it's unknown
   if Network Manager even looks at this stuff)

When an ordinary v3 mount is tried:

  mount -v server:/music /mnt/music

It fails in the following way:

mount.nfs: timeout set for Fri Jan 23 07:22:16 2009
mount.nfs: text-based options: 'addr=10.16.43.237'
mount.nfs: mount(2): Address family not supported by protocol
mount.nfs: Address family not supported by protocol

With the following being logged to /var/log/messages:

Jan 23 07:20:16 localhost kernel: RPC: failed to contact local rpcbind
server (errno 5).

------ cut here ------

When CONFIG_SUNRPC_REGISTER_V4 is removed, this exposes a second
problem, addressed by "lockd: Use AF_INET6 listener only when IPv6
support is built in."  It turns out that some Linux networking
infrastructure simply doesn't support IPv6, so it is a popular
workaround to blacklist the ipv6 module in a distribution-built
kernel.

Unfortunately, if the module is blacklisted but was built during
the kernel build, lockd still attempts to create an AF_INET6
listener, even for IPv4 mounts, and fails.

For now, we'll work around the problem by changing lockd to 
create AF_INET6 listeners only if IPv6 support is built into the
kernel, and pursue a long-term fix in the mean time.

---

Chuck Lever (7):
      SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
      SUNRPC: rpcb_register() should handle errors silently
      SUNRPC: Simplify kernel RPC service registration
      SUNRPC: Simplify svc_unregister()
      SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s helpers
      SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel RPC services
      lockd: Use AF_INET6 listener only when IPv6 support is built in

 fs/lockd/svc.c         |   11 +++--
 net/sunrpc/Kconfig     |   22 ----------
 net/sunrpc/rpcb_clnt.c |   25 +++---------
 net/sunrpc/svc.c       |  102 +++++++++++++++++++++---------------------------
 4 files changed, 58 insertions(+), 102 deletions(-)

-- 
Chuck Lever
