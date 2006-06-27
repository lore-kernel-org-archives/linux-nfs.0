From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 14] knfsd: svcrpc: gss: simplify rsc_parse()
Date: Tue, 27 Jun 2006 17:20:22 +1000
Message-ID: <1060627072022.26697@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7s5-0006NX-H2
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:29 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7s5-0006zu-03
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:29 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>


Adopt a simpler convention for gss_mech_put(), to simplify rsc_parse().

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./net/sunrpc/auth_gss/gss_mech_switch.c |    6 +++---
 ./net/sunrpc/auth_gss/svcauth_gss.c     |   12 ++++--------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff .prev/net/sunrpc/auth_gss/gss_mech_switch.c ./net/sunrpc/auth_gss/gss_mech_switch.c
--- .prev/net/sunrpc/auth_gss/gss_mech_switch.c	2006-06-27 14:59:44.000000000 +1000
+++ ./net/sunrpc/auth_gss/gss_mech_switch.c	2006-06-27 14:59:44.000000000 +1000
@@ -224,7 +224,8 @@ EXPORT_SYMBOL(gss_service_to_auth_domain
 void
 gss_mech_put(struct gss_api_mech * gm)
 {
-	module_put(gm->gm_owner);
+	if (gm)
+		module_put(gm->gm_owner);
 }
 
 EXPORT_SYMBOL(gss_mech_put);
@@ -307,8 +308,7 @@ gss_delete_sec_context(struct gss_ctx	**
 		(*context_handle)->mech_type->gm_ops
 			->gss_delete_sec_context((*context_handle)
 							->internal_ctx_id);
-	if ((*context_handle)->mech_type)
-		gss_mech_put((*context_handle)->mech_type);
+	gss_mech_put((*context_handle)->mech_type);
 	kfree(*context_handle);
 	*context_handle=NULL;
 	return GSS_S_COMPLETE;

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2006-06-27 14:59:44.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-06-27 14:59:44.000000000 +1000
@@ -425,6 +425,7 @@ static int rsc_parse(struct cache_detail
 	struct rsc rsci, *rscp = NULL;
 	time_t expiry;
 	int status = -EINVAL;
+	struct gss_api_mech *gm = NULL;
 
 	memset(&rsci, 0, sizeof(rsci));
 	/* context handle */
@@ -453,7 +454,6 @@ static int rsc_parse(struct cache_detail
 		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
 	else {
 		int N, i;
-		struct gss_api_mech *gm;
 
 		/* gid */
 		if (get_int(&mesg, &rsci.cred.cr_gid))
@@ -488,21 +488,17 @@ static int rsc_parse(struct cache_detail
 		status = -EINVAL;
 		/* mech-specific data: */
 		len = qword_get(&mesg, buf, mlen);
-		if (len < 0) {
-			gss_mech_put(gm);
+		if (len < 0)
 			goto out;
-		}
 		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx);
-		if (status) {
-			gss_mech_put(gm);
+		if (status)
 			goto out;
-		}
-		gss_mech_put(gm);
 	}
 	rsci.h.expiry_time = expiry;
 	rscp = rsc_update(&rsci, rscp);
 	status = 0;
 out:
+	gss_mech_put(gm);
 	rsc_free(&rsci);
 	if (rscp)
 		cache_put(&rscp->h, &rsc_cache);

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
