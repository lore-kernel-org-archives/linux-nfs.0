Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:40878 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2392167AbeHPTFZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 15:05:25 -0400
Received: by mail-it0-f65.google.com with SMTP id h23-v6so7363416ita.5
        for <linux-nfs@vger.kernel.org>; Thu, 16 Aug 2018 09:06:02 -0700 (PDT)
Subject: [PATCH v2 2/4] sunrpc: Extract target name into svc_cred
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, simo@redhat.com
Date: Thu, 16 Aug 2018 12:05:59 -0400
Message-ID: <20180816160559.2230.47274.stgit@klimt.1015granger.net>
In-Reply-To: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
References: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.0 callback needs to know the GSS target name the client used
when it established its lease. That information is available from
the GSS context created by gssproxy. Make it available in each
svc_cred.

Note this will also give us access to the real target service
principal name (which is typically "nfs", but spec does not require
that).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c                  |    7 ++-
 include/linux/sunrpc/svcauth.h       |    3 +
 net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
 3 files changed, 53 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8571414..9d9bc4c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1979,8 +1979,10 @@ static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 	target->cr_principal = kstrdup(source->cr_principal, GFP_KERNEL);
 	target->cr_raw_principal = kstrdup(source->cr_raw_principal,
 								GFP_KERNEL);
-	if ((source->cr_principal && ! target->cr_principal) ||
-	    (source->cr_raw_principal && ! target->cr_raw_principal))
+	target->cr_targ_princ = kstrdup(source->cr_targ_princ, GFP_KERNEL);
+	if ((source->cr_principal && !target->cr_principal) ||
+	    (source->cr_raw_principal && !target->cr_raw_principal) ||
+	    (source->cr_targ_princ && !target->cr_targ_princ))
 		return -ENOMEM;
 
 	target->cr_flavor = source->cr_flavor;
@@ -2057,6 +2059,7 @@ static bool is_gss_cred(struct svc_cred *cr)
 		|| (!gid_eq(cr1->cr_gid, cr2->cr_gid))
 		|| !groups_equal(cr1->cr_group_info, cr2->cr_group_info))
 		return false;
+	/* XXX: check that cr_targ_princ fields match ? */
 	if (cr1->cr_principal == cr2->cr_principal)
 		return true;
 	if (!cr1->cr_principal || !cr2->cr_principal)
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 7c36565..04e404a 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -31,6 +31,7 @@ struct svc_cred {
 	/* name of form servicetype@hostname, passed down by
 	 * rpc.svcgssd, or computed from the above: */
 	char			*cr_principal;
+	char			*cr_targ_princ;
 	struct gss_api_mech	*cr_gss_mech;
 };
 
@@ -39,6 +40,7 @@ static inline void init_svc_cred(struct svc_cred *cred)
 	cred->cr_group_info = NULL;
 	cred->cr_raw_principal = NULL;
 	cred->cr_principal = NULL;
+	cred->cr_targ_princ = NULL;
 	cred->cr_gss_mech = NULL;
 }
 
@@ -48,6 +50,7 @@ static inline void free_svc_cred(struct svc_cred *cred)
 		put_group_info(cred->cr_group_info);
 	kfree(cred->cr_raw_principal);
 	kfree(cred->cr_principal);
+	kfree(cred->cr_targ_princ);
 	gss_mech_put(cred->cr_gss_mech);
 	init_svc_cred(cred);
 }
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 1c7c49d..73dcda0 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -234,6 +234,35 @@ static int gssp_alloc_receive_pages(struct gssx_arg_accept_sec_context *arg)
 	return 0;
 }
 
+static char *gssp_stringify(struct xdr_netobj *netobj)
+{
+	return kstrndup(netobj->data, netobj->len, GFP_KERNEL);
+}
+
+static void gssp_hostbased_service(char **principal)
+{
+	char *c;
+
+	if (!*principal)
+		return;
+
+	/* terminate and remove realm part */
+	c = strchr(*principal, '@');
+	if (c) {
+		*c = '\0';
+
+		/* change service-hostname delimiter */
+		c = strchr(*principal, '/');
+		if (c)
+			*c = '@';
+	}
+	if (!c) {
+		/* not a service principal */
+		kfree(*principal);
+		*principal = NULL;
+	}
+}
+
 /*
  * Public functions
  */
@@ -262,6 +291,7 @@ int gssp_accept_sec_context_upcall(struct net *net,
 		 */
 		.exported_context_token.len = GSSX_max_output_handle_sz,
 		.mech.len = GSS_OID_MAX_LEN,
+		.targ_name.display_name.len = GSSX_max_princ_sz,
 		.src_name.display_name.len = GSSX_max_princ_sz
 	};
 	struct gssx_res_accept_sec_context res = {
@@ -275,6 +305,7 @@ int gssp_accept_sec_context_upcall(struct net *net,
 		.rpc_cred = NULL, /* FIXME ? */
 	};
 	struct xdr_netobj client_name = { 0 , NULL };
+	struct xdr_netobj target_name = { 0, NULL };
 	int ret;
 
 	if (data->in_handle.len != 0)
@@ -285,8 +316,6 @@ int gssp_accept_sec_context_upcall(struct net *net,
 	if (ret)
 		return ret;
 
-	/* use nfs/ for targ_name ? */
-
 	ret = gssp_call(net, &msg);
 
 	gssp_free_receive_pages(&arg);
@@ -304,6 +333,7 @@ int gssp_accept_sec_context_upcall(struct net *net,
 			kfree(rctxh.mech.data);
 		}
 		client_name = rctxh.src_name.display_name;
+		target_name = rctxh.targ_name.display_name;
 	}
 
 	if (res.options.count == 1) {
@@ -325,32 +355,22 @@ int gssp_accept_sec_context_upcall(struct net *net,
 	}
 
 	/* convert to GSS_NT_HOSTBASED_SERVICE form and set into creds */
-	if (data->found_creds && client_name.data != NULL) {
-		char *c;
-
-		data->creds.cr_raw_principal = kstrndup(client_name.data,
-						client_name.len, GFP_KERNEL);
-
-		data->creds.cr_principal = kstrndup(client_name.data,
-						client_name.len, GFP_KERNEL);
-		if (data->creds.cr_principal) {
-			/* terminate and remove realm part */
-			c = strchr(data->creds.cr_principal, '@');
-			if (c) {
-				*c = '\0';
-
-				/* change service-hostname delimiter */
-				c = strchr(data->creds.cr_principal, '/');
-				if (c) *c = '@';
-			}
-			if (!c) {
-				/* not a service principal */
-				kfree(data->creds.cr_principal);
-				data->creds.cr_principal = NULL;
-			}
+	if (data->found_creds) {
+		if (client_name.data) {
+			data->creds.cr_raw_principal =
+					gssp_stringify(&client_name);
+			data->creds.cr_principal =
+					gssp_stringify(&client_name);
+			gssp_hostbased_service(&data->creds.cr_principal);
+		}
+		if (target_name.data) {
+			data->creds.cr_targ_princ =
+					gssp_stringify(&target_name);
+			gssp_hostbased_service(&data->creds.cr_targ_princ);
 		}
 	}
 	kfree(client_name.data);
+	kfree(target_name.data);
 
 	return ret;
 }
