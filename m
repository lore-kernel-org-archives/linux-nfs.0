From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Support rpcbind v4 in kernel's RPC server
Date: Wed, 13 Aug 2008 18:39:29 -0400
Message-ID: <20080813223653.13068.9467.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30087 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbYHMWjt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:39:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond-

First set of patches for 2.6.28.  I hope I've addressed all review comments
on these.

And btw, I posted the V6ONLY patch on netdev; received no objections.

---

Chuck Lever (8):
      SUNRPC: Add kernel build option to disable server-side use of rpcbind v3/v4
      SUNRPC: Use new rpcb_v4_register() interface in svc_register()
      SUNRPC: Refactor svc_register()
      SUNRPC: Split portmap unregister API into separate function
      SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
      SUNRPC: Set V6ONLY socket option for RPC listener sockets
      SUNRPC: Add address family field to svc_serv data structure
      NFS: nfs_parsed_mount_options can use unsigned int


 fs/Kconfig                 |   22 +++++
 fs/lockd/svc.c             |    2 
 fs/nfs/callback.c          |    3 -
 fs/nfs/internal.h          |    8 +-
 fs/nfsd/nfssvc.c           |    3 -
 include/linux/sunrpc/svc.h |   15 ++-
 net/sunrpc/svc.c           |  197 ++++++++++++++++++++++++++++++++++++++------
 net/sunrpc/svc_xprt.c      |   37 +++++++-
 net/sunrpc/svcsock.c       |   13 +++
 9 files changed, 252 insertions(+), 48 deletions(-)

-- 
Chuck Lever
