From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Disable AF_INET6 callback service if SUNRPC_REGISTER_V4
	is disabled
Date: Fri, 01 May 2009 10:58:49 -0400
Message-ID: <20090501145754.17520.70458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:49883 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760139AbZEAO7p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2009 10:59:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This works around a problem (fixed in 2.6.30) where unloading the
ipv6.ko module causes mount.nfs4 to fail with "Cannot allocate memory."

SUNRPC_REGISTER_V4 is required for AF_INET6 support in NFS and lockd.
If V4 rpcbind registration support isn't available in the kernel, lockd
uses AF_INET only.  NFSv4 callback does not register with rpcbind, so it
doesn't care what flavor of rpcbind registration is available in the
kernel.

For 2.6.29 we decided to use SUNRPC_REGISTER_V4 to disable IPv6 support
in NFS and lockd to work around the requirement that ipv6.ko be loaded.
But I forgot that the NFSv4 callback service would still try to start an
AF_INET6 listener even if SUNRPC_REGISTER_V4 is disabled.

Tested-by: Andrew Savchenko <bircoph@gmail.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi Trond-

Would you consider this patch for 2.6.29-stable?

 fs/nfs/callback.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 3e634f2..b59a614 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -45,7 +45,8 @@ static const int nfs_set_port_max = 65535;
  * If the kernel has IPv6 support available, always listen for
  * both AF_INET and AF_INET6 requests.
  */
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
+	defined(CONFIG_SUNRPC_REGISTER_V4)
 static const sa_family_t	nfs_callback_family = AF_INET6;
 #else
 static const sa_family_t	nfs_callback_family = AF_INET;

