From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/3] Try to use kernel function to determine supported Kerberos
 enctypes (Updated)
Date: Thu, 15 Apr 2010 08:45:25 -0400
Message-ID: <4BC70A65.7050000@RedHat.com>
References: <1271272729-24422-1-git-send-email-steved@redhat.com> <1271272729-24422-3-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752944Ab0DOMp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 08:45:27 -0400
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o3FCjQVm022205
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 08:45:26 -0400
Received: from badhat.bos.devel.redhat.com (vpn-237-2.phx2.redhat.com [10.3.237.2])
	by int-mx05.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o3FCjPCU027261
	for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 08:45:25 -0400
In-Reply-To: <1271272729-24422-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I did notice the following problems with this patch.
 
1) I was not freeing enctypes in handle_gssd_upcall()
  
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 50a27e4..12e11d5 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -1301,7 +1301,6 @@ handle_gssd_upcall(struct clnt_info *clp)
 out:
        free(lbuf);
        free(mech);
-       free(enctypes);
        free(target);
        free(service);
        return; 

 2) gss_set_allowable_enctypes last arugment is a void *
      not a void **

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index dccbeb6..0f56b1d 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1298,10 +1298,11 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
         */
        if (krb5_enctypes == NULL)
                maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
-                                       &krb5oid, num_enctypes, enctypes);
+                                       &krb5oid, num_enctypes, &enctypes);
        else
                maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
-                                       &krb5oid, num_krb5_enctypes, krb5_enctypes);
+                                       &krb5oid, num_krb5_enctypes,
+                                       krb5_enctypes);

Here is the entire updated patch...


Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Thu Apr 15 08:10:07 2010 -0400

    gssd: move function limit_krb5_enctypes into the exported functions area
    
    cleanup: Move function limit_krb5_enctypes() from the section
    containing static functions into the section containing
    externally visible functions.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index be4fb11..50a27e4 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -600,6 +600,67 @@ update_client_list(void)
 	return retval;
 }
 
+/* Encryption types supported by the kernel rpcsec_gss code */
+int num_krb5_enctypes = 0;
+krb5_enctype *krb5_enctypes = NULL;
+
+/*
+ * Parse the supported encryption type information
+ */
+static int
+parse_enctypes(char *enctypes)
+{
+	int n = 0;
+	char *curr, *comma;
+	int i;
+	static char *cached_types;
+
+	if (cached_types && strcmp(cached_types, enctypes) == 0)
+		return 0;
+	free(cached_types);
+
+	if (krb5_enctypes != NULL) {
+		free(krb5_enctypes);
+		krb5_enctypes = NULL;
+		num_krb5_enctypes = 0;
+	}
+
+	/* count the number of commas */
+	for (curr = enctypes; curr && *curr != '\0'; curr = ++comma) {
+		comma = strchr(curr, ',');
+		if (comma != NULL)
+			n++;
+		else
+			break;
+	}
+	/* If no more commas and we're not at the end, there's one more value */
+	if (*curr != '\0')
+		n++;
+
+	/* Empty string, return an error */
+	if (n == 0)
+		return ENOENT;
+
+	/* Allocate space for enctypes array */
+	if ((krb5_enctypes = (int *) calloc(n, sizeof(int))) == NULL) {
+		return ENOMEM;
+	}
+
+	/* Now parse each value into the array */
+	for (curr = enctypes, i = 0; curr && *curr != '\0'; curr = ++comma) {
+		krb5_enctypes[i++] = atoi(curr);
+		comma = strchr(curr, ',');
+		if (comma == NULL)
+			break;
+	}
+
+	num_krb5_enctypes = n;
+	if (cached_types = malloc(strlen(enctypes)+1))
+		strcpy(cached_types, enctypes);
+
+	return 0;
+}
+
 static int
 do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	    gss_buffer_desc *context_token)
@@ -1128,11 +1189,12 @@ handle_gssd_upcall(struct clnt_info *clp)
 {
 	uid_t			uid;
 	char			*lbuf = NULL;
-	int			lbuflen = 0;
+	int			lbuflen = 0, code;
 	char			*p;
 	char			*mech = NULL;
 	char			*target = NULL;
 	char			*service = NULL;
+	char			*enctypes = NULL;
 
 	printerr(1, "handling gssd upcall (%s)\n", clp->dirname);
 
@@ -1176,6 +1238,23 @@ handle_gssd_upcall(struct clnt_info *clp)
 		goto out;
 	}
 
+	/* read supported encryption types if supplied */
+	if ((p = strstr(lbuf, "enctypes=")) != NULL) {
+		enctypes = malloc(lbuflen);
+		if (!enctypes)
+			goto out;
+		if (sscanf(p, "enctypes=%s", enctypes) != 1) {
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				    "failed to parse target name "
+				    "in upcall string '%s'\n", lbuf);
+			goto out;
+		}
+		if (parse_enctypes(enctypes) != 0) {
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				"parsing encryption types failed: errno %d\n", code);
+		}
+	}
+
 	/* read target name */
 	if ((p = strstr(lbuf, "target=")) != NULL) {
 		target = malloc(lbuflen);
@@ -1222,6 +1301,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 out:
 	free(lbuf);
 	free(mech);
+	free(enctypes);
 	free(target);
 	free(service);
 	return;	
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 1c10bd4..dccbeb6 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1274,6 +1274,8 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
 				    ENCTYPE_DES_CBC_MD5,
 				    ENCTYPE_DES_CBC_MD4 };
 	int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
+	extern int num_krb5_enctypes;
+	extern krb5_enctype *krb5_enctypes;
 
 	/* We only care about getting a krb5 cred */
 	desired_mechs.count = 1;
@@ -1290,8 +1292,17 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
 		return -1;
 	}
 
-	maj_stat = gss_set_allowable_enctypes(&min_stat, credh, &krb5oid,
-					     num_enctypes, &enctypes);
+	/*
+	 * If we failed for any reason to produce global
+	 * list of supported enctypes, use local default here.
+	 */
+	if (krb5_enctypes == NULL)
+		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
+					&krb5oid, num_enctypes, enctypes);
+	else
+		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
+					&krb5oid, num_krb5_enctypes, krb5_enctypes);
+
 	if (maj_stat != GSS_S_COMPLETE) {
 		pgsserr("gss_set_allowable_enctypes",
 			maj_stat, min_stat, &krb5oid);

