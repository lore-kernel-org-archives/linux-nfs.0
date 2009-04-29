From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/7] svcgssd: add client's principal name to downcall
	information
Date: Wed, 29 Apr 2009 17:56:16 -0400
Message-ID: <20090429215615.25811.85107.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47702 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbZD2V4Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:16 -0400
In-Reply-To: <20090429214300.25811.81332.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

This patch adds the krb5 hostbased principal, name which the
nfs client used to authenticate, to the svcgssd downcall
information.  This information is needed for the callback
authentication.

When estabishing the callback, nfsd will pass the principal
name in the upcall to the gssd.  gssd will acquire a service
ticket for the specified principal name.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/svcgssd_proc.c |   94 ++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 87 insertions(+), 7 deletions(-)

diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 6f2ba61..f1bfbef 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -56,6 +56,7 @@
 #include "gss_util.h"
 #include "err_util.h"
 #include "context.h"
+#include "gss_oids.h"
 
 extern char * mech2file(gss_OID mech);
 #define SVCGSSD_CONTEXT_CHANNEL "/proc/net/rpc/auth.rpcsec.context/channel"
@@ -73,7 +74,7 @@ struct svc_cred {
 static int
 do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 		gss_OID mech, gss_buffer_desc *context_token,
-		int32_t endtime)
+		int32_t endtime, char *client_name)
 {
 	FILE *f;
 	int i;
@@ -98,9 +99,10 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 	qword_printint(f, cred->cr_gid);
 	qword_printint(f, cred->cr_ngroups);
 	printerr(2, "mech: %s, hndl len: %d, ctx len %d, timeout: %d (%d from now), "
-		 "uid: %d, gid: %d, num aux grps: %d:\n",
+		 "clnt: %s, uid: %d, gid: %d, num aux grps: %d:\n",
 		 fname, out_handle->length, context_token->length,
 		 endtime, endtime - time(0),
+		 client_name ? client_name : "<null>",
 		 cred->cr_uid, cred->cr_gid, cred->cr_ngroups);
 	for (i=0; i < cred->cr_ngroups; i++) {
 		qword_printint(f, cred->cr_groups[i]);
@@ -108,6 +110,8 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 	}
 	qword_print(f, fname);
 	qword_printhex(f, context_token->value, context_token->length);
+	if (client_name)
+		qword_print(f, client_name);
 	err = qword_eol(f);
 	if (err) {
 		printerr(1, "WARNING: error writing to downcall channel "
@@ -307,6 +311,75 @@ print_hexl(const char *description, unsigned char *cp, int length)
 }
 #endif
 
+static int
+get_krb5_hostbased_name (gss_buffer_desc *name, char **hostbased_name)
+{
+	char *p, *sname = NULL;
+	if (strchr(name->value, '@') && strchr(name->value, '/')) {
+		if ((sname = calloc(name->length, 1)) == NULL) {
+			printerr(0, "ERROR: get_krb5_hostbased_name failed "
+				 "to allocate %d bytes\n", name->length);
+			return -1;
+		}
+		/* read in name and instance and replace '/' with '@' */
+		sscanf(name->value, "%[^@]", sname);
+		p = strrchr(sname, '/');
+		if (p == NULL) {    /* The '@' preceeded the '/' */
+			free(sname);
+			return -1;
+		}
+		*p = '@';
+	}
+	*hostbased_name = sname;
+	return 0;
+}
+
+static int
+get_hostbased_client_name(gss_name_t client_name, gss_OID mech,
+			  char **hostbased_name)
+{
+	u_int32_t	maj_stat, min_stat;
+	gss_buffer_desc	name;
+	gss_OID		name_type = GSS_C_NO_OID;
+	char		*cname;
+	int		res = -1;
+
+	*hostbased_name = NULL;	    /* preset in case we fail */
+
+	/* Get the client's gss authenticated name */
+	maj_stat = gss_display_name(&min_stat, client_name, &name, &name_type);
+	if (maj_stat != GSS_S_COMPLETE) {
+		pgsserr("get_hostbased_client_name: gss_display_name",
+			maj_stat, min_stat, mech);
+		goto out_err;
+	}
+	if (name.length >= 0xffff) {	    /* don't overflow */
+		printerr(0, "ERROR: get_hostbased_client_name: "
+			 "received gss_name is too long (%d bytes)\n",
+			 name.length);
+		goto out_rel_buf;
+	}
+
+	/* For Kerberos, transform the NT_KRB5_PRINCIPAL name to
+	 * an NT_HOSTBASED_SERVICE name */
+	if (g_OID_equal(&krb5oid, mech)) {
+		if (get_krb5_hostbased_name(&name, &cname) == 0)
+			*hostbased_name = cname;
+	}
+
+	/* No support for SPKM3, just print a warning (for now) */
+	if (g_OID_equal(&spkm3oid, mech)) {
+		printerr(1, "WARNING: get_hostbased_client_name: "
+			 "no hostbased_name support for SPKM3\n");
+	}
+
+	res = 0;
+out_rel_buf:
+	gss_release_buffer(&min_stat, &name);
+out_err:
+	return res;
+}
+
 void
 handle_nullreq(FILE *f) {
 	/* XXX initialize to a random integer to reduce chances of unnecessary
@@ -325,7 +398,7 @@ handle_nullreq(FILE *f) {
 				null_token = {.value = NULL};
 	u_int32_t		ret_flags;
 	gss_ctx_id_t		ctx = GSS_C_NO_CONTEXT;
-	gss_name_t		client_name;
+	gss_name_t		client_name = NULL;
 	gss_OID			mech = GSS_C_NO_OID;
 	u_int32_t		maj_stat = GSS_S_FAILURE, min_stat = 0;
 	u_int32_t		ignore_min_stat;
@@ -334,6 +407,7 @@ handle_nullreq(FILE *f) {
 	static int		lbuflen = 0;
 	static char		*cp;
 	int32_t			ctx_endtime;
+	char			*hostbased_name = NULL;
 
 	printerr(1, "handling null request\n");
 
@@ -396,11 +470,13 @@ handle_nullreq(FILE *f) {
 	if (get_ids(client_name, mech, &cred)) {
 		/* get_ids() prints error msg */
 		maj_stat = GSS_S_BAD_NAME; /* XXX ? */
-		gss_release_name(&ignore_min_stat, &client_name);
 		goto out_err;
 	}
-	gss_release_name(&ignore_min_stat, &client_name);
-
+	if (get_hostbased_client_name(client_name, mech, &hostbased_name)) {
+		/* get_hostbased_client_name() prints error msg */
+		maj_stat = GSS_S_BAD_NAME; /* XXX ? */
+		goto out_err;
+	}
 
 	/* Context complete. Pass handle_seq in out_handle to use
 	 * for context lookup in the kernel. */
@@ -419,7 +495,8 @@ handle_nullreq(FILE *f) {
 	/* We no longer need the gss context */
 	gss_delete_sec_context(&ignore_min_stat, &ctx, &ignore_out_tok);
 
-	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime);
+	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime,
+			hostbased_name);
 continue_needed:
 	send_response(f, &in_handle, &in_tok, maj_stat, min_stat,
 			&out_handle, &out_tok);
@@ -428,6 +505,9 @@ out:
 		free(ctx_token.value);
 	if (out_tok.value != NULL)
 		gss_release_buffer(&ignore_min_stat, &out_tok);
+	if (client_name)
+		gss_release_name(&ignore_min_stat, &client_name);
+	free(hostbased_name);
 	printerr(1, "finished handling null request\n");
 	return;
 

