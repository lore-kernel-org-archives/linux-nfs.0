From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 11 - gss_svc_module_ref.patch
Date: Fri, 28 May 2004 14:37:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7b-0008ES-04@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkYn-0006lT-Vd
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:29 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkYn-0006mm-AE
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:29 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
To: Andrew Morton <akpm@osdl.org>
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


The server sunrpc code should take a reference on the relevant module before
calling any authentication code.

Also, it looks to me like the table of authops needs some locking.

Finally, gss_svc_init wasn't checking the status of svc_auth_register,
and gss_svc_shutdown wasn't calling svc_auth_unregister.


From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcauth.h    |    1 +
 ./net/sunrpc/auth_gss/svcauth_gss.c |   12 ++++++++----
 ./net/sunrpc/svcauth.c              |   25 +++++++++++++++++++------
 ./net/sunrpc/svcauth_unix.c         |    3 +++
 4 files changed, 31 insertions(+), 10 deletions(-)

diff ./include/linux/sunrpc/svcauth.h~current~ ./include/linux/sunrpc/svcauth.h
--- ./include/linux/sunrpc/svcauth.h~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./include/linux/sunrpc/svcauth.h	2004-05-28 14:20:17.000000000 +1000
@@ -87,6 +87,7 @@ struct auth_domain {
  */
 struct auth_ops {
 	char *	name;
+	struct module *owner;
 	int	flavour;
 	int	(*accept)(struct svc_rqst *rq, u32 *authp);
 	int	(*release)(struct svc_rqst *rq);

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-05-28 14:20:17.000000000 +1000
@@ -1045,6 +1045,7 @@ svcauth_gss_domain_release(struct auth_d
 
 struct auth_ops svcauthops_gss = {
 	.name		= "rpcsec_gss",
+	.owner		= THIS_MODULE,
 	.flavour	= RPC_AUTH_GSS,
 	.accept		= svcauth_gss_accept,
 	.release	= svcauth_gss_release,
@@ -1054,10 +1055,12 @@ struct auth_ops svcauthops_gss = {
 int
 gss_svc_init(void)
 {
-	cache_register(&rsc_cache);
-	cache_register(&rsi_cache);
-	svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
-	return 0;
+	int rv = svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
+	if (rv == 0) {
+		cache_register(&rsc_cache);
+		cache_register(&rsi_cache);
+	}
+	return rv;
 }
 
 void
@@ -1065,4 +1068,5 @@ gss_svc_shutdown(void)
 {
 	cache_unregister(&rsc_cache);
 	cache_unregister(&rsi_cache);
+	svc_auth_unregister(RPC_AUTH_GSS);
 }

diff ./net/sunrpc/svcauth.c~current~ ./net/sunrpc/svcauth.c
--- ./net/sunrpc/svcauth.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./net/sunrpc/svcauth.c	2004-05-28 14:20:17.000000000 +1000
@@ -11,6 +11,7 @@
 
 #include <linux/types.h>
 #include <linux/sched.h>
+#include <linux/module.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcsock.h>
@@ -27,6 +28,7 @@
 extern struct auth_ops svcauth_null;
 extern struct auth_ops svcauth_unix;
 
+static spinlock_t authtab_lock = SPIN_LOCK_UNLOCKED;
 static struct auth_ops	*authtab[RPC_AUTH_MAXFLAVOR] = {
 	[0] = &svcauth_null,
 	[1] = &svcauth_unix,
@@ -43,10 +45,15 @@ svc_authenticate(struct svc_rqst *rqstp,
 	flavor = ntohl(svc_getu32(&rqstp->rq_arg.head[0]));
 
 	dprintk("svc: svc_authenticate (%d)\n", flavor);
-	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor])) {
+
+	spin_lock(&authtab_lock);
+	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor])
+			|| !try_module_get(aops->owner)) {
+		spin_unlock(&authtab_lock);
 		*authp = rpc_autherr_badcred;
 		return SVC_DENIED;
 	}
+	spin_unlock(&authtab_lock);
 
 	rqstp->rq_authop = aops;
 	return aops->accept(rqstp, authp);
@@ -66,24 +73,30 @@ int svc_authorise(struct svc_rqst *rqstp
 	if (aops) 
 		rv = aops->release(rqstp);
 
-	/* FIXME should I count and release authops */
+	module_put(aops->owner);
 	return rv;
 }
 
 int
 svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops)
 {
-	if (flavor >= RPC_AUTH_MAXFLAVOR || authtab[flavor])
-		return -EINVAL;
-	authtab[flavor] = aops;
-	return 0;
+	int rv = -EINVAL;
+	spin_lock(&authtab_lock);
+	if (flavor < RPC_AUTH_MAXFLAVOR && authtab[flavor] != NULL) {
+		authtab[flavor] = aops;
+		rv = 0;
+	}
+	spin_unlock(&authtab_lock);
+	return rv;
 }
 
 void
 svc_auth_unregister(rpc_authflavor_t flavor)
 {
+	spin_lock(&authtab_lock);
 	if (flavor < RPC_AUTH_MAXFLAVOR)
 		authtab[flavor] = NULL;
+	spin_unlock(&authtab_lock);
 }
 
 /**************************************************

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2004-05-28 14:20:17.000000000 +1000
@@ -1,5 +1,6 @@
 #include <linux/types.h>
 #include <linux/sched.h>
+#include <linux/module.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcsock.h>
@@ -411,6 +412,7 @@ svcauth_null_release(struct svc_rqst *rq
 
 struct auth_ops svcauth_null = {
 	.name		= "null",
+	.owner		= THIS_MODULE,
 	.flavour	= RPC_AUTH_NULL,
 	.accept 	= svcauth_null_accept,
 	.release	= svcauth_null_release,
@@ -515,6 +517,7 @@ svcauth_unix_release(struct svc_rqst *rq
 
 struct auth_ops svcauth_unix = {
 	.name		= "unix",
+	.owner		= THIS_MODULE,
 	.flavour	= RPC_AUTH_UNIX,
 	.accept 	= svcauth_unix_accept,
 	.release	= svcauth_unix_release,


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
