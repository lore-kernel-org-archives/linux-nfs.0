From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 12] svcrpc: add a per-flavor set_client method
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006VK-2K@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLir-0006vB-64
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLiq-0004Fk-Bo
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:29 -0800
To: Andrew Morton <akpm@osdl.org>
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
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./include/linux/sunrpc/svcauth.h    |    2 ++
 ./net/sunrpc/auth_gss/svcauth_gss.c |   14 ++++++++++++++
 ./net/sunrpc/sunrpc_syms.c          |    1 +
 ./net/sunrpc/svcauth.c              |    5 +++++
 ./net/sunrpc/svcauth_unix.c         |    2 ++
 5 files changed, 24 insertions(+)

diff ./include/linux/sunrpc/svcauth.h~current~ ./include/linux/sunrpc/svcauth.h
--- ./include/linux/sunrpc/svcauth.h~current~	2005-02-07 15:04:11.000000000 +1100
+++ ./include/linux/sunrpc/svcauth.h	2005-02-07 15:04:11.000000000 +1100
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
 

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2005-02-07 15:04:11.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2005-02-07 15:04:11.000000000 +1100
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
@@ -1052,6 +1065,7 @@ static struct auth_ops svcauthops_gss = 
 	.accept		= svcauth_gss_accept,
 	.release	= svcauth_gss_release,
 	.domain_release = svcauth_gss_domain_release,
+	.set_client	= svcauth_gss_set_client,
 };
 
 int

diff ./net/sunrpc/sunrpc_syms.c~current~ ./net/sunrpc/sunrpc_syms.c
--- ./net/sunrpc/sunrpc_syms.c~current~	2005-02-07 15:04:11.000000000 +1100
+++ ./net/sunrpc/sunrpc_syms.c	2005-02-07 15:04:11.000000000 +1100
@@ -91,6 +91,7 @@ EXPORT_SYMBOL(svc_reserve);
 EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
 EXPORT_SYMBOL(svc_authenticate);
+EXPORT_SYMBOL(svc_set_client);
 
 /* RPC statistics */
 #ifdef CONFIG_PROC_FS

diff ./net/sunrpc/svcauth.c~current~ ./net/sunrpc/svcauth.c
--- ./net/sunrpc/svcauth.c~current~	2005-02-07 15:04:11.000000000 +1100
+++ ./net/sunrpc/svcauth.c	2005-02-07 15:04:11.000000000 +1100
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

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2005-02-07 15:04:11.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2005-02-07 15:04:11.000000000 +1100
@@ -429,6 +429,7 @@ struct auth_ops svcauth_null = {
 	.flavour	= RPC_AUTH_NULL,
 	.accept 	= svcauth_null_accept,
 	.release	= svcauth_null_release,
+	.set_client	= svcauth_unix_set_client,
 };
 
 
@@ -510,5 +511,6 @@ struct auth_ops svcauth_unix = {
 	.accept 	= svcauth_unix_accept,
 	.release	= svcauth_unix_release,
 	.domain_release	= svcauth_unix_domain_release,
+	.set_client	= svcauth_unix_set_client,
 };
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
