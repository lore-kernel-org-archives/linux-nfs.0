From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 4/8] Add new keytab handling functions for dealing
	with machine credentials
Date: Fri, 30 Mar 2007 18:32:12 -0400
Message-ID: <20070330223212.28802.35622.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdm-0000Kk-MX
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:14 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HXPdl-0005l1-RE
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:14 -0700
In-Reply-To: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Add new functions that will be used in the next patch.  The new behavior
is to search for particular keytab entries in a specified order:

root/<fqdn>@<REALM>
nfs/<fqdn>@<REALM>
host/<fqdn>@<REALM>
root/<any-name>@<REALM>
nfs/<any-name>@<REALM>
host/<any-name>@<REALM>

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/krb5_util.c |  466 ++++++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/krb5_util.h |    2 
 2 files changed, 468 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 7ef690b..20396e0 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -103,8 +103,11 @@ #include <arpa/inet.h>
 
 #include <stdio.h>
 #include <stdlib.h>
+#include <unistd.h>
 #include <string.h>
 #include <dirent.h>
+#include <netdb.h>
+#include <ctype.h>
 #include <errno.h>
 #include <time.h>
 #include <gssapi/gssapi.h>
@@ -135,6 +138,7 @@ static int gssd_have_realm_ple(void *rea
 static int gssd_process_krb5_keytab(krb5_context context, krb5_keytab kt,
 		char *kt_name);
 
+
 /*
  * Called from the scandir function to weed out potential krb5
  * credentials cache files
@@ -585,6 +589,403 @@ #else
 #endif
 }
 
+/*
+ * Given a principal, find a matching ple structure
+ */
+static struct gssd_k5_kt_princ *
+find_ple_by_princ(krb5_context context, krb5_principal princ)
+{
+	struct gssd_k5_kt_princ *ple;
+
+	for (ple = gssd_k5_kt_princ_list; ple != NULL; ple = ple->next) {
+		if (krb5_principal_compare(context, ple->princ, princ))
+			return ple;
+	}
+	/* no match found */
+	return NULL;
+}
+
+/*
+ * Create, initialize, and add a new ple structure to the global list
+ */
+static struct gssd_k5_kt_princ *
+new_ple(krb5_context context, krb5_principal princ)
+{
+	struct gssd_k5_kt_princ *ple = NULL, *p;
+	krb5_error_code code;
+	char *default_realm;
+	int is_default_realm = 0;
+
+	ple = malloc(sizeof(struct gssd_k5_kt_princ));
+	if (ple == NULL)
+		goto outerr;
+	memset(ple, 0, sizeof(*ple));
+
+#ifdef HAVE_KRB5
+	ple->realm = strndup(princ->realm.data,
+			     princ->realm.length);
+#else
+	ple->realm = strdup(princ->realm);
+#endif
+	if (ple->realm == NULL)
+		goto outerr;
+	code = krb5_copy_principal(context, princ, &ple->princ);
+	if (code)
+		goto outerr;
+
+	/*
+	 * Add new entry onto the list (if this is the default
+	 * realm, always add to the front of the list)
+	 */
+
+	code = krb5_get_default_realm(context, &default_realm);
+	if (code == 0) {
+		if (strcmp(ple->realm, default_realm) == 0)
+			is_default_realm = 1;
+		k5_free_default_realm(context, default_realm);
+	}
+
+	if (is_default_realm) {
+		ple->next = gssd_k5_kt_princ_list;
+		gssd_k5_kt_princ_list = ple;
+	} else {
+		p = gssd_k5_kt_princ_list;
+		while (p != NULL && p->next != NULL)
+			p = p->next;
+		if (p == NULL)
+			gssd_k5_kt_princ_list = ple;
+		else
+			p->next = ple;
+	}
+
+	return ple;
+outerr:
+	if (ple) {
+		if (ple->realm)
+			free(ple->realm);
+		free(ple);
+	}
+	return NULL;
+}
+
+/*
+ * Given a principal, find an existing ple structure, or create one
+ */
+static struct gssd_k5_kt_princ *
+get_ple_by_princ(krb5_context context, krb5_principal princ)
+{
+	struct gssd_k5_kt_princ *ple;
+
+	/* Need to serialize list if we ever become multi-threaded! */
+
+	ple = find_ple_by_princ(context, princ);
+	if (ple == NULL) {
+		ple = new_ple(context, princ);
+	}
+
+	return ple;
+}
+
+/*
+ * Given a (possibly unqualified) hostname,
+ * return the fully qualified (lower-case!) hostname
+ */
+static int
+get_full_hostname(const char *inhost, char *outhost, int outhostlen)
+{
+	struct addrinfo *addrs = NULL;
+	struct addrinfo hints;
+	int retval;
+	char *c;
+
+	memset(&hints, 0, sizeof(hints));
+	hints.ai_socktype = SOCK_STREAM;
+	hints.ai_family = PF_UNSPEC;
+	hints.ai_flags = AI_CANONNAME;
+
+	/* Get full target hostname */
+	retval = getaddrinfo(inhost, NULL, &hints, &addrs);
+	if (retval) {
+		printerr(0, "%s while getting full hostname for '%s'\n",
+			 gai_strerror(retval), inhost);
+		goto out;
+	}
+	strncpy(outhost, addrs->ai_canonname, outhostlen);
+	freeaddrinfo(addrs);
+	for (c = outhost; *c != '\0'; c++)
+	    *c = tolower(*c);
+
+	printerr(3, "Full hostname for '%s' is '%s'\n", inhost, outhost);
+	retval = 0;
+out:
+	return retval;
+}
+
+/* 
+ * If principal matches the given realm and service name,
+ * and has *any* instance (hostname), return 1.
+ * Otherwise return 0, indicating no match.
+ */
+static int
+realm_and_service_match(krb5_context context, krb5_principal p,
+			const char *realm, const char *service)
+{
+#ifdef HAVE_KRB5
+	/* Must have two components */
+	if (p->length != 2)
+		return 0;
+	if ((strlen(realm) == p->realm.length)
+	    && (strncmp(realm, p->realm.data, p->realm.length) == 0)
+	    && (strlen(service) == p->data[0].length)
+	    && (strncmp(service, p->data[0].data, p->data[0].length) == 0))
+		return 1;
+#else
+	const char *name, *inst;
+
+	if (p->name.name_string.len != 2)
+		return 0;
+	name = krb5_principal_get_comp_string(context, p, 0);
+	inst = krb5_principal_get_comp_string(context, p, 1);
+	if (name == NULL || inst == NULL)
+		return 0;
+	if ((strcmp(realm, p->realm) == 0)
+	    && (strcmp(service, name) == 0))
+		return 1;
+#endif
+	return 0;
+}
+
+/*
+ * Search the given keytab file looking for an entry with the given
+ * service name and realm, ignoring hostname (instance).
+ *
+ * Returns:
+ *	0 => No error
+ *	non-zero => An error occurred
+ *
+ * If a keytab entry is found, "found" is set to one, and the keytab
+ * entry is returned in "kte".  Otherwise, "found" is zero, and the
+ * value of "kte" is unpredictable.
+ */
+static int
+gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
+			const char *realm, const char *service,
+			int *found, krb5_keytab_entry *kte)
+{
+	krb5_kt_cursor cursor;
+	krb5_error_code code;
+	struct gssd_k5_kt_princ *ple;
+	int retval = -1;
+	char kt_name[BUFSIZ];
+	char *pname;
+
+	if (found == NULL) {
+		retval = EINVAL;
+		goto out;
+	}
+	*found = 0;
+
+	/*
+	 * Look through each entry in the keytab file and determine
+	 * if we might want to use it as machine credentials.  If so,
+	 * save info in the global principal list (gssd_k5_kt_princ_list).
+	 */
+	if ((code = krb5_kt_get_name(context, kt, kt_name, BUFSIZ))) {
+		printerr(0, "ERROR: %s attempting to get keytab name\n",
+			 error_message(code));
+		retval = code;
+		goto out;
+	}
+	if ((code = krb5_kt_start_seq_get(context, kt, &cursor))) {
+		printerr(0, "ERROR: %s while beginning keytab scan "
+			    "for keytab '%s'\n",
+			error_message(code), kt_name);
+		retval = code;
+		goto out;
+	}
+
+	while ((code = krb5_kt_next_entry(context, kt, kte, &cursor)) == 0) {
+		if ((code = krb5_unparse_name(context, kte->principal,
+					      &pname))) {
+			printerr(0, "WARNING: Skipping keytab entry because "
+				 "we failed to unparse principal name: %s\n",
+				 error_message(code));
+			k5_free_kt_entry(context, kte);
+			continue;
+		}
+		printerr(4, "Processing keytab entry for principal '%s'\n",
+			 pname);
+		/* Use the first matching keytab entry found */
+	        if ((realm_and_service_match(context, kte->principal, realm,
+					     service))) {
+			printerr(4, "We WILL use this entry (%s)\n", pname);
+			ple = get_ple_by_princ(context, kte->principal);
+			/*
+			 * Return, don't free, keytab entry if
+			 * we were successful!
+			 */
+			if (ple == NULL) {
+				retval = ENOMEM;
+				k5_free_kt_entry(context, kte);
+			} else {
+				retval = 0;
+				*found = 1;
+			}
+			k5_free_unparsed_name(context, pname);
+			break;
+		}
+		else {
+			printerr(4, "We will NOT use this entry (%s)\n",
+				pname);
+		}
+		k5_free_unparsed_name(context, pname);
+		k5_free_kt_entry(context, kte);
+	}
+
+	if ((code = krb5_kt_end_seq_get(context, kt, &cursor))) {
+		printerr(0, "WARNING: %s while ending keytab scan for "
+			    "keytab '%s'\n",
+			 error_message(code), kt_name);
+	}
+
+	retval = 0;
+  out:
+	return retval;
+}
+
+/*
+ * Find a keytab entry to use for a given target hostname.
+ * Tries to find the most appropriate keytab to use given the
+ * name of the host we are trying to connect with.
+ */
+static int
+find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
+		  krb5_keytab_entry *kte)
+{
+	krb5_error_code code;
+	const char *svcnames[] = { "root", "nfs", "host", NULL };
+	char **realmnames = NULL;
+	char myhostname[NI_MAXHOST], targethostname[NI_MAXHOST];
+	int i, j, retval;
+	char *default_realm = NULL;
+	char *realm;
+	int tried_all = 0, tried_default = 0;
+	krb5_principal princ;
+
+
+	/* Get full target hostname */
+	retval = get_full_hostname(hostname, targethostname,
+				   sizeof(targethostname));
+	if (retval)
+		goto out;
+
+	/* Get full local hostname */
+	retval = gethostname(myhostname, sizeof(myhostname));
+	if (retval) {
+		printerr(1, "%s while getting local hostname\n",
+			 error_message(retval));
+		goto out;
+	}
+	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
+	if (retval)
+		goto out;
+
+	code = krb5_get_default_realm(context, &default_realm);
+	if (code) {
+		retval = code;
+		printerr(1, "%s while getting default realm name\n",
+			 error_message(code));
+		goto out;
+	}
+
+	/*
+	 * Get the realm name(s) for the target hostname.
+	 * In reality, this function currently only returns a
+	 * single realm, but we code with the assumption that
+	 * someday it may actually return a list.
+	 */
+	code = krb5_get_host_realm(context, targethostname, &realmnames);
+	if (code) {
+		printerr(0, "ERROR: %s while getting realm(s) for host '%s'\n",
+			 error_message(code), targethostname);
+		retval = code;
+		goto out;
+	}
+
+	/*
+	 * Try the "appropriate" realm first, and if nothing found for that
+	 * realm, try the default realm (if it hasn't already been tried).
+	 */
+	i = 0;
+	realm = realmnames[i];
+	while (1) {
+		if (realm == NULL) {
+			tried_all = 1;
+			if (!tried_default)
+				realm = default_realm;
+		}
+		if (tried_all && tried_default)
+			break;
+		if (strcmp(realm, default_realm) == 0)
+			tried_default = 1;
+		for (j = 0; svcnames[j] != NULL; j++) {
+			code = krb5_build_principal_ext(context, &princ,
+							strlen(realm),
+							realm,
+							strlen(svcnames[j]),
+							svcnames[j],
+							strlen(myhostname),
+							myhostname,
+							NULL);
+			if (code) {
+				printerr(1, "%s while building principal for "
+					 "'%s/%s@%s'\n", error_message(code),
+					 svcnames[j], myhostname, realm);
+				continue;
+			}
+			code = krb5_kt_get_entry(context, kt, princ, 0, 0, kte);
+			krb5_free_principal(context, princ);
+			if (code) {
+				printerr(3, "%s while getting keytab entry for "
+					 "'%s/%s@%s'\n", error_message(code),
+					 svcnames[j], myhostname, realm);
+			} else {
+				printerr(3, "Success getting keytab entry for "
+					 "'%s/%s@%s'\n",
+					 svcnames[j], myhostname, realm);
+				retval = 0;
+				goto out;
+			}
+			retval = code;
+		}
+		/*
+		 * Nothing found with our hostname instance, now look for
+		 * names with any instance (they must have an instance)
+		 */
+		for (j = 0; svcnames[j] != NULL; j++) {
+			int found = 0;
+			code = gssd_search_krb5_keytab(context, kt, realm,
+						       svcnames[j], &found, kte);
+			if (!code && found) {
+				printerr(3, "Success getting keytab entry for "
+					 "%s/*@%s\n", svcnames[j], realm);
+				retval = 0;
+				goto out;
+			}
+		}
+		if (!tried_all) {
+			i++;
+			realm = realmnames[i];
+		}
+	}
+out:
+	if (default_realm)
+		k5_free_default_realm(context, default_realm);
+	if (realmnames)
+		krb5_free_host_realm(context, realmnames);
+	return retval;
+}
+
 /*==========================*/
 /*===  External routines ===*/
 /*==========================*/
@@ -836,3 +1237,68 @@ gssd_destroy_krb5_machine_creds(void)
 	krb5_free_context(context);
 }
 
+/*
+ * Obtain (or refresh if necessary) Kerberos machine credentials
+ */
+int
+gssd_refresh_krb5_machine_credential(char *hostname,
+				     struct gssd_k5_kt_princ *ple)
+{
+	krb5_error_code code = 0;
+	krb5_context context;
+	krb5_keytab kt = NULL;;
+	int retval = 0;
+
+	if (hostname == NULL && ple == NULL)
+		return EINVAL;
+
+	code = krb5_init_context(&context);
+	if (code) {
+		printerr(0, "ERROR: %s: %s while initializing krb5 context\n",
+			 __FUNCTION__, error_message(code));
+		retval = code;
+		goto out;
+	}
+
+	if ((code = krb5_kt_resolve(context, keytabfile, &kt))) {
+		printerr(0, "ERROR: %s: %s while resolving keytab '%s'\n",
+			 __FUNCTION__, error_message(code), keytabfile);
+		goto out;
+	}
+
+	if (ple == NULL) {
+		krb5_keytab_entry kte;
+
+		code = find_keytab_entry(context, kt, hostname, &kte);
+		if (code) {
+			printerr(0, "ERROR: %s: no usable keytab entry found "
+				 "in keytab %s for connection with host %s\n",
+				 __FUNCTION__, keytabfile, hostname);
+			retval = code;
+			goto out;
+		}
+
+		ple = get_ple_by_princ(context, kte.principal);
+		k5_free_kt_entry(context, &kte);
+		if (ple == NULL) {
+			char *pname;
+			if ((krb5_unparse_name(context, kte.principal, &pname))) {
+				pname = NULL;
+			}
+			printerr(0, "ERROR: %s: Could not locate or create "
+				 "ple struct for principal %s for connection "
+				 "with host %s\n",
+				 __FUNCTION__, pname ? pname : "<unparsable>",
+				 hostname);
+			if (pname) k5_free_unparsed_name(context, pname);
+			goto out;
+		}
+	}
+	retval = gssd_get_single_krb5_cred(context, kt, ple);
+out:
+	if (kt)
+		krb5_kt_close(context, kt);
+	krb5_free_context(context);
+	return retval;
+}
+
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 36dfcc8..625d53c 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -22,6 +22,8 @@ int  gssd_refresh_krb5_machine_creds(voi
 void gssd_free_krb5_machine_cred_list(char **list);
 void gssd_setup_krb5_machine_gss_ccache(char *servername);
 void gssd_destroy_krb5_machine_creds(void);
+int  gssd_refresh_krb5_machine_credential(char *hostname,
+					  struct gssd_k5_kt_princ *ple);
 
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
 int limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
