From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1 of 6] svcrpc: add a per-flavor set_client method
Date: Thu, 09 Dec 2004 17:28:37 -0500
Message-ID: <1102628809.16c39937.1@fieldses.org>
References: <1102628809.16c39937.0@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcWlq-0005GH-R4
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:22 -0800
Received: from dh173.citi.umich.edu
	([141.211.133.173] helo=puzzle.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CcWlh-0006Pz-6u
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:22 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1102628809.16c39937.0@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Add a set_client method to the server rpc auth_ops struct, used to set the
client (for the purposes of nfsd export authorization) using flavor-specific
information.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.10-rc3-bfields/include/linux/sunrpc/svcauth.h    |    2 +
 linux-2.6.10-rc3-bfields/net/sunrpc/auth_gss/svcauth_gss.c |   14 +++++++++++++
 linux-2.6.10-rc3-bfields/net/sunrpc/sunrpc_syms.c          |    1 
 linux-2.6.10-rc3-bfields/net/sunrpc/svcauth.c              |    5 ++++
 linux-2.6.10-rc3-bfields/net/sunrpc/svcauth_unix.c         |    2 +
 5 files changed, 24 insertions(+)

diff -puN include/linux/sunrpc/svcauth.h~svcrpc_per_flavor_set_client_method include/linux/sunrpc/svcauth.h
--- linux-2.6.10-rc3/include/linux/sunrpc/svcauth.h~svcrpc_per_flavor_set_client_method	2004-12-09 16:37:51.000000000 -0500
+++ linux-2.6.10-rc3-bfields/include/linux/sunrpc/svcauth.h	2004-12-09 16:37:51.000000000 -0500
@@ -92,6 +92,7 @@ struct auth_ops {
 	int	(*accept)(struct svc_rqst *rq, u32 *authp);
 	int	(*release)(struct svc_rqst *rq);
 	void	(*domain_release)(struct auth_domain *);
+	int	(*set_client)(struct svc_rqst *rq);
 };
 
 #define	SVC_GARBAGE	1
@@ -107,6 +108,7 @@ struct auth_ops {
 
 extern int	svc_authenticate(struct svc_rqst *rqstp, u32 *authp);
 extern int	svc_authorise(struct svc_rqst *rqstp);
+extern int	svc_set_client(struct svc_rqst *rqstp);
 extern int	svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops);
 extern void	svc_auth_unregister(rpc_authflavor_t flavor);
 
diff -puN net/sunrpc/auth_gss/svcauth_gss.c~svcrpc_per_flavor_set_client_method net/sunrpc/auth_gss/svcauth_gss.c
--- linux-2.6.10-rc3/net/sunrpc/auth_gss/svcauth_gss.c~svcrpc_per_flavor_set_client_method	2004-12-09 16:37:51.000000000 -0500
+++ linux-2.6.10-rc3-bfields/net/sunrpc/auth_gss/svcauth_gss.c	2004-12-09 16:37:51.000000000 -0500
@@ -730,6 +730,19 @@ struct gss_svc_data {
 	struct rsc			*rsci;
 };
 
+static int
+svcauth_gss_set_client(struct svc_rqst *rqstp)
+{
+	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
+	struct rsc *rsci = svcdata->rsci;
+	struct rpc_gss_wire_cred *gc = &svcdata->clcred;
+
+	rqstp->rq_client = find_gss_auth_domain(rsci->mechctx, gc->gc_svc);
+	if (rqstp->rq_client == NULL)
+		return SVC_DENIED;
+	return SVC_OK;
+}
+
 /*
  * Accept an rpcsec packet.
  * If context establishment, punt to user space
@@ -1052,6 +1065,7 @@ struct auth_ops svcauthops_gss = {
 	.accept		= svcauth_gss_accept,
 	.release	= svcauth_gss_release,
 	.domain_release = svcauth_gss_domain_release,
+	.set_client	= svcauth_gss_set_client,
 };
 
 int
diff -puN net/sunrpc/sunrpc_syms.c~svcrpc_per_flavor_set_client_method net/sunrpc/sunrpc_syms.c
--- linux-2.6.10-rc3/net/sunrpc/sunrpc_syms.c~svcrpc_per_flavor_set_client_method	2004-12-09 16:37:51.000000000 -0500
+++ linux-2.6.10-rc3-bfields/net/sunrpc/sunrpc_syms.c	2004-12-09 16:37:51.000000000 -0500
@@ -90,6 +90,7 @@ EXPORT_SYMBOL(svc_reserve);
 EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
 EXPORT_SYMBOL(svc_authenticate);
+EXPORT_SYMBOL(svc_set_client);
 
 /* RPC statistics */
 #ifdef CONFIG_PROC_FS
diff -puN net/sunrpc/svcauth.c~svcrpc_per_flavor_set_client_method net/sunrpc/svcauth.c
--- linux-2.6.10-rc3/net/sunrpc/svcauth.c~svcrpc_per_flavor_set_client_method	2004-12-09 16:37:51.000000000 -0500
+++ linux-2.6.10-rc3-bfields/net/sunrpc/svcauth.c	2004-12-09 16:37:51.000000000 -0500
@@ -59,6 +59,11 @@ svc_authenticate(struct svc_rqst *rqstp,
 	return aops->accept(rqstp, authp);
 }
 
+int svc_set_client(struct svc_rqst *rqstp)
+{
+	return rqstp->rq_authop->set_client(rqstp);
+}
+
 /* A request, which was authenticated, has now executed.
  * Time to finalise the the credentials and verifier
  * and release and resources
diff -puN net/sunrpc/svcauth_unix.c~svcrpc_per_flavor_set_client_method net/sunrpc/svcauth_unix.c
--- linux-2.6.10-rc3/net/sunrpc/svcauth_unix.c~svcrpc_per_flavor_set_client_method	2004-12-09 16:37:51.000000000 -0500
+++ linux-2.6.10-rc3-bfields/net/sunrpc/svcauth_unix.c	2004-12-09 16:37:51.000000000 -0500
@@ -430,6 +430,7 @@ struct auth_ops svcauth_null = {
 	.flavour	= RPC_AUTH_NULL,
 	.accept 	= svcauth_null_accept,
 	.release	= svcauth_null_release,
+	.set_client	= svcauth_unix_set_client,
 };
 
 
@@ -511,5 +512,6 @@ struct auth_ops svcauth_unix = {
 	.accept 	= svcauth_unix_accept,
 	.release	= svcauth_unix_release,
 	.domain_release	= svcauth_unix_domain_release,
+	.set_client	= svcauth_unix_set_client,
 };
 
_


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
