From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] Register kernel RPC services via rpcbind v4
Date: Mon, 18 Aug 2008 19:33:20 -0400
Message-ID: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21570 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbYHSMG7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 08:06:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond-

Here's the patch series that adds rpcbind v4 support to svc_register(), with
the simplification we discussed last week.  I think this looks cleaner.

Please consider these for 2.6.28.

---

Chuck Lever (7):
      SUNRPC: Support IPv6 when registering kernel RPC services
      SUNRPC: Split portmap unregister API into separate function
      SUNRPC: Simplify rpcb_register() API
      SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
      SUNRPC: Set V6ONLY socket option for RPC listener sockets
      SUNRPC: Add address family field to svc_serv data structure
      NFS: nfs_parsed_mount_options can use unsigned int


 fs/Kconfig                  |   22 +++++
 fs/lockd/svc.c              |    2 
 fs/nfs/callback.c           |    3 -
 fs/nfs/internal.h           |    8 +-
 fs/nfsd/nfssvc.c            |    3 -
 include/linux/sunrpc/clnt.h |    4 -
 include/linux/sunrpc/svc.h  |   15 ++--
 net/sunrpc/rpcb_clnt.c      |   65 +++++++---------
 net/sunrpc/svc.c            |  175 ++++++++++++++++++++++++++++++++++++-------
 net/sunrpc/svc_xprt.c       |   37 +++++++--
 net/sunrpc/svcsock.c        |   13 +++
 11 files changed, 260 insertions(+), 87 deletions(-)

-- 
Chuck Lever
