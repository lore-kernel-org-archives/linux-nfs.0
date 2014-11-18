Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775AbaKROGq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 09:06:46 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jDo023041
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:46 -0500
Received: from bcodding-csb.redhat.com (vpn-60-200.rdu2.redhat.com [10.10.60.200])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6iSG022959
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] mount.nfs: Add struct nfs_version and generalize version parsing
Date: Tue, 18 Nov 2014 09:06:42 -0500
Message-Id: <8e68ceb83e4e65c2e25743e11b836417e7fd808d.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs_version needs to carry major, minor, and basic mode information to
allow decisions to be made to override, discard, or negotiate various
versions.  Update nfs_nfs_version() to work against this struct and set the
various modes.  This change also makes nfs_nfs_version() parse properly
for future version number additions.

The general rules for version.v_mode are
 - not set             V_DEFAULT
 - single digit => 4   V_GENERAL
 - single digit < 4    V_SPECIFIC
 - decimal included    V_SPECIFIC
 - miss all others     V_PARSE_ERR

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/configfile.c |    2 +-
 utils/mount/network.c    |  122 ++++++++++++++++++++++-----------------------
 utils/mount/network.h    |   15 +++++-
 utils/mount/nfsumount.c  |    4 +-
 utils/mount/stropts.c    |   22 ++++----
 5 files changed, 88 insertions(+), 77 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 39d3741..a0072f1 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -258,7 +258,7 @@ check_vers(char *mopt, char *field)
 	return 0;
 }
 
-unsigned long config_default_vers;
+struct nfs_version config_default_vers;
 unsigned long config_default_proto;
 extern sa_family_t config_default_family;
 
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
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 2d72d5b..faa77cf 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -88,7 +88,7 @@ struct nfsmount_info {
 	struct mount_options	*options;	/* parsed mount options */
 	char			**extra_opts;	/* string for /etc/mtab */
 
-	unsigned long		version;	/* NFS version */
+	struct nfs_version	version;	/* NFS version */
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
 				child;		/* forked bg child? */
@@ -99,13 +99,13 @@ static void nfs_default_version(struct nfsmount_info *mi);
 
 static void nfs_default_version(struct nfsmount_info *mi)
 {
-	extern unsigned long config_default_vers;
+	extern struct nfs_version config_default_vers;
 	/*
 	 * Use the default value set in the config file when
 	 * the version has not been explicitly set.
 	 */
-	if (mi->version == 0 && config_default_vers) {
-		if (config_default_vers < 4)
+	if (mi->version.major == 0 && config_default_vers.major) {
+		if (config_default_vers.major < 4)
 			mi->version = config_default_vers;
 	}
 }
@@ -300,7 +300,7 @@ static int nfs_set_version(struct nfsmount_info *mi)
 		return 0;
 
 	if (strncmp(mi->type, "nfs4", 4) == 0)
-		mi->version = 4;
+		mi->version.major = 4;
 
 	/*
 	 * Before 2.6.32, the kernel NFS client didn't
@@ -308,20 +308,20 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	 * 4 cannot be included when autonegotiating
 	 * while running on those kernels.
 	 */
-	if (mi->version == 0 &&
+	if (mi->version.major == 0 &&
 	    linux_version_code() <= MAKE_VERSION(2, 6, 31))
-		mi->version = 3;
+		mi->version.major = 3;
 
 	/*
 	 * If we still don't know, check for version-specific
 	 * mount options.
 	 */
-	if (mi->version == 0) {
+	if (mi->version.major == 0) {
 		if (po_contains(mi->options, "mounthost") ||
 		    po_contains(mi->options, "mountaddr") ||
 		    po_contains(mi->options, "mountvers") ||
 		    po_contains(mi->options, "mountproto"))
-			mi->version = 3;
+			mi->version.major = 3;
 	}
 
 	/*
@@ -691,7 +691,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 		return result;
 	}
 
-	if (mi->version == 0) {
+	if (mi->version.major == 0) {
 		if (po_contains(options, "mounthost") ||
 			po_contains(options, "mountaddr") ||
 			po_contains(options, "mountvers") ||
@@ -839,7 +839,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 {
 	int result = 0;
 
-	switch (mi->version) {
+	switch (mi->version.major) {
 	case 0:
 		result = nfs_autonegotiate(mi);
 		break;
-- 
1.7.1

