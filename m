From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] rpcbind v4 support in net/sunrpc/svc*
Date: Mon, 30 Jun 2008 18:45:21 -0400
Message-ID: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:13620 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbYF3Wpx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:45:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond -

These implement basic support in net/sunrpc/svc* for registering IPv6-
enabled kernel RPC services with the local user-space rpcbind.  These
all depend on the new rpcb_v4_register() API I just posted.

The last patch enables IPv6 support for the NFSv4 callback service, even
though it doesn't register with rpcbind.

---

Chuck Lever (8):
      NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets
      SUNRPC: Set V6ONLY socket option for RPC listener sockets
      SUNRPC: Add kernel build option to disable server-side use of rpcbind v3/v4
      SUNRPC: Use new rpcb_v4_register() interface in svc_register()
      SUNRPC: Clean up svc_register
      SUNRPC: Split portmap unregister API into separate function
      SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
      SUNRPC: Add address family field to svc_serv data structure


 fs/Kconfig                 |   22 +++++
 fs/lockd/svc.c             |    2 
 fs/nfs/callback.c          |   12 +-
 fs/nfs/callback.h          |    4 -
 fs/nfs/client.c            |    2 
 fs/nfsd/nfssvc.c           |    1 
 include/linux/sunrpc/svc.h |   11 +-
 net/sunrpc/svc.c           |  212 ++++++++++++++++++++++++++++++++++++--------
 net/sunrpc/svc_xprt.c      |   39 +++++++-
 net/sunrpc/svcsock.c       |   12 ++
 10 files changed, 260 insertions(+), 57 deletions(-)

-- 
Chuck Lever
chu ckl eve rat ora cle dot com
