From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 20] knfsd: nfsd4: store pseudoflavor in request
Date: Tue, 10 Jul 2007 12:23:22 +1000
Message-ID: <1070710022322.12986@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Andy Adamson <andros@citi.umich.edu>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85Nu-0004m4-GD
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:23:27 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85Nx-000057-JC
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:23:30 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: andros@citi.umich.edu <andros@citi.umich.edu>

Add a new field to the svc_rqst structure to record the pseudoflavor that
the request was made with.  For now we record the pseudoflavor but don't
use it for anything.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/gss_api.h        |    1 +
 ./include/linux/sunrpc/svc.h            |    1 +
 ./net/sunrpc/auth_gss/gss_mech_switch.c |   14 ++++++++++++++
 ./net/sunrpc/auth_gss/svcauth_gss.c     |    2 ++
 ./net/sunrpc/svcauth_unix.c             |    3 +++
 5 files changed, 21 insertions(+)

diff .prev/include/linux/sunrpc/gss_api.h ./include/linux/sunrpc/gss_api.h
--- .prev/include/linux/sunrpc/gss_api.h	2007-07-10 11:28:10.000000000 +1000
+++ ./include/linux/sunrpc/gss_api.h	2007-07-10 11:27:13.000000000 +1000
@@ -58,6 +58,7 @@ u32 gss_unwrap(
 u32 gss_delete_sec_context(
 		struct gss_ctx		**ctx_id);
 
+u32 gss_svc_to_pseudoflavor(struct gss_api_mech *, u32 service);
 u32 gss_pseudoflavor_to_service(struct gss_api_mech *, u32 pseudoflavor);
 char *gss_service_to_auth_domain_name(struct gss_api_mech *, u32 service);
 

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2007-07-10 11:28:10.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2007-07-10 11:27:13.000000000 +1000
@@ -212,6 +212,7 @@ struct svc_rqst {
 	struct svc_pool *	rq_pool;	/* thread pool */
 	struct svc_procedure *	rq_procinfo;	/* procedure info */
 	struct auth_ops *	rq_authop;	/* authentication flavour */
+	u32			rq_flavor;	/* pseudoflavor */
 	struct svc_cred		rq_cred;	/* auth info */
 	struct sk_buff *	rq_skbuff;	/* fast recv inet buffer */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */

diff .prev/net/sunrpc/auth_gss/gss_mech_switch.c ./net/sunrpc/auth_gss/gss_mech_switch.c
--- .prev/net/sunrpc/auth_gss/gss_mech_switch.c	2007-07-10 11:28:10.000000000 +1000
+++ ./net/sunrpc/auth_gss/gss_mech_switch.c	2007-07-10 11:28:53.000000000 +1000
@@ -200,6 +200,20 @@ gss_mech_get_by_pseudoflavor(u32 pseudof
 EXPORT_SYMBOL(gss_mech_get_by_pseudoflavor);
 
 u32
+gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
+{
+	int i;
+
+	for (i = 0; i < gm->gm_pf_num; i++) {
+		if (gm->gm_pfs[i].service == service) {
+			return gm->gm_pfs[i].pseudoflavor;
+		}
+	}
+	return RPC_AUTH_MAXFLAVOR; /* illegal value */
+}
+EXPORT_SYMBOL(gss_svc_to_pseudoflavor);
+
+u32
 gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 {
 	int i;

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2007-07-10 11:28:10.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2007-07-10 11:27:13.000000000 +1000
@@ -1145,6 +1145,8 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		}
 		svcdata->rsci = rsci;
 		cache_get(&rsci->h);
+		rqstp->rq_flavor = gss_svc_to_pseudoflavor(
+					rsci->mechctx->mech_type, gc->gc_svc);
 		ret = SVC_OK;
 		goto out;
 	}

diff .prev/net/sunrpc/svcauth_unix.c ./net/sunrpc/svcauth_unix.c
--- .prev/net/sunrpc/svcauth_unix.c	2007-07-10 11:28:10.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2007-07-10 11:27:13.000000000 +1000
@@ -5,6 +5,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/svcauth.h>
+#include <linux/sunrpc/gss_api.h>
 #include <linux/err.h>
 #include <linux/seq_file.h>
 #include <linux/hash.h>
@@ -707,6 +708,7 @@ svcauth_null_accept(struct svc_rqst *rqs
 	svc_putnl(resv, RPC_AUTH_NULL);
 	svc_putnl(resv, 0);
 
+	rqstp->rq_flavor = RPC_AUTH_NULL;
 	return SVC_OK;
 }
 
@@ -784,6 +786,7 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	svc_putnl(resv, RPC_AUTH_NULL);
 	svc_putnl(resv, 0);
 
+	rqstp->rq_flavor = RPC_AUTH_UNIX;
 	return SVC_OK;
 
 badcred:

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
