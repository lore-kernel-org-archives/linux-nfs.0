Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:49482 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753Ab3EMQZc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 12:25:32 -0400
Received: by mail-ie0-f170.google.com with SMTP id aq17so12812955iec.15
        for <linux-nfs@vger.kernel.org>; Mon, 13 May 2013 09:25:32 -0700 (PDT)
Received: from seurat.1015granger.net (adsl-99-26-161-222.dsl.sfldmi.sbcglobal.net. [99.26.161.222])
        by mx.google.com with ESMTPSA id qn10sm18004595igc.6.2013.05.13.09.25.28
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 May 2013 09:25:29 -0700 (PDT)
Subject: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 13 May 2013 12:25:28 -0400
Message-ID: <20130513162528.1942.64673.stgit@seurat.1015granger.net>
In-Reply-To: <20130513161515.1942.845.stgit@seurat.1015granger.net>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state
whenever possible" is reverted...

NFSv4 server trunking detection was added with commit 05f4c350 "NFS:
Discover NFSv4 server trunking when mounting" in v3.7.  One of the
issues that the reverted commit 4edaa308 tried to address was that
when server trunking detection was added, we broke the ability to
mount krb5 exports when the client has no keytab.  We still need to
address that regression.

Let's try a narrow approach to re-enabling sec=krb5 mounts without a
local system keytab, and worry about the other issues when we can
plan concomitant user space and kernel changes.

When a GSS security flavor is used on a mount, allow the security
flavor for state management to fall back to AUTH_SYS if there is
a problem setting up a GSS context for it.

The existing situation is that the first NFSv4 mount of a server
determines the state management security flavor.  So, if a sec=sys
mount occurs first, all subsequent mounts will continue to use
AUTH_SYS for state management, even if they specified sec=krb5 or
higher.  The risk is allowing a malicious or broken client to purge
this client's open and lock state on the server; data is not
exposed.

Falling back if any error occurs while establishing a GSS context
for state management has its own risks.  A network intermediary can
prevent the establishment of a GSS context for state management,
forcing the client to use AUTH_SYS for this task.

However, given that the order of NFS mounts is non-deterministic
anyway, we already fail to provide robust security guarantees for
state management.

This will be remedied eventually, but changes co-ordinated with user
space are required for that.  When a gssd upcall fails, it currently
does not distinguish between "I don't have a keytab" and "some other
problem occurred".  To close this security hole, the kernel must
fall back only when there is no local keytab.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org [>=3.7]
---
 fs/nfs/nfs4state.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b5137c9..a2482c6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1911,11 +1911,23 @@ again:
 	switch (status) {
 	case 0:
 		break;
-
+	case -ENOKEY:
 	case -EACCES:
 		if (clp->cl_machine_cred == NULL)
 			break;
 		/* Handle case where the user hasn't set up machine creds */
+		if (clnt->cl_auth->au_flavor > RPC_AUTH_MAXFLAVOR) {
+			clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
+			if (IS_ERR(clnt)) {
+				status = PTR_ERR(clnt);
+				break;
+			}
+			clnt = xchg(&clp->cl_rpcclient, clnt);
+			rpc_shutdown_client(clnt);
+			clnt = clp->cl_rpcclient;
+			dprintk("NFS: retrying trunking detection with AUTH_SYS\n");
+			goto again;
+		}
 		nfs4_clear_machine_cred(clp);
 	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:

