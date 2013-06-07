Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:46758 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab3FGVhE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 17:37:04 -0400
Received: by mail-oa0-f45.google.com with SMTP id j6so3867216oag.32
        for <linux-nfs@vger.kernel.org>; Fri, 07 Jun 2013 14:37:04 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id z5sm791647obw.4.2013.06.07.14.37.03
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Jun 2013 14:37:03 -0700 (PDT)
Subject: [PATCH 2 2/2] NFS: Use root's credential for lease management when
 keytab is missing
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 07 Jun 2013 17:37:02 -0400
Message-ID: <20130607213702.1127.99199.stgit@seurat.1015granger.net>
In-Reply-To: <20130607213518.1127.72500.stgit@seurat.1015granger.net>
References: <20130607213518.1127.72500.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 05f4c350 "NFS: Discover NFSv4 server trunking when mounting"
Fri Sep 14 17:24:32 2012 introduced Uniform Client String support,
which forces our NFS client to establish a client ID immediately
during a mount operation rather than waiting until a user wants to
open a file.

Normally machine credentials (eg. from a keytab) are used to perform
a mount operation that is protected by Kerberos.  Before 05fc350,
SETCLIENTID used a machine credential, or fell back to a regular
user's credential if no keytab is available.

On clients that don't have a keytab, performing SETCLIENTID early
means there's no user credential to fall back on, since no regular
user has kinit'd yet.  05f4c350 seems to have broken the ability
to mount with sec=krb5 on clients that don't have a keytab in
kernels 3.7 - 3.9.

To address this regression, commit 4edaa308 (NFS: Use "krb5i" to
establish NFSv4 state whenever possible), Sat Mar 16 15:56:20 2013,
was merged in 3.10.  This commit forces the NFS client to fall back
to AUTH_SYS for lease management operations if no keytab is
available.

Neil Brown noticed that, since root is required to kinit to do a
sec=krb5 mount when a client doesn't have a keytab, we can try to
use root's Kerberos credential before AUTH_SYS.

Now, when determining a principal and flavor to use for lease
management, the NFS client tries in this order:

  1.  Flavor: AUTH_GSS, krb5i
      Principal: service principal (via keytab)

  2.  Flavor: AUTH_GSS, krb5i
      Principal: user principal established for UID 0 (via kinit)

  3.  Flavor: AUTH_SYS
      Principal: UID 0 / GID 0

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4state.c |   20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1fab140..6ceece7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -154,6 +154,19 @@ struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 	return cred;
 }
 
+static void nfs4_root_machine_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred, *new;
+
+	new = rpc_lookup_machine_cred(NULL);
+	spin_lock(&clp->cl_lock);
+	cred = clp->cl_machine_cred;
+	clp->cl_machine_cred = new;
+	spin_unlock(&clp->cl_lock);
+	if (cred != NULL)
+		put_rpccred(cred);
+}
+
 static struct rpc_cred *
 nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 {
@@ -1888,9 +1901,14 @@ again:
 	case -NFS4ERR_STALE_CLIENTID:
 		dprintk("NFS: %s after status %d, retrying\n",
 			__func__, status);
+		i = 0;
 		goto again;
 	case -EACCES:
-		if (i++)
+		if (i++ == 0) {
+			nfs4_root_machine_cred(clp);
+			goto again;
+		}
+		if (i > 2)
 			break;
 	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_WRONGSEC:

