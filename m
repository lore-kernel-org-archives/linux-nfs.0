Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196AbbKGSOQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Nov 2015 13:14:16 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id E35F58E221
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2015 18:14:15 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-59-101.rdu2.redhat.com [10.10.59.101])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA7IECrO027545
	for <linux-nfs@vger.kernel.org>; Sat, 7 Nov 2015 13:14:15 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] gssd: reworked second level of debugging
Date: Sat,  7 Nov 2015 13:14:10 -0500
Message-Id: <1446920050-5968-4-git-send-email-steved@redhat.com>
In-Reply-To: <1446920050-5968-1-git-send-email-steved@redhat.com>
References: <1446920050-5968-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trimmed down the number messages being logged
by moving them into level 3 or 4 of debugging

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/context_heimdal.c |  2 +-
 utils/gssd/context_lucid.c   |  6 +++---
 utils/gssd/gssd.c            |  2 +-
 utils/gssd/gssd_proc.c       |  6 +++---
 utils/gssd/krb5_util.c       | 10 +++++-----
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/utils/gssd/context_heimdal.c b/utils/gssd/context_heimdal.c
index 1e8738a..d07103b 100644
--- a/utils/gssd/context_heimdal.c
+++ b/utils/gssd/context_heimdal.c
@@ -260,7 +260,7 @@ serialize_krb5_ctx(gss_ctx_id_t *_ctx, gss_buffer_desc *buf, int32_t *endtime)
 	if (write_heimdal_seq_key(&p, end, ctx)) goto out_err;
 
 	buf->length = p - (char *)buf->value;
-	printerr(2, "serialize_krb5_ctx: returning buffer "
+	printerr(4, "serialize_krb5_ctx: returning buffer "
 		    "with %d bytes\n", buf->length);
 
 	return 0;
diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index badbe88..5d77c21 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -206,7 +206,7 @@ prepare_krb5_rfc4121_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	if (WRITE_BYTES(&p, end, lctx->send_seq)) goto out_err;
 
 	/* Protocol 0 here implies DES3 or RC4 */
-	printerr(2, "%s: protocol %d\n", __FUNCTION__, lctx->protocol);
+	printerr(4, "%s: protocol %d\n", __FUNCTION__, lctx->protocol);
 	if (lctx->protocol == 0) {
 		enctype = lctx->rfc1964_kd.ctx_key.type;
 		keysize = lctx->rfc1964_kd.ctx_key.length;
@@ -219,7 +219,7 @@ prepare_krb5_rfc4121_buffer(gss_krb5_lucid_context_v1_t *lctx,
 			keysize = lctx->cfx_kd.ctx_key.length;
 		}
 	}
-	printerr(2, "%s: serializing key with enctype %d and size %d\n",
+	printerr(4, "%s: serializing key with enctype %d and size %d\n",
 		 __FUNCTION__, enctype, keysize);
 
 	if (WRITE_BYTES(&p, end, enctype)) goto out_err;
@@ -265,7 +265,7 @@ serialize_krb5_ctx(gss_ctx_id_t *ctx, gss_buffer_desc *buf, int32_t *endtime)
 	gss_krb5_lucid_context_v1_t *lctx = 0;
 	int retcode = 0;
 
-	printerr(2, "DEBUG: %s: lucid version!\n", __FUNCTION__);
+	printerr(4, "DEBUG: %s: lucid version!\n", __FUNCTION__);
 	maj_stat = gss_export_lucid_sec_context(&min_stat, ctx,
 						1, &return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 804c53a..e7cb07f 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -556,7 +556,7 @@ gssd_scan_topdir(const char *name)
 		if (clp->scanned)
 			continue;
 
-		printerr(2, "destroying client %s\n", clp->relpath);
+		printerr(3, "destroying client %s\n", clp->relpath);
 		saveprev = clp->list.tqe_prev;
 		TAILQ_REMOVE(&tdi->clnt_list, clp, list);
 		gssd_destroy_client(clp);
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 29f0e24..1ef68d8 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -231,7 +231,7 @@ populate_port(struct sockaddr *sa, const socklen_t salen,
 	switch (sa->sa_family) {
 	case AF_INET:
 		if (s4->sin_port != 0) {
-			printerr(2, "DEBUG: port already set to %d\n",
+			printerr(4, "DEBUG: port already set to %d\n",
 				 ntohs(s4->sin_port));
 			return 1;
 		}
@@ -239,7 +239,7 @@ populate_port(struct sockaddr *sa, const socklen_t salen,
 #ifdef IPV6_SUPPORTED
 	case AF_INET6:
 		if (s6->sin6_port != 0) {
-			printerr(2, "DEBUG: port already set to %d\n",
+			printerr(4, "DEBUG: port already set to %d\n",
 				 ntohs(s6->sin6_port));
 			return 1;
 		}
@@ -393,7 +393,7 @@ create_auth_rpc_client(struct clnt_info *clp,
 	auth = authgss_create_default(rpc_clnt, tgtname, &sec);
 	if (!auth) {
 		/* Our caller should print appropriate message */
-		printerr(2, "WARNING: Failed to create krb5 context for "
+		printerr(1, "WARNING: Failed to create krb5 context for "
 			    "user with uid %d for server %s\n",
 			 uid, tgtname);
 		goto out_fail;
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 0d07d1f..8ef8184 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -356,7 +356,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	 */
 	now += 300;
 	if (ple->ccname && ple->endtime > now && !nocache) {
-		printerr(2, "INFO: Credentials in CC '%s' are good until %d\n",
+		printerr(3, "INFO: Credentials in CC '%s' are good until %d\n",
 			 ple->ccname, ple->endtime);
 		code = 0;
 		goto out;
@@ -476,7 +476,7 @@ gssd_set_krb5_ccache_name(char *ccname)
 #ifdef USE_GSS_KRB5_CCACHE_NAME
 	u_int	maj_stat, min_stat;
 
-	printerr(2, "using gss_krb5_ccache_name to select krb5 ccache %s\n",
+	printerr(3, "using gss_krb5_ccache_name to select krb5 ccache %s\n",
 		 ccname);
 	maj_stat = gss_krb5_ccache_name(&min_stat, ccname, NULL);
 	if (maj_stat != GSS_S_COMPLETE) {
@@ -491,7 +491,7 @@ gssd_set_krb5_ccache_name(char *ccname)
 	 * function above for which there is no generic gssapi
 	 * equivalent.)
 	 */
-	printerr(2, "using environment variable to select krb5 ccache %s\n",
+	printerr(3, "using environment variable to select krb5 ccache %s\n",
 		 ccname);
 	setenv("KRB5CCNAME", ccname, 1);
 #endif
@@ -1092,8 +1092,8 @@ gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirpattern)
 	struct dirent		*d;
 	int			err, i, j;
 
-	printerr(2, "getting credentials for client with uid %u for "
-		    "server %s\n", uid, servername);
+	printerr(3, "looking for client creds with uid %u for "
+		    "server %s in %s\n", uid, servername, dirpattern);
 
 	for (i = 0, j = 0; dirpattern[i] != '\0'; i++) {
 		switch (dirpattern[i]) {
-- 
2.4.3

