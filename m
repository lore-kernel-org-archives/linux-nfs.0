Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:37600
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757771AbZKESWu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:22:50 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] For 2.6.33
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 05 Nov 2009 13:22:26 -0500
Message-ID: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

Here is what I'd like to submit for 2.6.33.  These have had some
testing here, but not as much as I would like.  Maybe linux-next would
be appropriate.

---

Chuck Lever (11):
      SUNRPC: soft connect semantics for UDP
      SUNRPC: Use soft connect semantics when performing RPC ping
      SUNRPC: Use soft connects for autobinding over TCP
      SUNRPC: Use TCP for local rpcbind upcalls
      SUNRPC: Use a cached RPC client and transport for rpcbind upcalls
      SUNRPC: Simplify synopsis of rpcb_local_clnt()
      SUNRPC: Allow RPCs to fail quickly if the server is unreachable
      SUNRPC: Check explicitly for tk_status == 0 in call_transmit_status()
      NFS: Revert default r/wsize behavior
      NFS: Display compressed (shorthand) IPv6 in /proc/mounts
      SUNRPC: Display compressed (shorthand) IPv6 presentation addresses


 fs/nfs/super.c               |    4 --
 include/linux/sunrpc/sched.h |    2 +
 net/sunrpc/addr.c            |   10 -----
 net/sunrpc/clnt.c            |   54 ++++++++++++++++++++++---
 net/sunrpc/rpcb_clnt.c       |   89 +++++++++++++++++++++++++++++++-----------
 net/sunrpc/sunrpc_syms.c     |    3 +
 net/sunrpc/xprtsock.c        |    2 -
 7 files changed, 120 insertions(+), 44 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
