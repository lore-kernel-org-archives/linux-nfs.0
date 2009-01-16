From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Address kernel bugzilla 12256
Date: Fri, 16 Jan 2009 10:38:33 -0500
Message-ID: <20090116153327.13042.80083.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:57495 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbZAPPjZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jan 2009 10:39:25 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond-

I've tossed out the previous strategy for managing RPC registration
upcalls.  The kernel now adjusts automatically to whatever the local
portmap daemon supports.

If IPv6 is enabled in the kernel, RPC services will get an AF_INET6
listener, but if the system has a portmapper capable only of rpcbind
v2, only IPv4 services are registered.

We can get rid of CONFIG_SUNRPC_REGISTER_V4 entirely.

I've tested this approach on FC6 (legacy portmap) and F9 (new rpcbind)
as both client and server.

Thoughts?

---

Chuck Lever (6):
      SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
      SUNRPC: rpcb_register() should handle errors silently
      SUNRPC: Simplify kernel RPC service registration
      SUNRPC: Simplify svc_unregister()
      SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s helpers
      SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel RPC services


 fs/Kconfig             |   22 ----------
 fs/lockd/svc.c         |    7 +--
 net/sunrpc/rpcb_clnt.c |   25 +++---------
 net/sunrpc/svc.c       |  102 +++++++++++++++++++++---------------------------
 4 files changed, 55 insertions(+), 101 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
