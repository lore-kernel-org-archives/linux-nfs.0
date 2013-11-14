Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:58034 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab3KNMZb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 07:25:31 -0500
Received: by mail-qa0-f53.google.com with SMTP id k4so1295892qaq.12
        for <linux-nfs@vger.kernel.org>; Thu, 14 Nov 2013 04:25:30 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, neilb@suse.de, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v4 3/3] nfs: check if gssd is running before attempting to use krb5i auth in SETCLIENTID call
Date: Thu, 14 Nov 2013 07:25:19 -0500
Message-Id: <1384431919-20921-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384431919-20921-1-git-send-email-jlayton@redhat.com>
References: <1384431919-20921-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the client will attempt to use krb5i in the SETCLIENTID call
even if rpc.gssd isn't running. When that fails, it'll then fall back to
RPC_AUTH_UNIX. This introduced a delay when mounting if rpc.gssd isn't
running, and causes warning messages to pop up in the ring buffer.

Check to see if rpc.gssd is running before even attempting to use krb5i
auth, and just silently skip trying to do so if it isn't. In the event
that the admin is actually trying to mount with krb5*, it will still
fail at a later stage of the mount attempt.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4client.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b4a160a..c1b7a80 100644
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
@@ -370,7 +371,11 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
+
+	error = -EINVAL;
+	if (gssd_running(clp->cl_net))
+		error = nfs_create_rpc_client(clp, timeparms,
+					      RPC_AUTH_GSS_KRB5I);
 	if (error == -EINVAL)
 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
-- 
1.8.3.1

