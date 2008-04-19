From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/33] NFSv4: Don't use cred->cr_ops->cr_name in
	nfs4_proc_setclientid()
Date: Sat, 19 Apr 2008 16:40:52 -0400
Message-ID: <20080419204052.14124.60689.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43464 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756770AbYDSUuc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:32 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoVIc002643
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:31 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the recent change to generic creds, we can no longer use
cred->cr_ops->cr_name to distinguish between RPCSEC_GSS principals and
AUTH_SYS/AUTH_NULL identities. Replace it with the rpc_authops->au_name
instead...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c              |    2 +-
 include/linux/sunrpc/auth.h    |    2 --
 net/sunrpc/auth_generic.c      |    2 --
 net/sunrpc/auth_gss/auth_gss.c |    2 --
 net/sunrpc/auth_null.c         |    2 --
 net/sunrpc/auth_unix.c         |    2 --
 6 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a106932..dbc0927 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2885,7 +2885,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short po
 							RPC_DISPLAY_ADDR),
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_PROTO),
-				cred->cr_ops->cr_name,
+				clp->cl_rpcclient->cl_auth->au_ops->au_name,
 				clp->cl_id_uniquifier);
 		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
 				sizeof(setclientid.sc_netid),
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index e93cd8a..a19c3af 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -96,9 +96,7 @@ struct rpc_auth {
 struct rpc_authops {
 	struct module		*owner;
 	rpc_authflavor_t	au_flavor;	/* flavor (RPC_AUTH_*) */
-#ifdef RPC_DEBUG
 	char *			au_name;
-#endif
 	struct rpc_auth *	(*create)(struct rpc_clnt *, rpc_authflavor_t);
 	void			(*destroy)(struct rpc_auth *);
 
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 6a3f77c..b6f124c 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -136,9 +136,7 @@ static struct rpc_cred_cache generic_cred_cache = {
 
 static const struct rpc_authops generic_auth_ops = {
 	.owner = THIS_MODULE,
-#ifdef RPC_DEBUG
 	.au_name = "Generic",
-#endif
 	.lookup_cred = generic_lookup_cred,
 	.crcreate = generic_create_cred,
 };
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 55948cd..7567eb9 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1287,9 +1287,7 @@ out:
 static const struct rpc_authops authgss_ops = {
 	.owner		= THIS_MODULE,
 	.au_flavor	= RPC_AUTH_GSS,
-#ifdef RPC_DEBUG
 	.au_name	= "RPCSEC_GSS",
-#endif
 	.create		= gss_create,
 	.destroy	= gss_destroy,
 	.lookup_cred	= gss_lookup_cred,
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 3c26c18..c70dd7f 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -104,9 +104,7 @@ nul_validate(struct rpc_task *task, __be32 *p)
 const struct rpc_authops authnull_ops = {
 	.owner		= THIS_MODULE,
 	.au_flavor	= RPC_AUTH_NULL,
-#ifdef RPC_DEBUG
 	.au_name	= "NULL",
-#endif
 	.create		= nul_create,
 	.destroy	= nul_destroy,
 	.lookup_cred	= nul_lookup_cred,
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 04e936a..44920b9 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -210,9 +210,7 @@ void __init rpc_init_authunix(void)
 const struct rpc_authops authunix_ops = {
 	.owner		= THIS_MODULE,
 	.au_flavor	= RPC_AUTH_UNIX,
-#ifdef RPC_DEBUG
 	.au_name	= "UNIX",
-#endif
 	.create		= unx_create,
 	.destroy	= unx_destroy,
 	.lookup_cred	= unx_lookup_cred,

