Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752993AbcEWQSc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2016 12:18:32 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 32623C05B1D4
	for <linux-nfs@vger.kernel.org>; Mon, 23 May 2016 16:18:31 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-59-118.rdu2.redhat.com [10.10.59.118])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u4NGIT54012144
	for <linux-nfs@vger.kernel.org>; Mon, 23 May 2016 12:18:30 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH 1/1] libnfsidmap: Query DNS for the NFSv4 ID domain
Date: Mon, 23 May 2016 12:18:27 -0400
Message-Id: <1464020307-8806-2-git-send-email-steved@redhat.com>
In-Reply-To: <1464020307-8806-1-git-send-email-steved@redhat.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a DNS domain is found in nfs4_init_name_mapping()
query the DNS for the _nfsv4-iddomainname.tcp SRV record.
When the record exists, use that as the v4 id domain.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac  |  1 +
 libnfsidmap.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 89 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 5944166..52e12c8 100644
--- a/configure.ac
+++ b/configure.ac
@@ -13,6 +13,7 @@ LT_INIT
 AC_PROG_CC
 
 # Checks for libraries.
+AC_CHECK_LIB([resolv], [res_querydomain])
 
 AC_ARG_ENABLE([ldap],
 	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:@default=detect@:>@])])
diff --git a/libnfsidmap.c b/libnfsidmap.c
index a8a9229..84b5ea8 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -53,6 +53,10 @@
 #include <stdarg.h>
 #include <dlfcn.h>
 #include <ctype.h>
+#include <resolv.h>
+#include <arpa/nameser.h>
+#include <arpa/nameser_compat.h>
+
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
 #include "cfg.h"
@@ -79,6 +83,10 @@ gid_t nobody_gid = (gid_t)-1;
 #define IDMAPD_DEFAULT_DOMAIN "localdomain"
 #endif
 
+#ifndef IDMAPD_DEFAULT_SRVNAME
+#define IDMAPD_DEFAULT_SRVNAME "_nfsv4-iddomainname.tcp"
+#endif
+
 /* Default logging fuction */
 static void default_logger(const char *fmt, ...)
 {
@@ -129,6 +137,76 @@ static int domain_from_dns(char **domain)
 	return 0;
 }
 
+static char * 
+iddomain_from_dns(char *domain)
+{
+	int len, l;
+	unsigned char *msg, *eom, *comp_dn; 
+	char *exp_dn, *iddomain = NULL;
+	const char *srvname = IDMAPD_DEFAULT_SRVNAME;
+	unsigned short count;
+	HEADER *hdr;
+
+	if ((msg = calloc(1, NS_MAXMSG)) == NULL) {
+		IDMAP_LOG(1, ("iddomain_from_dns: calloc(msg) failed: %m\n"));
+		return NULL;
+	}
+	if ((exp_dn = calloc(1, NS_MAXDNAME)) == NULL) {
+		IDMAP_LOG(1, ("iddomain_from_dns: calloc(exp_dn) failed: %m\n"));
+		free(msg);
+		return NULL;
+	}
+	len = res_querydomain(srvname, domain, C_IN, T_SRV, msg, NS_MAXMSG);
+	if (len < 0) {
+		IDMAP_LOG(1, ("SRV query failed for %s.%s: %s\n", 
+				srvname, domain, hstrerror(h_errno)));
+		goto free_mem;
+	}
+
+	hdr = (HEADER *)msg;
+	/* answer count */
+	count = ntohs(hdr->ancount);
+
+	/* Note: if more than one answer is returned, only
+	 * the first answer will be processed 
+	 */
+	if (count < 1) {
+		IDMAP_LOG(1, ("No SRV record returned for %s\n", srvname));
+		goto free_mem;
+	}
+
+	/* find the EOM */
+	eom = msg + len;
+	/* skip header */
+	comp_dn = &msg[HFIXEDSZ];
+	/* skip question header */
+	comp_dn += dn_skipname(comp_dn, eom) + QFIXEDSZ;
+
+	/* read in the question */
+	l = dn_expand(msg, eom, comp_dn, exp_dn, NS_MAXDNAME);
+	if (l < 0) {
+		IDMAP_LOG(1, ("dn_expand(que) failed for %s.%s: %s\n",
+			srvname, default_domain, hstrerror(h_errno)));
+		goto free_mem;
+	}
+
+	/* skip to the answer and read it in */
+	comp_dn += 18;
+	l = dn_expand(msg, eom, comp_dn, exp_dn, NS_MAXDNAME);
+	if (l < 0) {
+		IDMAP_LOG(1, ("dn_expand(ans) failed for %s.%s: %s\n",
+			srvname, default_domain, hstrerror(h_errno)));
+		goto free_mem;
+	}
+	iddomain = strdup(exp_dn);
+
+free_mem:
+	free(msg);
+	free(exp_dn);
+
+	return (iddomain);
+}
+
 static int load_translation_plugin(char *method, struct mapping_plugin *plgn)
 {
 	void *dl = NULL;
@@ -233,7 +311,7 @@ int nfs4_init_name_mapping(char *conffile)
 	int ret = -ENOENT;
 	int dflt = 0;
 	struct conf_list *nfs4_methods, *gss_methods;
-	char *nobody_user, *nobody_group;
+	char *nobody_user, *nobody_group, *iddomain;
 
 	/* XXX: need to be able to reload configurations... */
 	if (nfs4_plugins) /* already succesfully initialized */
@@ -254,6 +332,15 @@ int nfs4_init_name_mapping(char *conffile)
 				  "user defined in %s\n", 
 				  IDMAPD_DEFAULT_DOMAIN, PATH_IDMAPDCONF));
 			default_domain = IDMAPD_DEFAULT_DOMAIN;
+		} else {
+			/* Since a DNS domain does exist, see if the 
+		 	 * idmap domain exists in DNS
+			 */
+			iddomain = iddomain_from_dns(default_domain);
+			if (iddomain != NULL) {
+				free(default_domain);
+				default_domain = iddomain;
+			}
 		}
 	}
 	IDMAP_LOG(1, ("libnfsidmap: using%s domain: %s",
-- 
2.5.0

