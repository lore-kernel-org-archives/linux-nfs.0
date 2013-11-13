Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f170.google.com ([209.85.161.170]:33287 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab3KMVxG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 16:53:06 -0500
Received: by mail-gg0-f170.google.com with SMTP id 4so452822ggm.15
        for <linux-nfs@vger.kernel.org>; Wed, 13 Nov 2013 13:53:05 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, neilb@suse.de, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/3] nfs: check if gssd is running before attempting to use krb5i auth in SETCLIENTID call
Date: Wed, 13 Nov 2013 16:52:55 -0500
Message-Id: <1384379575-8997-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384379575-8997-1-git-send-email-jlayton@redhat.com>
References: <1384379575-8997-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the client will attempt to use krb5i in the SETCLIENTID call
even if rpc.gssd is running. If that fails, it'll then fall back to
RPC_AUTH_UNIX. This introduced a delay when mounting if rpc.gssd isn't
running, and causes warning messages to pop up in the ring buffer.

Check to see if rpc.gssd is running before even attempting to use krb5i
auth, and just silently skip trying to do so if it isn't.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4client.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b4a160a..37643fe 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -10,6 +10,7 @@
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include "internal.h"
 #include "callback.h"
 #include "delegation.h"
@@ -370,7 +371,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
+
+	error = -EINVAL;
+	if (gssd_running(clp->cl_net))
+		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
 	if (error == -EINVAL)
 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
-- 
1.8.3.1

