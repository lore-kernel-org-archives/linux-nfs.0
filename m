From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Address kernel bugzilla 12256
Date: Fri, 23 Jan 2009 11:45:52 -0500
Message-ID: <20090123164302.27126.56411.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:21134 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756386AbZAWQqo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2009 11:46:44 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Resend of patchset that addresses kernel bugzilla 12256 ("RPC: failed
to contact local rpcbind server (errno 5)." if
CONFIG_SUNRPC_REGISTER_V4 is set to Y").

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

Steve, you are welcome to confirm that this patchset addresses the
problem.

I recommend this (or a similar) patch set be merged with 2.6.29-rc as
a regression fix.  Please also consider submitting this for recent
stable kernels (hopefully only .28 is affected).

There may be some problems applying this patch set to linux-next, as
that may have recent patches that split up fs/Kconfig.

---

Chuck Lever (6):
      SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
      SUNRPC: rpcb_register() should handle errors silently
      SUNRPC: Simplify kernel RPC service registration
      SUNRPC: Simplify svc_unregister()
      SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s helpers
      SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel RPC
              services


 fs/Kconfig             |   22 ----------
 fs/lockd/svc.c         |    7 +--
 net/sunrpc/rpcb_clnt.c |   25 +++---------
 net/sunrpc/svc.c       |  102 +++++++++++++++++++++---------------------------
 4 files changed, 55 insertions(+), 101 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
