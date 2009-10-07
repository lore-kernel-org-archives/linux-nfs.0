From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] EXPERIMENTAL: soft connect semantics for rpcbind
Date: Wed, 07 Oct 2009 18:02:16 -0400
Message-ID: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:52159
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754731AbZJGWCy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2009 18:02:54 -0400
Received: from matisse.1015granger.net (matisse.1015granger.net [127.0.0.1])
	by matisse.1015granger.net (8.14.3/8.14.3) with ESMTP id n97M2GPc001926
	for <linux-nfs@vger.kernel.org>; Wed, 7 Oct 2009 18:02:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These need further refinement, but I'm posting now to spark some
discussion.

To address manifold reports of svc_unregister() hanging (either at
shutdown or if rpcbind simply wasn't ever started), these patches add
a new per-request soft connect semantic, and update the kernel's
rpcbind client to use a connection-oriented transport for local
queries.  This should cause the kernel's local rpcbind queries to fail
immediately if rpcbind isn't reachable.

This can work with either TCP or connected UDP.  I used TCP here
merely as an example.

The final two patches have not been tested, but provide a taste of
other uses for the soft connect semantic.  One possible use is to
address Ian's NFSv4 mount hang problems by making rpc_ping() fail if
it cannot connect to the server.

We can also make use of this new feature to do proper "hangless" NFS
v2/v3 version and transport negotiation in the kernel, although
that is beyond the scope of the current patch set.

---

Chuck Lever (7):
      SUNRPC: Use soft connect semantics when performing RPC ping
      SUNRPC: Use soft connects for autobinding over TCP
      SUNRPC: Use TCP for local rpcbind upcalls
      SUNRPC: maintain a single transport for rpcbind upcalls
      SUNRPC: Clean up call_transmit_status()
      SUNRPC: Allow RPCs to fail quickly if the server is unreachable
      SUNRPC: Don't report a connect delay of 0 seconds


 include/linux/sunrpc/sched.h |    2 +
 net/sunrpc/clnt.c            |   45 ++++++++++++++++++++--------
 net/sunrpc/rpcb_clnt.c       |   68 ++++++++++++++++++++++++++++++++----------
 net/sunrpc/sunrpc_syms.c     |    5 +++
 net/sunrpc/xprtsock.c        |    9 +++---
 5 files changed, 96 insertions(+), 33 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
