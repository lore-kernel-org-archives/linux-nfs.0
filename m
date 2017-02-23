Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59240 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751719AbdBWRDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 12:03:45 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] sunrpc: turn bitfield flags in svc_version into bools
Date: Thu, 23 Feb 2017 12:03:35 -0500
Message-Id: <20170223170337.10686-3-jlayton@redhat.com>
In-Reply-To: <20170223170337.10686-1-jlayton@redhat.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's just simpler to read this way, IMO. Also, no need to explicitly
set vs_hidden to false in the nfsacl ones.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback_xdr.c      | 4 ++--
 fs/nfsd/nfs2acl.c          | 1 -
 fs/nfsd/nfs3acl.c          | 1 -
 fs/nfsd/nfs4proc.c         | 2 +-
 include/linux/sunrpc/svc.h | 9 +++++----
 net/sunrpc/svc.c           | 2 +-
 6 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index eb094c6011d8..e9836f611d9c 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -1083,7 +1083,7 @@ struct svc_version nfs4_callback_version1 = {
 	.vs_proc = nfs4_callback_procedures1,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
-	.vs_hidden = 1,
+	.vs_hidden = true,
 };
 
 struct svc_version nfs4_callback_version4 = {
@@ -1092,5 +1092,5 @@ struct svc_version nfs4_callback_version4 = {
 	.vs_proc = nfs4_callback_procedures1,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
-	.vs_hidden = 1,
+	.vs_hidden = true,
 };
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index d08cd88155c7..838f90f3f890 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -376,5 +376,4 @@ struct svc_version	nfsd_acl_version2 = {
 		.vs_proc	= nfsd_acl_procedures2,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
-		.vs_hidden	= 0,
 };
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 0c890347cde3..dcb5f79076c0 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -266,6 +266,5 @@ struct svc_version	nfsd_acl_version3 = {
 		.vs_proc	= nfsd_acl_procedures3,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
-		.vs_hidden	= 0,
 };
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 74a6e573e061..2b73b37c2b36 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2481,7 +2481,7 @@ struct svc_version	nfsd_version4 = {
 		.vs_proc	= nfsd_procedures4,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
-		.vs_rpcb_optnl	= 1,
+		.vs_rpcb_optnl	= true,
 };
 
 /*
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 7321ae933867..96467c95f02e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -400,10 +400,11 @@ struct svc_version {
 	struct svc_procedure *	vs_proc;	/* per-procedure info */
 	u32			vs_xdrsize;	/* xdrsize needed for this version */
 
-	unsigned int		vs_hidden : 1,	/* Don't register with portmapper.
-						 * Only used for nfsacl so far. */
-				vs_rpcb_optnl:1;/* Don't care the result of register.
-						 * Only used for nfsv4. */
+	/* Don't register with rpcbind */
+	bool			vs_hidden;
+
+	/* Don't care if the rpcbind registration fails */
+	bool			vs_rpcb_optnl;
 
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 75f290bddca1..85bcdea67a3f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -385,7 +385,7 @@ static int svc_uses_rpcbind(struct svc_serv *serv)
 		for (i = 0; i < progp->pg_nvers; i++) {
 			if (progp->pg_vers[i] == NULL)
 				continue;
-			if (progp->pg_vers[i]->vs_hidden == 0)
+			if (!progp->pg_vers[i]->vs_hidden)
 				return 1;
 		}
 	}
-- 
2.9.3

