Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46531 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758487Ab1FVVcK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 17:32:10 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1QZV1t-00017F-5t
	for linux-nfs@vger.kernel.org; Wed, 22 Jun 2011 17:32:09 -0400
Date: Wed, 22 Jun 2011 17:32:09 -0400
To: linux-nfs@vger.kernel.org
Subject: autoload rpcsec_gss_krb5
Message-ID: <20110622213209.GA3010@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There are three layers of modules required for rpcsec_gss to work:
auth_gss, a mechanism (rpcsec_gss_krb5), and then any crypto algorithms.

We autoload all of those except rpcsec_gss_krb5.

Objections?

(I suppose another option would be to get rid of the gss mechanism layer
entirely, now that we've only got one of them.  But I'd rather keep it.)

--b.

commit 027c33f5a292b5a4bbfc1ad9ced19ad4626d056b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Jun 22 10:50:08 2011 -0400

    rpc: allow autoloading of gss mechanisms
    
    Remove the need for an explicit modprobe of rpcsec_gss_krb5.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 0a9a2ec..5c33926 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -743,6 +743,13 @@ static struct pf_desc gss_kerberos_pfs[] = {
 	},
 };
 
+MODULE_ALIAS("rpc-auth-gss-krb5");
+MODULE_ALIAS("rpc-auth-gss-krb5i");
+MODULE_ALIAS("rpc-auth-gss-krb5p");
+MODULE_ALIAS("rpc-auth-gss-390003");
+MODULE_ALIAS("rpc-auth-gss-390004");
+MODULE_ALIAS("rpc-auth-gss-390005");
+
 static struct gss_api_mech gss_kerberos_mech = {
 	.gm_name	= "krb5",
 	.gm_owner	= THIS_MODULE,
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index e3c36a2..ca8cad8 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -141,7 +141,7 @@ gss_mech_get(struct gss_api_mech *gm)
 EXPORT_SYMBOL_GPL(gss_mech_get);
 
 struct gss_api_mech *
-gss_mech_get_by_name(const char *name)
+_gss_mech_get_by_name(const char *name)
 {
 	struct gss_api_mech	*pos, *gm = NULL;
 
@@ -158,6 +158,17 @@ gss_mech_get_by_name(const char *name)
 
 }
 
+struct gss_api_mech * gss_mech_get_by_name(const char *name)
+{
+	struct gss_api_mech *gm = NULL;
+
+	gm = _gss_mech_get_by_name(name);
+	if (!gm) {
+		request_module("rpc-auth-gss-%s", name);
+		gm = _gss_mech_get_by_name(name);
+	}
+	return gm;
+}
 EXPORT_SYMBOL_GPL(gss_mech_get_by_name);
 
 struct gss_api_mech *
@@ -194,10 +205,9 @@ mech_supports_pseudoflavor(struct gss_api_mech *gm, u32 pseudoflavor)
 	return 0;
 }
 
-struct gss_api_mech *
-gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
+struct gss_api_mech *_gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
 {
-	struct gss_api_mech *pos, *gm = NULL;
+	struct gss_api_mech *gm = NULL, *pos;
 
 	spin_lock(&registered_mechs_lock);
 	list_for_each_entry(pos, &registered_mechs, gm_list) {
@@ -213,6 +223,20 @@ gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
 	return gm;
 }
 
+struct gss_api_mech *
+gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
+{
+	struct gss_api_mech *gm;
+
+	gm = _gss_mech_get_by_pseudoflavor(pseudoflavor);
+
+	if (!gm) {
+		request_module("rpc-auth-gss-%u", pseudoflavor);
+		gm = _gss_mech_get_by_pseudoflavor(pseudoflavor);
+	}
+	return gm;
+}
+
 EXPORT_SYMBOL_GPL(gss_mech_get_by_pseudoflavor);
 
 int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr)
