From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 71/85] nfs41: Add a reference to svc_serv during callback service bring up
Date: Mon, 10 Nov 2008 22:30:54 +0200
Message-ID: <1226349054-9599-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60055 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbYKJUbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:31:00 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

There is only one NFSv4.1 callback service.  The first caller of
nfs4_callback_up() creates the service, subsequent callers increment a
reference count on the service.  The service is destroyed when the last
caller invokes nfs_callback_down().

The transport needs to hold a reference to the callback service in order
to invoke it during callback processing.  Currently this reference is only
obtained when the service is first created.  This is incorrect, since
subsequent registrations for other transports will leave the xprt->serv
pointer uninitialized, leading to an oops when a callback arrives on
the "unreferenced" transport.

This patch fixes the problem by ensuring that a reference to the service
is saved in xprt->serv, either because the service is created by this
invocation to nfs4_callback_up() or by a prior invocation.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index be8ac50..036d66a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -223,8 +223,13 @@ int nfs_callback_up(u32 minorversion, void *args)
 #endif /* CONFIG_NFS_V4_1 */
 
 	mutex_lock(&nfs_callback_mutex);
-	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
+	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL) {
+#if defined(CONFIG_NFS_V4_1)
+		if (minorversion)
+			xprt->bc_serv = nfs_callback_info.serv;
+#endif /* CONFIG_NFS_V4_1 */
 		goto out;
+	}
 	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
 				nfs_callback_family, NULL);
 	if (!serv) {
-- 
1.6.0.2

