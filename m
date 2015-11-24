Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43508 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753974AbbKXRSX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 12:18:23 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, Simo Sorce <simo@redhat.com>
Subject: [PATCH 5/5] nfsd4: fix gss-proxy 4.1 mounts for some AD principals
Date: Tue, 24 Nov 2015 12:18:17 -0500
Message-Id: <1448385497-23737-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1448385497-23737-1-git-send-email-bfields@redhat.com>
References: <1448385497-23737-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The principal name on a gss cred is used to setup the NFSv4.0 callback,
which has to have a client principal name to authenticate to.

That code wants the name to be in the form servicetype@hostname.
rpc.svcgssd passes down such names (and passes down no principal name at
all in the case the principal isn't a service principal).

gss-proxy always passes down the principal name, and passes it down in
the form servicetype/hostname@REALM.  So we've been munging the name
gss-proxy passes down into the format the NFSv4.0 callback code expects,
or throwing away the name if we can't.

Since the introduction of the MACH_CRED enforcement in NFSv4.1, we've
also been using the principal name to verify that certain operations are
done as the same principal as was used on the original EXCHANGE_ID call.

For that application, the original name passed down by gss-proxy is also
useful.

Lack of that name in some cases was causing some kerberized NFSv4.1
mount failures in an Active Directory environment.

This fix only works in the gss-proxy case.  The fix for legacy
rpc.svcgssd would be more involved, and rpc.svcgssd already has other
problems in the AD case.

Reported-and-tested-by: James Ralston <ralston@pobox.com>
Cc: Simo Sorce <simo@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c                  | 10 +++++++++-
 include/linux/sunrpc/svcauth.h       |  9 ++++++++-
 net/sunrpc/auth_gss/gss_rpc_upcall.c |  3 +++
 3 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 36ad22a15d61..0e685201f0db 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1875,6 +1875,10 @@ static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 	ret = strdup_if_nonnull(&target->cr_principal, source->cr_principal);
 	if (ret)
 		return ret;
+	ret = strdup_if_nonnull(&target->cr_raw_principal,
+					source->cr_raw_principal);
+	if (ret)
+		return ret;
 	target->cr_flavor = source->cr_flavor;
 	target->cr_uid = source->cr_uid;
 	target->cr_gid = source->cr_gid;
@@ -1978,6 +1982,9 @@ static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
 		return false;
 	if (!svc_rqst_integrity_protected(rqstp))
 		return false;
+	if (cl->cl_cred.cr_raw_principal)
+		return 0 == strcmp(cl->cl_cred.cr_raw_principal,
+						cr->cr_raw_principal);
 	if (!cr->cr_principal)
 		return false;
 	return 0 == strcmp(cl->cl_cred.cr_principal, cr->cr_principal);
@@ -2389,7 +2396,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		 * Which is a bug, really.  Anyway, we can't enforce
 		 * MACH_CRED in that case, better to give up now:
 		 */
-		if (!new->cl_cred.cr_principal) {
+		if (!new->cl_cred.cr_principal &&
+					!new->cl_cred.cr_raw_principal) {
 			status = nfserr_serverfault;
 			goto out_nolock;
 		}
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 8d71d6577459..c00f53a4ccdd 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -23,13 +23,19 @@ struct svc_cred {
 	kgid_t			cr_gid;
 	struct group_info	*cr_group_info;
 	u32			cr_flavor; /* pseudoflavor */
-	char			*cr_principal; /* for gss */
+	/* name of form servicetype/hostname@REALM, passed down by
+	 * gss-proxy: */
+	char			*cr_raw_principal;
+	/* name of form servicetype@hostname, passed down by
+	 * rpc.svcgssd, or computed from the above: */
+	char			*cr_principal;
 	struct gss_api_mech	*cr_gss_mech;
 };
 
 static inline void init_svc_cred(struct svc_cred *cred)
 {
 	cred->cr_group_info = NULL;
+	cred->cr_raw_principal = NULL;
 	cred->cr_principal = NULL;
 	cred->cr_gss_mech = NULL;
 }
@@ -38,6 +44,7 @@ static inline void free_svc_cred(struct svc_cred *cred)
 {
 	if (cred->cr_group_info)
 		put_group_info(cred->cr_group_info);
+	kfree(cred->cr_raw_principal);
 	kfree(cred->cr_principal);
 	gss_mech_put(cred->cr_gss_mech);
 	init_svc_cred(cred);
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 59eeed43eda2..f0c6a8c78a56 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -326,6 +326,9 @@ int gssp_accept_sec_context_upcall(struct net *net,
 	if (data->found_creds && client_name.data != NULL) {
 		char *c;
 
+		data->creds.cr_raw_principal = kstrndup(client_name.data,
+						client_name.len, GFP_KERNEL);
+
 		data->creds.cr_principal = kstrndup(client_name.data,
 						client_name.len, GFP_KERNEL);
 		if (data->creds.cr_principal) {
-- 
2.5.0

