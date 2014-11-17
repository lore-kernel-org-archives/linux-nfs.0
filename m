Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbaKQTnI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 14:43:08 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAHJh8oG029052
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 14:43:08 -0500
Received: from bcodding-csb.redhat.com (vpn-61-110.rdu2.redhat.com [10.10.61.110])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAHJh70J014339
	for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 14:43:07 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] mount.nfs: configurable minor version defaults
Date: Mon, 17 Nov 2014 14:43:07 -0500
Message-Id: <f42187317b088e355161c3e2b9ea32c5f8afd914.1416253354.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update nfsmount.conf to allow minor version specification, and rearrange
the autonegotiation logic to agreed upon best behavior.  Depending upon the
combination of values specified within nfsmount.conf and given to mount.nfs,
the retry behavior of mount.nfs varies according to the general rule of
defaulting to the most specific setting, with some exceptions.  A general
guide to the expected behavior follows:

┌────────────────┐
│ nfsmount.conf  ├──────────────┬───────────────────┐
│ Defaultvers=   │  arg option  │     attempts:     │
├────────────────┼──────────────┼───────────────────┤
│     4.2        │  not set     │ v4.2 v4.1 v4.0 v3 │
│     4.2        │   v4         │ v4.2 v4.1 v4.0    │
│     4.1        │  not set     │      v4.1 v4.0 v3 │
│     4.1        │   v4         │      v4.1 v4.0    │
│     4          │  not set     │           v4.0 v3 │
│     4          │   v4         │           v4.0    │
│     3          │  not set     │                v3 │
│    any set     │   v4.2       │ v4.2              │
│    any set     │   v4.1       │      v4.1         │
│    any set     │   v4         │           v4.0    │
│    any set     │   v3         │                v3 │
│    not set     │  not set     │           v4.0 v3 │
└────────────────┴──────────────┴───────────────────┘

If built without --enable-mountconfig, then the behavior is the same as if
nfsmount.conf did not set Defaultvers.

The last case in the above table is a special case of disagreement about how
to determine the upper bound for a minor number of the v4 protocol.  It
could be argued that mount.nfs should start at the highest available
protocol version, if that version could be discovered at mount time.  For
now, the upper bound on the value can be modified by setting the values
within nfs_default_version().

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/configfile.c |   36 +-----------
 utils/mount/network.c    |  122 +++++++++++++++++++--------------------
 utils/mount/network.h    |   15 +++++-
 utils/mount/nfsumount.c  |    4 +-
 utils/mount/parse_opt.c  |   26 ++++++++-
 utils/mount/parse_opt.h  |    2 +
 utils/mount/stropts.c    |  144 ++++++++++++++++++++++++++++++----------------
 7 files changed, 199 insertions(+), 150 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 39d3741..0a4cc04 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -228,37 +228,8 @@ void free_all(void)
 		free(entry);
 	}
 }
-static char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
-static int 
-check_vers(char *mopt, char *field)
-{
-	int i, found=0;
-
-	/*
-	 * First check to see if the config setting is one 
-	 * of the many version settings
-	 */
-	for (i=0; versions[i]; i++) { 
-		if (strcasestr(field, versions[i]) != NULL) {
-			found++;
-			break;
-		}
-	}
-	if (!found)
-		return 0;
-	/*
-	 * It appears the version is being set, now see
-	 * if the version appears on the command 
-	 */
-	for (i=0; versions[i]; i++)  {
-		if (strcasestr(mopt, versions[i]) != NULL)
-			return 1;
-	}
-
-	return 0;
-}
 
-unsigned long config_default_vers;
+struct nfs_version config_default_vers;
 unsigned long config_default_proto;
 extern sa_family_t config_default_family;
 
@@ -331,11 +302,6 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 		snprintf(buf, BUFSIZ, "%s=", node->field);
 		if (opts && strcasestr(opts, buf) != NULL)
 			continue;
-		/* 
-		 * Protocol verions can be set in a number of ways
-		 */
-		if (opts && check_vers(opts, node->field))
-			continue;
 
 		if (lookup_entry(node->field) != NULL)
 			continue;
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 4f8c15c..b5ed850 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -92,9 +92,6 @@ static const char *nfs_version_opttbl[] = {
 	"v4",
 	"vers",
 	"nfsvers",
-	"v4.0",
-	"v4.1",
-	"v4.2",
 	NULL,
 };
 
@@ -1242,71 +1239,69 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
  * or FALSE if the option was specified with an invalid value.
  */
 int
-nfs_nfs_version(struct mount_options *options, unsigned long *version)
+nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
 {
-	long tmp;
+	char *version_key, *version_val, *cptr;
+	int i, found = 0;
 
-	switch (po_rightmost(options, nfs_version_opttbl)) {
-	case 0:	/* v2 */
-		*version = 2;
-		return 1;
-	case 1: /* v3 */
-		*version = 3;
-		return 1;
-	case 2: /* v4 */
-		*version = 4;
-		return 1;
-	case 3:	/* vers */
-		switch (po_get_numeric(options, "vers", &tmp)) {
-		case PO_FOUND:
-			if (tmp >= 2 && tmp <= 4) {
-				*version = tmp;
-				return 1;
-			}
-			nfs_error(_("%s: parsing error on 'vers=' option\n"),
-					progname);
-			return 0;
-		case PO_NOT_FOUND:
-			nfs_error(_("%s: parsing error on 'vers=' option\n"),
-					progname);
-			return 0;
-		case PO_BAD_VALUE:
-			nfs_error(_("%s: invalid value for 'vers=' option"),
-					progname);
-			return 0;
-		}
-	case 4: /* nfsvers */
-		switch (po_get_numeric(options, "nfsvers", &tmp)) {
-		case PO_FOUND:
-			if (tmp >= 2 && tmp <= 4) {
-				*version = tmp;
-				return 1;
-			}
-			nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
-					progname);
-			return 0;
-		case PO_NOT_FOUND:
-			nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
-					progname);
-			return 0;
-		case PO_BAD_VALUE:
-			nfs_error(_("%s: invalid value for 'nfsvers=' option"),
-					progname);
-			return 0;
+	version->v_mode = V_DEFAULT;
+
+	for (i = 0; nfs_version_opttbl[i]; i++) {
+		if (po_contains_prefix(options, nfs_version_opttbl[i],
+								&version_key) == PO_FOUND) {
+			found++;
+			break;
 		}
-	case 5: /* v4.0 */
-	case 6: /* v4.1 */
-	case 7: /* v4.2 */
-		*version = 4;
+	}
+
+	if (!found)
 		return 1;
+
+	if (i <= 2 ) {
+		/* v2, v3, v4 */
+		version_val = version_key + 1;
+		version->v_mode = V_SPECIFIC;
+	} else if (i > 2 ) {
+		/* vers=, nfsvers= */
+		version_val = po_get(options, version_key);
 	}
 
-	/*
-	 * NFS version wasn't specified.  The pmap version value
-	 * will be filled in later by an rpcbind query in this case.
-	 */
-	*version = 0;
+	if (!version_val)
+		goto ret_error;
+
+	if (!(version->major = strtol(version_val, &cptr, 10)))
+		goto ret_error;
+
+	if (version->major < 4)
+		version->v_mode = V_SPECIFIC;
+
+	if (*cptr == '.') {
+		version_val = ++cptr;
+		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
+			goto ret_error;
+		version->v_mode = V_SPECIFIC;
+	} else if (version->major > 3 && *cptr == '\0')
+		version->v_mode = V_GENERAL;
+
+	if (*cptr != '\0')
+		goto ret_error;
+
 	return 1;
+
+ret_error:
+	if (i <= 2 ) {
+		nfs_error(_("%s: parsing error on 'v' option"),
+			progname);
+	} else if (i == 3 ) {
+		nfs_error(_("%s: parsing error on 'vers=' option"),
+			progname);
+	} else if (i == 4) {
+		nfs_error(_("%s: parsing error on 'nfsvers=' option"),
+			progname);
+	}
+	version->v_mode = V_PARSE_ERR;
+	errno = EINVAL;
+	return 0;
 }
 
 /*
@@ -1625,10 +1620,13 @@ out_err:
 int nfs_options2pmap(struct mount_options *options,
 		     struct pmap *nfs_pmap, struct pmap *mnt_pmap)
 {
+	struct nfs_version version;
+
 	if (!nfs_nfs_program(options, &nfs_pmap->pm_prog))
 		return 0;
-	if (!nfs_nfs_version(options, &nfs_pmap->pm_vers))
+	if (!nfs_nfs_version(options, &version))
 		return 0;
+	nfs_pmap->pm_vers = version.major;
 	if (!nfs_nfs_protocol(options, &nfs_pmap->pm_prot))
 		return 0;
 	if (!nfs_nfs_port(options, &nfs_pmap->pm_port))
diff --git a/utils/mount/network.h b/utils/mount/network.h
index d7636d7..9cc5dec 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -57,9 +57,22 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
 
 struct mount_options;
 
+enum {
+	V_DEFAULT = 0,
+	V_GENERAL,
+	V_SPECIFIC,
+	V_PARSE_ERR,
+};
+
+struct nfs_version {
+	unsigned long major;
+	unsigned long minor;
+	int v_mode;
+};
+
 int nfs_nfs_proto_family(struct mount_options *options, sa_family_t *family);
 int nfs_mount_proto_family(struct mount_options *options, sa_family_t *family);
-int nfs_nfs_version(struct mount_options *options, unsigned long *version);
+int nfs_nfs_version(struct mount_options *options, struct nfs_version *version);
 int  nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol);
 
 int nfs_options2pmap(struct mount_options *,
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 3538d88..de284f2 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -179,10 +179,10 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
 
 		options = po_split(pmc->m.mnt_opts);
 		if (options != NULL) {
-			unsigned long version;
+			struct nfs_version version;
 			int rc = nfs_nfs_version(options, &version);
 			po_destroy(options);
-			if (rc && version == 4)
+			if (rc && version.major == 4)
 				goto out_nfs4;
 		}
 
diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index 75a0daa..7ba61c4 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -391,7 +391,7 @@ po_return_t po_append(struct mount_options *options, char *str)
 }
 
 /**
- * po_contains - check for presense of an option in a group
+ * po_contains - check for presence of an option in a group
  * @options: pointer to mount options
  * @keyword: pointer to a C string containing option keyword for which to search
  *
@@ -410,6 +410,30 @@ po_found_t po_contains(struct mount_options *options, char *keyword)
 }
 
 /**
+ * po_contains_prefix - check for presence of an option matching a prefix
+ * @options: pointer to mount options
+ * @prefix: pointer to prefix to match against a keyword
+ * @keyword: pointer to a C string containing the option keyword if found
+ *
+ * On success, *keyword contains the pointer of the matching option's keyword.
+ */
+po_found_t po_contains_prefix(struct mount_options *options,
+								const char *prefix, char **keyword)
+{
+	struct mount_option *option;
+
+	if (options && prefix) {
+		for (option = options->head; option; option = option->next)
+			if (strncmp(option->keyword, prefix, strlen(prefix)) == 0) {
+				*keyword = option->keyword;
+				return PO_FOUND;
+			}
+	}
+
+	return PO_NOT_FOUND;
+}
+
+/**
  * po_get - return the value of the rightmost instance of an option
  * @options: pointer to mount options
  * @keyword: pointer to a C string containing option keyword for which to search
diff --git a/utils/mount/parse_opt.h b/utils/mount/parse_opt.h
index 5037207..0745e0f 100644
--- a/utils/mount/parse_opt.h
+++ b/utils/mount/parse_opt.h
@@ -45,6 +45,8 @@ po_return_t		po_join(struct mount_options *, char **);
 
 po_return_t		po_append(struct mount_options *, char *);
 po_found_t		po_contains(struct mount_options *, char *);
+po_found_t		po_contains_prefix(struct mount_options *options,
+						const char *prefix, char **keyword);
 char *			po_get(struct mount_options *, char *);
 po_found_t		po_get_numeric(struct mount_options *,
 					char *, long *);
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 2d72d5b..936f65c 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -88,30 +88,44 @@ struct nfsmount_info {
 	struct mount_options	*options;	/* parsed mount options */
 	char			**extra_opts;	/* string for /etc/mtab */
 
-	unsigned long		version;	/* NFS version */
+	struct nfs_version	version;	/* NFS version */
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
 				child;		/* forked bg child? */
 };
 
-#ifdef MOUNT_CONFIG
-static void nfs_default_version(struct nfsmount_info *mi);
 
 static void nfs_default_version(struct nfsmount_info *mi)
 {
-	extern unsigned long config_default_vers;
+#ifdef MOUNT_CONFIG
+	extern struct nfs_version config_default_vers;
 	/*
 	 * Use the default value set in the config file when
 	 * the version has not been explicitly set.
 	 */
-	if (mi->version == 0 && config_default_vers) {
-		if (config_default_vers < 4)
-			mi->version = config_default_vers;
+	if (config_default_vers.v_mode == V_PARSE_ERR) {
+		mi->version.v_mode = V_PARSE_ERR;
+		return;
 	}
-}
-#else
-inline void nfs_default_version(__attribute__ ((unused)) struct nfsmount_info *mi) {}
+
+	if (mi->version.v_mode == V_DEFAULT &&
+		config_default_vers.v_mode != V_DEFAULT) {
+		mi->version.major = config_default_vers.major;
+		mi->version.minor = config_default_vers.minor;
+		return;
+	}
+
+	if (mi->version.v_mode == V_GENERAL &&
+		config_default_vers.v_mode != V_DEFAULT) {
+		if (mi->version.major == config_default_vers.major)
+			mi->version.minor = config_default_vers.minor;
+		return;
+	}
+
 #endif /* MOUNT_CONFIG */
+	mi->version.major = 4;
+	mi->version.minor = 0;
+}
 
 /*
  * Obtain a retry timeout value based on the value of the "retry=" option.
@@ -300,7 +314,7 @@ static int nfs_set_version(struct nfsmount_info *mi)
 		return 0;
 
 	if (strncmp(mi->type, "nfs4", 4) == 0)
-		mi->version = 4;
+		mi->version.major = 4;
 
 	/*
 	 * Before 2.6.32, the kernel NFS client didn't
@@ -308,28 +322,44 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	 * 4 cannot be included when autonegotiating
 	 * while running on those kernels.
 	 */
-	if (mi->version == 0 &&
-	    linux_version_code() <= MAKE_VERSION(2, 6, 31))
-		mi->version = 3;
+	if (mi->version.v_mode == V_DEFAULT &&
+	    linux_version_code() <= MAKE_VERSION(2, 6, 31)) {
+		mi->version.major = 3;
+		mi->version.v_mode = V_SPECIFIC;
+	}
 
 	/*
 	 * If we still don't know, check for version-specific
 	 * mount options.
 	 */
-	if (mi->version == 0) {
+	if (mi->version.v_mode == V_DEFAULT) {
 		if (po_contains(mi->options, "mounthost") ||
 		    po_contains(mi->options, "mountaddr") ||
 		    po_contains(mi->options, "mountvers") ||
-		    po_contains(mi->options, "mountproto"))
-			mi->version = 3;
+		    po_contains(mi->options, "mountproto")) {
+			mi->version.major = 3;
+			mi->version.v_mode = V_SPECIFIC;
+		}
 	}
 
 	/*
 	 * If enabled, see if the default version was
 	 * set in the config file
 	 */
-	nfs_default_version(mi);
-	
+	if (mi->version.v_mode != V_SPECIFIC) {
+		nfs_default_version(mi);
+		/*
+		 * If the version was not specifically set, it will
+		 * be set by autonegotiation later, so remove it now:
+		 */
+		po_remove_all(mi->options, "v4");
+		po_remove_all(mi->options, "vers");
+		po_remove_all(mi->options, "nfsvers");
+	}
+
+	if (mi->version.v_mode == V_PARSE_ERR)
+		return 0;
+
 	return 1;
 }
 
@@ -684,6 +714,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 {
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
+	char version_opt[16];
 	char *extra_opts = NULL;
 
 	if (!options) {
@@ -691,20 +722,24 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 		return result;
 	}
 
-	if (mi->version == 0) {
-		if (po_contains(options, "mounthost") ||
-			po_contains(options, "mountaddr") ||
-			po_contains(options, "mountvers") ||
-			po_contains(options, "mountproto")) {
-		/*
-		 * Since these mountd options are set assume version 3
-		 * is wanted so error out with EPROTONOSUPPORT so the
-		 * protocol negation starts with v3.
-		 */
-			errno = EPROTONOSUPPORT;
-			goto out_fail;
-		}
-		if (po_append(options, "vers=4") == PO_FAILED) {
+	if (po_contains(options, "mounthost") ||
+		po_contains(options, "mountaddr") ||
+		po_contains(options, "mountvers") ||
+		po_contains(options, "mountproto")) {
+	/*
+	 * Since these mountd options are set assume version 3
+	 * is wanted so error out with EPROTONOSUPPORT so the
+	 * protocol negation starts with v3.
+	 */
+		errno = EPROTONOSUPPORT;
+		goto out_fail;
+	}
+
+	if (mi->version.v_mode != V_SPECIFIC) {
+		snprintf(version_opt, sizeof(version_opt) - 1,
+			"vers=%lu.%lu", mi->version.major, mi->version.minor);
+
+		if (po_append(options, version_opt) == PO_FAILED) {
 			errno = EINVAL;
 			goto out_fail;
 		}
@@ -792,14 +827,25 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
 	int result;
 
 	result = nfs_try_mount_v4(mi);
+check_result:
 	if (result)
 		return result;
 
-check_errno:
 	switch (errno) {
 	case EPROTONOSUPPORT:
 		/* A clear indication that the server or our
-		 * client does not support NFS version 4. */
+		 * client does not support NFS version 4 and minor */
+		if (mi->version.v_mode == V_GENERAL &&
+			mi->version.minor == 0)
+				return result;
+		if (mi->version.v_mode != V_SPECIFIC) {
+			if (mi->version.minor > 0) {
+				mi->version.minor--;
+				result = nfs_try_mount_v4(mi);
+				goto check_result;
+			}
+		}
+
 		goto fall_back;
 	case ENOENT:
 		/* Legacy Linux servers don't export an NFS
@@ -818,7 +864,7 @@ check_errno:
 			/* v4 server seems to be registered now. */
 			result = nfs_try_mount_v4(mi);
 			if (result == 0 && errno != ECONNREFUSED)
-				goto check_errno;
+				goto check_result;
 		}
 		return result;
 	default:
@@ -839,19 +885,19 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 {
 	int result = 0;
 
-	switch (mi->version) {
-	case 0:
-		result = nfs_autonegotiate(mi);
-		break;
-	case 2:
-	case 3:
-		result = nfs_try_mount_v3v2(mi, FALSE);
-		break;
-	case 4:
-		result = nfs_try_mount_v4(mi);
-		break;
-	default:
-		errno = EIO;
+	switch (mi->version.major) {
+		case 2:
+		case 3:
+			result = nfs_try_mount_v3v2(mi, FALSE);
+			break;
+		case 4:
+			if (mi->version.v_mode != V_SPECIFIC)
+				result = nfs_autonegotiate(mi);
+			else
+				result = nfs_try_mount_v4(mi);
+			break;
+		default:
+			errno = EIO;
 	}
 
 	return result;
-- 
1.7.1

