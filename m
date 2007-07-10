From: NeilBrown <neilb@suse.de>
Subject: [PATCH 018 of 20] knfsd: nfsd4: secinfo handling without
	secinfo= option
Date: Tue, 10 Jul 2007 12:28:10 +1000
Message-ID: <1070710022810.13598@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85SW-0005Aa-Pa
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:28:15 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85SZ-0004q6-BB
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:28:16 -0700
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


From: J. Bruce Fields <bfields@citi.umich.edu>

We could return some sort of error in the case where someone asks for
secinfo on an export without the secinfo= option set--that'd be no worse
than what we've been doing.  But it's not really correct.  So, hack up
an approximate secinfo response in that case--it may not be complete,
but it'll tell the client at least one acceptable security flavor.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c                  |   30 +++++++++++++++++++++++++++---
 ./include/linux/sunrpc/svcauth_gss.h |    1 +
 ./net/sunrpc/auth_gss/svcauth_gss.c  |    9 +++++++++
 3 files changed, 37 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2007-07-10 11:52:23.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2007-07-10 12:18:53.000000000 +1000
@@ -57,6 +57,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfs4_acl.h>
 #include <linux/sunrpc/gss_api.h>
+#include <linux/sunrpc/svcauth_gss.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -2454,15 +2455,38 @@ nfsd4_encode_secinfo(struct nfsd4_compou
 {
 	int i = 0;
 	struct svc_export *exp = secinfo->si_exp;
+	u32 nflavs;
+	struct exp_flavor_info *flavs;
+	struct exp_flavor_info def_flavs[2];
 	ENCODE_HEAD;
 
 	if (nfserr)
 		goto out;
+	if (exp->ex_nflavors) {
+		flavs = exp->ex_flavors;
+		nflavs = exp->ex_nflavors;
+	} else { /* Handling of some defaults in absence of real secinfo: */
+		flavs = def_flavs;
+		if (exp->ex_client->flavour->flavour == RPC_AUTH_UNIX) {
+			nflavs = 2;
+			flavs[0].pseudoflavor = RPC_AUTH_UNIX;
+			flavs[1].pseudoflavor = RPC_AUTH_NULL;
+		} else if (exp->ex_client->flavour->flavour == RPC_AUTH_GSS) {
+			nflavs = 1;
+			flavs[0].pseudoflavor
+					= svcauth_gss_flavor(exp->ex_client);
+		} else {
+			nflavs = 1;
+			flavs[0].pseudoflavor
+					= exp->ex_client->flavour->flavour;
+		}
+	}
+
 	RESERVE_SPACE(4);
-	WRITE32(exp->ex_nflavors);
+	WRITE32(nflavs);
 	ADJUST_ARGS();
-	for (i = 0; i < exp->ex_nflavors; i++) {
-		u32 flav = exp->ex_flavors[i].pseudoflavor;
+	for (i = 0; i < nflavs; i++) {
+		u32 flav = flavs[i].pseudoflavor;
 		struct gss_api_mech *gm = gss_mech_get_by_pseudoflavor(flav);
 
 		if (gm) {

diff .prev/include/linux/sunrpc/svcauth_gss.h ./include/linux/sunrpc/svcauth_gss.h
--- .prev/include/linux/sunrpc/svcauth_gss.h	2007-07-10 11:19:39.000000000 +1000
+++ ./include/linux/sunrpc/svcauth_gss.h	2007-07-10 12:19:19.000000000 +1000
@@ -23,6 +23,7 @@ int gss_svc_init(void);
 void gss_svc_shutdown(void);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 void svcauth_gss_unregister_pseudoflavor(char *name);
+u32 svcauth_gss_flavor(struct auth_domain *dom);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2007-07-10 11:35:37.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2007-07-10 12:18:53.000000000 +1000
@@ -743,6 +743,15 @@ find_gss_auth_domain(struct gss_ctx *ctx
 
 static struct auth_ops svcauthops_gss;
 
+u32 svcauth_gss_flavor(struct auth_domain *dom)
+{
+	struct gss_domain *gd = container_of(dom, struct gss_domain, h);
+
+	return gd->pseudoflavor;
+}
+
+EXPORT_SYMBOL(svcauth_gss_flavor);
+
 int
 svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name)
 {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
