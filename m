From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Bake-a-thon fixes
Date: Thu, 25 Sep 2008 11:56:47 -0400
Message-ID: <20080925154814.8353.64762.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21792 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbYIYP6j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 11:58:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond, Bruce-

I know it is late, but please consider these three bug fixes for 2.6.28.

The first patch is another result of Olaf's recent exploration of the
Linux rpcbind port.  It belongs with the other patches for 2.6.28 that
provide proper support for IPv6 and rpcbind v4 when the kernel registers
its RPC services with the local rpcbind daemon.

The second patch is a simple clean up that reduces the verbosity of
rpcbind debugging messages.

The third is important for NFSv4 over IPv6.  Without it, the NFSv4.0
callback channel does not work properly over IPv6.  There may be more
problems there, so this does not yet guarantee that we have working
callback support over IPv6.

---

Chuck Lever (3):
      NFS: SETCLIENTID truncates client ID and netid
      SUNRPC: Clean up debug messages in rpcb_clnt.c
      SUNRPC: Fix up svc_unregister()


 include/linux/nfs_xdr.h |    8 +++---
 net/sunrpc/rpcb_clnt.c  |   14 ++++-------
 net/sunrpc/svc.c        |   58 +++++++++++++++++++++++++++++++----------------
 3 files changed, 47 insertions(+), 33 deletions(-)

-- 
Chuck Lever
