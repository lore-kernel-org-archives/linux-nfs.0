Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42750 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758551Ab3ENVMz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:12:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] svcrpc: store gss mech in svc_cred
Date: Tue, 14 May 2013 17:12:52 -0400
Message-Id: <1368565973-16739-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1368565973-16739-1-git-send-email-bfields@redhat.com>
References: <1368565973-16739-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Store a pointer to the gss mechanism used in the rq_cred and cl_cred.
This will make it easier to enforce SP4_MACH_CRED, which needs to
compare the mechanism used on the exchange_id with that used on
protected operations.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c                   |    3 +++
 include/linux/sunrpc/gss_api.h        |    2 ++
 include/linux/sunrpc/svcauth.h        |    4 ++++
 net/sunrpc/auth_gss/gss_mech_switch.c |    5 ++++-
 net/sunrpc/auth_gss/svcauth_gss.c     |    4 +---
 5 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 91ead0e..52f9e92 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1188,6 +1188,9 @@ static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 	target->cr_gid = source->cr_gid;
 	target->cr_group_info = source->cr_group_info;
 	get_group_info(target->cr_group_info);
+	target->cr_gss_mech = source->cr_gss_mech;
+	if (source->cr_gss_mech)
+		gss_mech_get(source->cr_gss_mech);
 	return 0;
 }
 
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 161463e..1f911cc 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -151,6 +151,8 @@ struct gss_api_mech *gss_mech_get_by_pseudoflavor(u32);
 /* Fill in an array with a list of supported pseudoflavors */
 int gss_mech_list_pseudoflavors(rpc_authflavor_t *, int);
 
+struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
+
 /* For every successful gss_mech_get or gss_mech_get_by_* call there must be a
  * corresponding call to gss_mech_put. */
 void gss_mech_put(struct gss_api_mech *);
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 95c9566..8d71d65 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -14,6 +14,7 @@
 #include <linux/string.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/cache.h>
+#include <linux/sunrpc/gss_api.h>
 #include <linux/hash.h>
 #include <linux/cred.h>
 
@@ -23,6 +24,7 @@ struct svc_cred {
 	struct group_info	*cr_group_info;
 	u32			cr_flavor; /* pseudoflavor */
 	char			*cr_principal; /* for gss */
+	struct gss_api_mech	*cr_gss_mech;
 };
 
 static inline void init_svc_cred(struct svc_cred *cred)
@@ -37,6 +39,8 @@ static inline void free_svc_cred(struct svc_cred *cred)
 	if (cred->cr_group_info)
 		put_group_info(cred->cr_group_info);
 	kfree(cred->cr_principal);
+	gss_mech_put(cred->cr_gss_mech);
+	init_svc_cred(cred);
 }
 
 struct svc_rqst;		/* forward decl */
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index defa9d3..27ce262 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -139,11 +139,12 @@ void gss_mech_unregister(struct gss_api_mech *gm)
 }
 EXPORT_SYMBOL_GPL(gss_mech_unregister);
 
-static struct gss_api_mech *gss_mech_get(struct gss_api_mech *gm)
+struct gss_api_mech *gss_mech_get(struct gss_api_mech *gm)
 {
 	__module_get(gm->gm_owner);
 	return gm;
 }
+EXPORT_SYMBOL(gss_mech_get);
 
 static struct gss_api_mech *
 _gss_mech_get_by_name(const char *name)
@@ -360,6 +361,7 @@ gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(gss_pseudoflavor_to_service);
 
 char *
 gss_service_to_auth_domain_name(struct gss_api_mech *gm, u32 service)
@@ -379,6 +381,7 @@ gss_mech_put(struct gss_api_mech * gm)
 	if (gm)
 		module_put(gm->gm_owner);
 }
+EXPORT_SYMBOL(gss_mech_put);
 
 /* The mech could probably be determined from the token instead, but it's just
  * as easy for now to pass it in. */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index c59f875..9f0f017 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -391,7 +391,6 @@ update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
 	memset(&new->seqdata, 0, sizeof(new->seqdata));
 	spin_lock_init(&new->seqdata.sd_lock);
 	new->cred = tmp->cred;
-	new->cred.cr_principal = tmp->cred.cr_principal;
 	init_svc_cred(&tmp->cred);
 }
 
@@ -485,7 +484,7 @@ static int rsc_parse(struct cache_detail *cd,
 		len = qword_get(&mesg, buf, mlen);
 		if (len < 0)
 			goto out;
-		gm = gss_mech_get_by_name(buf);
+		gm = rsci.cred.cr_gss_mech = gss_mech_get_by_name(buf);
 		status = -EOPNOTSUPP;
 		if (!gm)
 			goto out;
@@ -515,7 +514,6 @@ static int rsc_parse(struct cache_detail *cd,
 	rscp = rsc_update(cd, &rsci, rscp);
 	status = 0;
 out:
-	gss_mech_put(gm);
 	rsc_free(&rsci);
 	if (rscp)
 		cache_put(&rscp->h, cd);
-- 
1.7.9.5

