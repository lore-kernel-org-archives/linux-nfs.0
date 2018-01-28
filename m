Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:53308 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752024AbeA1SfU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jan 2018 13:35:20 -0500
Received: by mail-it0-f68.google.com with SMTP id b5so5754410itc.3
        for <linux-nfs@vger.kernel.org>; Sun, 28 Jan 2018 10:35:20 -0800 (PST)
Received: from manet.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s99sm3059569ioe.63.2018.01.28.10.35.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jan 2018 10:35:18 -0800 (PST)
Subject: [PATCH v3 3/3] Add LDAP-free 'nfsref' command
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Sun, 28 Jan 2018 13:35:18 -0500
Message-ID: <20180128183518.3092.81633.stgit@manet.1015granger.net>
In-Reply-To: <20180128183357.3092.38903.stgit@manet.1015granger.net>
References: <20180128183357.3092.38903.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 'nfsref' command administers junctions. On an NFS server, it
can create new junctions, remove existing junctions, or display
the contents of junctions.

A man page with more details is included.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 configure.ac             |    1 
 utils/Makefile.am        |    4 +
 utils/nfsref/Makefile.am |   39 +++++++
 utils/nfsref/add.c       |  271 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsref/lookup.c    |  211 ++++++++++++++++++++++++++++++++++++
 utils/nfsref/nfsref.c    |  188 ++++++++++++++++++++++++++++++++
 utils/nfsref/nfsref.h    |   47 ++++++++
 utils/nfsref/nfsref.man  |  180 +++++++++++++++++++++++++++++++
 utils/nfsref/remove.c    |  145 +++++++++++++++++++++++++
 9 files changed, 1086 insertions(+)
 create mode 100644 utils/nfsref/Makefile.am
 create mode 100644 utils/nfsref/add.c
 create mode 100644 utils/nfsref/lookup.c
 create mode 100644 utils/nfsref/nfsref.c
 create mode 100644 utils/nfsref/nfsref.h
 create mode 100644 utils/nfsref/nfsref.man
 create mode 100644 utils/nfsref/remove.c

diff --git a/configure.ac b/configure.ac
index d2e48a5..fba9064 100644
--- a/configure.ac
+++ b/configure.ac
@@ -601,6 +601,7 @@ AC_CONFIG_FILES([
 	utils/mount/Makefile
 	utils/mountd/Makefile
 	utils/nfsd/Makefile
+	utils/nfsref/Makefile
 	utils/nfsstat/Makefile
 	utils/nfsidmap/Makefile
 	utils/showmount/Makefile
diff --git a/utils/Makefile.am b/utils/Makefile.am
index c75a5a0..d361aea 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -23,6 +23,10 @@ if CONFIG_NFSDCLTRACK
 OPTDIRS += nfsdcltrack
 endif
 
+if CONFIG_JUNCTION
+OPTDIRS += nfsref
+endif
+
 SUBDIRS = \
 	exportfs \
 	mountd \
diff --git a/utils/nfsref/Makefile.am b/utils/nfsref/Makefile.am
new file mode 100644
index 0000000..2b2bb53
--- /dev/null
+++ b/utils/nfsref/Makefile.am
@@ -0,0 +1,39 @@
+##
+## @file utils/nfsref/Makefile.am
+## @brief Process this file with automake to produce utils/nfsref/Makefile.in
+##
+
+##
+## Copyright 2011, 2018 Oracle.  All rights reserved.
+##
+## This file is part of nfs-utils.
+##
+## nfs-utils is free software; you can redistribute it and/or modify
+## it under the terms of the GNU General Public License version 2.0 as
+## published by the Free Software Foundation.
+##
+## nfs-utils is distributed in the hope that it will be useful, but
+## WITHOUT ANY WARRANTY; without even the implied warranty of
+## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+## GNU General Public License version 2.0 for more details.
+##
+## You should have received a copy of the GNU General Public License
+## version 2.0 along with nfs-utils.  If not, see:
+##
+##	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+##
+
+noinst_HEADERS		= nfsref.h
+
+sbin_PROGRAMS		= nfsref
+nfsref_SOURCES		= add.c lookup.c nfsref.c remove.c
+LDADD			= $(LIBXML2) $(LIBCAP) \
+			  ../../support/nfs/libnfs.la \
+			  ../../support/junction/libjunction.la
+
+man8_MANS		= nfsref.man
+
+MAINTAINERCLEANFILES	= Makefile.in
+
+AM_CPPFLAGS		= -I. -I../../support/include
+##AM_LDFLAGS		= -Wl,--as-needed
diff --git a/utils/nfsref/add.c b/utils/nfsref/add.c
new file mode 100644
index 0000000..d5d0cf8
--- /dev/null
+++ b/utils/nfsref/add.c
@@ -0,0 +1,271 @@
+/**
+ * @file utils/nfsref/add.c
+ * @brief Add junction metadata to a local file system object
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <sys/stat.h>
+#include <sys/types.h>
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <errno.h>
+
+#include <uuid/uuid.h>
+
+#include "junction.h"
+#include "xlog.h"
+#include "nfsref.h"
+
+/**
+ * Default cache expiration for FSN information
+ */
+#define FSN_DEFAULT_TTL		(300)
+
+/**
+ * Display help message for "add" subcommand
+ *
+ * @param progname NUL-terminated C string containing name of program
+ * @return program exit status
+ */
+int
+nfsref_add_help(const char *progname)
+{
+	fprintf(stderr, " \n");
+
+	fprintf(stderr, "Usage: %s [ -t type ] add <junction path> "
+			"<server> <export> [ <server> <export> ... ]\n\n",
+		progname);
+
+	fprintf(stderr, "Add a new junction containing the specified list "
+			"of fileset locations.\n");
+	fprintf(stderr, "<junction path> is the filename of the new junction.  "
+			"<server> is the hostname\n");
+	fprintf(stderr, "or IP address of an NFS server where the fileset is "
+			"located.  <export> is the\n");
+	fprintf(stderr, "export pathname of the fileset on that server.\n\n");
+
+	fprintf(stderr, "For NFS basic junctions, the location list is stored "
+			"locally in the junction.\n");
+	fprintf(stderr, "For FedFS junctions, the location list is stored "
+			"as new FSN and FSL records\n");
+	fprintf(stderr, "on an NSDB.\n");
+
+	return EXIT_SUCCESS;
+}
+
+/**
+ * Fill in default settings for NFSv4.0 fs_locations4
+ *
+ * @param new NFS location structure to fill in
+ *
+ * See section 5.1.3.2 of the NSDB protocol draft.
+ */
+static void
+nfsref_add_fsloc_defaults(struct nfs_fsloc *new)
+{
+	new->nfl_hostport = 0;
+	new->nfl_flags.nfl_varsub = false;
+	new->nfl_currency = -1;
+	new->nfl_validfor = 0;
+	new->nfl_genflags.nfl_writable = false;
+	new->nfl_genflags.nfl_going = false;
+	new->nfl_genflags.nfl_split = true;
+	new->nfl_transflags.nfl_rdma = true;
+	new->nfl_info.nfl_simul = 0;
+	new->nfl_info.nfl_handle = 0;
+	new->nfl_info.nfl_fileid = 0;
+	new->nfl_info.nfl_writever = 0;
+	new->nfl_info.nfl_change = 0;
+	new->nfl_info.nfl_readdir = 0;
+	new->nfl_info.nfl_readrank = 0;
+	new->nfl_info.nfl_readorder = 0;
+	new->nfl_info.nfl_writerank = 0;
+	new->nfl_info.nfl_writeorder = 0;
+}
+
+/**
+ * Convert a pair of command line arguments to one nfs_fsloc structure
+ *
+ * @param server NUL-terminated C string containing file server hostname
+ * @param rootpath NUL-terminated C string containing POSIX-style export path
+ * @param fsloc OUT: NFS location structure
+ * @return a FedFsStatus code
+ *
+ * If nfsref_add_build_fsloc() returns FEDFS_OK, caller must free the
+ * returned fsloc with nfs_free_location().
+ */
+static FedFsStatus
+nfsref_add_build_fsloc(const char *server, const char *rootpath,
+		struct nfs_fsloc **fsloc)
+{
+	struct nfs_fsloc *new;
+	FedFsStatus retval;
+
+	if (server == NULL || rootpath == NULL)
+		return FEDFS_ERR_INVAL;
+
+	xlog(D_GENERAL, "%s: Building fsloc for %s:%s",
+		__func__, server, rootpath);
+
+	new = nfs_new_location();
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: No memory", __func__);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	new->nfl_hostname = strdup(server);
+	if (new->nfl_hostname == NULL) {
+		nfs_free_location(new);
+		xlog(D_GENERAL, "%s: No memory", __func__);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	retval = nsdb_posix_to_path_array(rootpath, &new->nfl_rootpath);
+	if (retval != FEDFS_OK) {
+		nfs_free_location(new);
+		return retval;
+	}
+
+	nfsref_add_fsloc_defaults(new);
+	*fsloc = new;
+	return FEDFS_OK;
+}
+
+/**
+ * Convert array of command line arguments to list of nfs_fsloc structures
+ *
+ * @param argv array of pointers to NUL-terminated C strings contains arguments
+ * @param optind index of "argv" where "add" subcommand arguments start
+ * @param fslocs OUT: list of NFS locations
+ * @return a FedFsStatus code
+ *
+ * If nfsref_add_build_fsloc_list() returns FEDFS_OK, caller must free the
+ * returned list of fslocs with nfs_free_locations().
+ */
+static FedFsStatus
+nfsref_add_build_fsloc_list(char **argv, int optind, struct nfs_fsloc **fslocs)
+{
+	struct nfs_fsloc *fsloc, *result = NULL;
+	FedFsStatus retval;
+	int i;
+
+	for (i = optind + 2; argv[i] != NULL; i += 2) {
+		retval = nfsref_add_build_fsloc(argv[i], argv[i + 1], &fsloc);
+		if (retval != FEDFS_OK) {
+			nfs_free_locations(result);
+			return retval;
+		}
+		if (result == NULL)
+			result = fsloc;
+		else
+			result->nfl_next = fsloc;
+	}
+	if (result == NULL)
+		return FEDFS_ERR_INVAL;
+
+	*fslocs = result;
+	return FEDFS_OK;
+}
+
+/**
+ * Add NFS locations to a junction
+ *
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @param argv array of pointers to NUL-terminated C strings contains arguments
+ * @param optind index of "argv" where "add" subcommand arguments start
+ * @return program exit status
+ */
+static int
+nfsref_add_nfs_basic(const char *junct_path, char **argv, int optind)
+{
+	struct nfs_fsloc *fslocs = NULL;
+	FedFsStatus retval;
+
+	xlog(D_GENERAL, "%s: Adding basic junction to %s",
+		__func__, junct_path);
+
+	retval = nfsref_add_build_fsloc_list(argv, optind, &fslocs);
+	switch (retval) {
+	case FEDFS_OK:
+		break;
+	case FEDFS_ERR_INVAL:
+		xlog(L_ERROR, "Missing arguments");
+		return EXIT_FAILURE;
+	case FEDFS_ERR_SVRFAULT:
+		xlog(L_ERROR, "No memory");
+		return EXIT_FAILURE;
+	default:
+		xlog(L_ERROR, "Failed to add NFS location metadata to %s: %s",
+			junct_path, nsdb_display_fedfsstatus(retval));
+		return EXIT_FAILURE;
+	}
+
+	retval = nfs_add_junction(junct_path, fslocs);
+	nfs_free_locations(fslocs);
+	switch (retval) {
+	case FEDFS_OK:
+		break;
+	case FEDFS_ERR_EXIST:
+		xlog(L_ERROR, "%s already contains junction metadata",
+			junct_path);
+		return EXIT_FAILURE;
+	default:
+		xlog(L_ERROR, "Failed to add NFS location metadata to %s: %s",
+			junct_path, nsdb_display_fedfsstatus(retval));
+		return EXIT_FAILURE;
+	}
+
+	printf("Created junction %s\n", junct_path);
+	return EXIT_SUCCESS;
+}
+
+/**
+ * Add locations to a junction
+ *
+ * @param type type of junction to add
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @param argv array of pointers to NUL-terminated C strings contains arguments
+ * @param optind index of "argv" where "add" subcommand arguments start
+ * @return program exit status
+ */
+int
+nfsref_add(enum nfsref_type type, const char *junct_path, char **argv, int optind)
+{
+	if (mkdir(junct_path, 0755) == -1)
+		if (errno != EEXIST) {
+			xlog(L_ERROR, "Failed to create junction object: %m");
+			return EXIT_FAILURE;
+		}
+
+	switch (type) {
+	case NFSREF_TYPE_UNSPECIFIED:
+	case NFSREF_TYPE_NFS_BASIC:
+		return nfsref_add_nfs_basic(junct_path, argv, optind);
+	default:
+		xlog(L_ERROR, "Unrecognized junction type");
+	}
+	return EXIT_FAILURE;
+}
diff --git a/utils/nfsref/lookup.c b/utils/nfsref/lookup.c
new file mode 100644
index 0000000..16fca2e
--- /dev/null
+++ b/utils/nfsref/lookup.c
@@ -0,0 +1,211 @@
+/**
+ * @file utils/nfsref/lookup.c
+ * @brief Examine junction metadata from a local file system object
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <stdint.h>
+#include <stdbool.h>
+#include <stdlib.h>
+#include <stdio.h>
+
+#include <rpcsvc/nfs_prot.h>
+
+#include "junction.h"
+#include "xlog.h"
+#include "nfsref.h"
+
+/**
+ * Display help message for "lookup" subcommand
+ *
+ * @param progname NUL-terminated C string containing name of program
+ * @return program exit status
+ */
+int
+nfsref_lookup_help(const char *progname)
+{
+	fprintf(stderr, " \n");
+
+	fprintf(stderr, "Usage: %s [ -t type ] lookup <junction path>\n\n",
+		progname);
+
+	fprintf(stderr, "Display the contents of the junction at "
+			"<junction path>.  For NFS basic\n");
+	fprintf(stderr, "junctions, the local contents of the junction "
+			"are displayed.  For FedFS\n");
+	fprintf(stderr, "junctions, FSL records are retrieved from the "
+			"NSDB and displayed.\n");
+
+	return EXIT_SUCCESS;
+}
+
+/**
+ * Convert a boolean value into a displayable string constant
+ *
+ * @param value boolean value
+ * @return NUL-terminated static constant C string
+ */
+static const char *
+nfsref_lookup_display_boolean(_Bool value)
+{
+	return value ? "true" : "false";
+}
+
+/**
+ * Display a single NFS location
+ *
+ * @param fsloc pointer to an NFS location structure
+ */
+static void
+nfsref_lookup_display_nfs_location(struct nfs_fsloc *fsloc)
+{
+	char *rootpath;
+
+	if (nsdb_path_array_to_posix(fsloc->nfl_rootpath, &rootpath) == FEDFS_OK) {
+		printf("%s:%s\n", fsloc->nfl_hostname, rootpath);
+		free(rootpath);
+	} else
+		printf("%s: - Invalid root path -\n", fsloc->nfl_hostname);
+	printf("\n");
+
+	printf("\tNFS port:\t%u\n", fsloc->nfl_hostport);
+	printf("\tValid for:\t%d\n", fsloc->nfl_validfor);
+	printf("\tCurrency:\t%d\n", fsloc->nfl_currency);
+	printf("\tFlags:\t\tvarsub(%s)\n",
+		nfsref_lookup_display_boolean(fsloc->nfl_flags.nfl_varsub));
+
+	printf("\tGenFlags:\twritable(%s), going(%s), split(%s)\n",
+		nfsref_lookup_display_boolean(fsloc->nfl_genflags.nfl_writable),
+		nfsref_lookup_display_boolean(fsloc->nfl_genflags.nfl_going),
+		nfsref_lookup_display_boolean(fsloc->nfl_genflags.nfl_split));
+	printf("\tTransFlags:\trdma(%s)\n",
+		nfsref_lookup_display_boolean(fsloc->nfl_transflags.nfl_rdma));
+
+	printf("\tClass:\t\tsimul(%u), handle(%u), fileid(%u)\n",
+		fsloc->nfl_info.nfl_simul,
+		fsloc->nfl_info.nfl_handle,
+		fsloc->nfl_info.nfl_fileid);
+	printf("\tClass:\t\twritever(%u), change(%u), readdir(%u)\n",
+		fsloc->nfl_info.nfl_writever,
+		fsloc->nfl_info.nfl_change,
+		fsloc->nfl_info.nfl_readdir);
+	printf("\tRead:\t\trank(%u), order(%u)\n",
+		fsloc->nfl_info.nfl_readrank, fsloc->nfl_info.nfl_readorder);
+	printf("\tWrite:\t\trank(%u), order(%u)\n",
+		fsloc->nfl_info.nfl_writerank, fsloc->nfl_info.nfl_writeorder);
+
+	printf("\n");
+}
+
+/**
+ * Display a list of NFS locations
+ *
+ * @param fslocs list of NFS locations to display
+ */
+static void
+nfsref_lookup_display_nfs_locations(struct nfs_fsloc *fslocs)
+{
+	struct nfs_fsloc *fsloc;
+
+	for (fsloc = fslocs; fsloc != NULL; fsloc = fsloc->nfl_next)
+		nfsref_lookup_display_nfs_location(fsloc);
+}
+
+/**
+ * List NFS locations in an nfs-basic junction
+ *
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @return program exit status
+ */
+static int
+nfsref_lookup_nfs_basic(const char *junct_path)
+{
+	struct nfs_fsloc *fslocs = NULL;
+	FedFsStatus retval;
+
+	xlog(D_GENERAL, "%s: Looking up basic junction in %s",
+		__func__, junct_path);
+
+	retval = nfs_is_junction(junct_path);
+	switch (retval) {
+	case FEDFS_OK:
+		break;
+	case FEDFS_ERR_NOTJUNCT:
+		xlog(L_ERROR, "%s is not an nfs-basic junction", junct_path);
+		return EXIT_FAILURE;
+	default:
+		xlog(L_ERROR, "Failed to access %s: %s",
+			junct_path, nsdb_display_fedfsstatus(retval));
+		return EXIT_FAILURE;
+	}
+
+	retval = nfs_get_locations(junct_path, &fslocs);
+	if (retval != FEDFS_OK) {
+		xlog(L_ERROR, "Failed to access %s: %s",
+			junct_path, nsdb_display_fedfsstatus(retval));
+		return EXIT_FAILURE;
+	}
+
+	nfsref_lookup_display_nfs_locations(fslocs);
+
+	nfs_free_locations(fslocs);
+	return EXIT_SUCCESS;
+}
+
+/**
+ * Resolve either a FedFS or NFS basic junction
+ *
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @return program exit status
+ */
+static int
+nfsref_lookup_unspecified(const char *junct_path)
+{
+	FedFsStatus retval;
+
+	retval = nfs_is_junction(junct_path);
+	if (retval == FEDFS_OK)
+		return nfsref_lookup_nfs_basic(junct_path);
+	xlog(L_ERROR, "%s is not a junction", junct_path);
+	return EXIT_FAILURE;
+}
+
+/**
+ * Enumerate metadata of a junction
+ *
+ * @param type type of junction to add
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @return program exit status
+ */
+int
+nfsref_lookup(enum nfsref_type type, const char *junct_path)
+{
+	switch (type) {
+	case NFSREF_TYPE_UNSPECIFIED:
+		return nfsref_lookup_unspecified(junct_path);
+	case NFSREF_TYPE_NFS_BASIC:
+		return nfsref_lookup_nfs_basic(junct_path);
+	default:
+		xlog(L_ERROR, "Unrecognized junction type");
+	}
+	return EXIT_FAILURE;
+}
diff --git a/utils/nfsref/nfsref.c b/utils/nfsref/nfsref.c
new file mode 100644
index 0000000..ff7013e
--- /dev/null
+++ b/utils/nfsref/nfsref.c
@@ -0,0 +1,188 @@
+/**
+ * @file utils/nfsref/nfsref.c
+ * @brief Manage NFS referrals
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <sys/types.h>
+#include <sys/capability.h>
+#include <sys/prctl.h>
+#include <sys/stat.h>
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <getopt.h>
+#include <time.h>
+
+#include <locale.h>
+#include <langinfo.h>
+
+#include "junction.h"
+#include "xlog.h"
+#include "nfsref.h"
+
+/**
+ * Short form command line options
+ */
+static const char nfsref_opts[] = "?dt:";
+
+/**
+ * Long form command line options
+ */
+static const struct option nfsref_longopts[] = {
+	{ "debug", 0, NULL, 'd', },
+	{ "help", 0, NULL, '?', },
+	{ "type", 1, NULL, 't', },
+	{ NULL, 0, NULL, 0, },
+};
+
+/**
+ * Display program synopsis
+ *
+ * @param progname NUL-terminated C string containing name of program
+ */
+static void
+nfsref_usage(const char *progname)
+{
+	fprintf(stderr, "Usage: %s [ -t type ] SUBCOMMAND [ ARGUMENTS ]\n\n",
+		progname);
+
+	fprintf(stderr, "SUBCOMMAND is one of:\n");
+	fprintf(stderr, "\tadd        Add a new junction\n");
+	fprintf(stderr, "\tremove     Remove an existing junction\n");
+	fprintf(stderr, "\tlookup     Enumerate a junction\n");
+
+	fprintf(stderr, "\nUse \"%s SUBCOMMAND -?\" for details.\n", progname);
+}
+
+/**
+ * Program entry point
+ *
+ * @param argc count of command line arguments
+ * @param argv array of NUL-terminated C strings containing command line arguments
+ * @return program exit status
+ */
+int
+main(int argc, char **argv)
+{
+	char *progname, *subcommand, *junct_path;
+	enum nfsref_type type;
+	int arg, exit_status;
+	_Bool help;
+
+	(void)setlocale(LC_ALL, "");
+	(void)umask(S_IWGRP | S_IWOTH);
+
+	exit_status = EXIT_FAILURE;
+
+	/* Set the basename */
+	if ((progname = strrchr(argv[0], '/')) != NULL)
+		progname++;
+	else
+		progname = argv[0];
+
+	xlog_stderr(1);
+	xlog_syslog(0);
+	xlog_open(progname);
+
+	if (argc < 2) {
+		nfsref_usage(progname);
+		goto out;
+	}
+
+	help = false;
+	type = NFSREF_TYPE_UNSPECIFIED;
+	while ((arg = getopt_long(argc, argv, nfsref_opts,
+			nfsref_longopts, NULL)) != -1) {
+		switch (arg) {
+		case 'd':
+			xlog_config(D_ALL, 1);
+			break;
+		case 't':
+			if (strcmp(optarg, "nfs-basic") == 0)
+				type = NFSREF_TYPE_NFS_BASIC;
+			else if (strcmp(optarg, "nfs-fedfs") == 0)
+				type = NFSREF_TYPE_NFS_FEDFS;
+			else {
+				xlog(L_ERROR,
+					"Unrecognized junction type: %s",
+					optarg);
+				exit(EXIT_FAILURE);
+			}
+			break;
+		case '?':
+			help = true;
+		}
+	}
+
+	if (argc < optind + 1) {
+		nfsref_usage(progname);
+		goto out;
+	}
+
+	if (!help && geteuid() != 0) {
+		xlog(L_ERROR, "Root permission is required");
+		goto out;
+	}
+
+	subcommand = argv[optind];
+	junct_path = argv[optind + 1];
+
+	if (strcasecmp(subcommand, "add") == 0) {
+		if (help) {
+			exit_status = nfsref_add_help(progname);
+			goto out;
+		}
+		if (argc < optind + 3) {
+			xlog(L_ERROR, "Not enough positional parameters");
+			nfsref_usage(progname);
+			goto out;
+		}
+		exit_status = nfsref_add(type, junct_path, argv, optind);
+		if (exit_status == EXIT_SUCCESS)
+			(void)junction_flush_exports_cache();
+	} else if (strcasecmp(subcommand, "remove") == 0) {
+		if (help) {
+			exit_status = nfsref_remove_help(progname);
+			goto out;
+		}
+		exit_status = nfsref_remove(type, junct_path);
+		if (exit_status == EXIT_SUCCESS)
+			(void)junction_flush_exports_cache();
+	} else if (strcasecmp(subcommand, "lookup") == 0) {
+		if (help) {
+			exit_status = nfsref_lookup_help(progname);
+			goto out;
+		}
+		exit_status = nfsref_lookup(type, junct_path);
+	} else {
+		xlog(L_ERROR, "Unrecognized subcommand: %s", subcommand);
+		nfsref_usage(progname);
+	}
+
+out:
+	exit(exit_status);
+}
diff --git a/utils/nfsref/nfsref.h b/utils/nfsref/nfsref.h
new file mode 100644
index 0000000..bf0e70e
--- /dev/null
+++ b/utils/nfsref/nfsref.h
@@ -0,0 +1,47 @@
+/**
+ * @file support/nfsref/nfsref.h
+ * @brief Declarations and definitions for nfsref command line tool
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#ifndef UTILS_NFSREF_H
+#define UTILS_NFSREF_H
+
+/**
+ * Junction types supported by the "nfsref" command
+ */
+enum nfsref_type {
+	NFSREF_TYPE_UNSPECIFIED = 1,
+	NFSREF_TYPE_NFS_BASIC,
+	NFSREF_TYPE_NFS_FEDFS
+};
+
+int	 nfsref_add(enum nfsref_type type, const char *junct_path, char **argv,
+				int optind);
+int	 nfsref_remove(enum nfsref_type type, const char *junct_path);
+int	 nfsref_lookup(enum nfsref_type type, const char *junct_path);
+
+int	 nfsref_add_help(const char *progname);
+int	 nfsref_remove_help(const char *progname);
+int	 nfsref_lookup_help(const char *progname);
+
+#endif	/* !UTILS_NFSREF_H */
diff --git a/utils/nfsref/nfsref.man b/utils/nfsref/nfsref.man
new file mode 100644
index 0000000..1261549
--- /dev/null
+++ b/utils/nfsref/nfsref.man
@@ -0,0 +1,180 @@
+.\"@(#)nfsref.8"
+.\"
+.\" @file utils/nfsref/nfsref.man
+.\" @brief man page for nfsref command
+.\"
+
+.\"
+.\" Copyright 2011, 2018 Oracle.  All rights reserved.
+.\"
+.\" This file is part of nfs-utils.
+.\"
+.\" nfs-utils is free software; you can redistribute it and/or modify
+.\" it under the terms of the GNU General Public License version 2.0 as
+.\" published by the Free Software Foundation.
+.\"
+.\" nfs-utils is distributed in the hope that it will be useful, but
+.\" WITHOUT ANY WARRANTY; without even the implied warranty of
+.\" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+.\" GNU General Public License version 2.0 for more details.
+.\"
+.\" You should have received a copy of the GNU General Public License
+.\" version 2.0 along with nfs-utils.  If not, see:
+.\"
+.\"	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+.\"
+.TH NFSREF 8 "9 Jan 2018"
+.SH NAME
+nfsref \- manage NFS referrals
+.SH SYNOPSIS
+.B nfsref
+.RB [ \-?d ]
+.RB [ \-t
+.IB type ]
+.B add
+.I pathname server export
+.RI [ " server"
+.IR export " ... ]"
+.P
+.B nfsref
+.RB [ \-?d ]
+.RB [ \-t
+.IB type ]
+.B remove
+.I pathname
+.P
+.B nfsref
+.RB [ \-?d ]
+.RB [ \-t
+.IB type ]
+.B lookup
+.I pathname
+.SH INTRODUCTION
+NFS version 4 introduces the concept of
+.I file system referrals
+to NFS.
+A file system referral is like a symbolic link on a file server
+to another file system share, possibly on another file server.
+On an NFS client, a referral behaves like an automounted directory.
+The client, under the server's direction, mounts a new NFS export
+automatically when an application first accesses that directory.
+.P
+Referrals are typically used to construct a single file name space
+across multiple file servers.
+Because file servers control the shape of the name space,
+no client configuration is required,
+and all clients see the same referral information.
+.P
+The Linux NFS server supports NFS version 4 referrals.
+Administrators can specify the
+.B refer=
+export option in
+.I /etc/exports
+to configure a list of exports from which the client can choose.
+See
+.BR exports (5)
+for details.
+.P
+.SH DESCRIPTION
+The
+.BR nfsref (8)
+command is a simple way to get started managing junction metadata.
+Other administrative commands provide richer access to junction information.
+.SS Subcommands
+Valid
+.BR nfsref (8)
+subcommands are:
+.IP "\fBadd\fP"
+Adds junction information to the directory named by
+.IR pathname .
+The named directory must already exist,
+and must not already contain junction information.
+Regular directory contents are obscured to NFS clients by this operation.
+.IP
+A list of one or more file server and export path pairs
+is also specified on the command line.
+When creating an NFS basic junction, this list is
+stored in an extended attribute of the directory.
+.IP
+If junction creation is successful, the
+.BR nfsref (8)
+command flushes the kernel's export cache
+to remove previously cached junction information.
+.IP "\fBremove\fP"
+Removes junction information from the directory named by
+.IR pathname .
+The named directory must exist,
+and must contain junction information.
+Regular directory contents are made visible to NFS clients again by this operation.
+.IP
+If junction deletion is successful, the
+.BR nfsref (8)
+command flushes the kernel's export cache
+to remove previously cached junction information.
+.IP "\fBlookup\fP"
+Displays junction information stored in the directory named by
+.IR pathname .
+The named directory must exist,
+and must contain junction information.
+.IP
+When looking up an NFS basic junction, the junction information
+in the directory is listed on
+.IR stdout .
+.SS Command line options
+.IP "\fB\-d, \-\-debug"
+Enables debugging messages during operation.
+.IP "\fB\-t, \-\-type=\fIjunction-type\fP"
+Specifies the junction type for the operation.  Valid values for
+.I junction-type
+are
+.B nfs-basic
+or
+.BR nfs-fedfs .
+.IP
+For the
+.B add
+subcommand, the default value if this option is not specified is
+.BR nfs-basic .
+For the
+.B remove
+and
+.B lookup
+subcommands, the
+.B \-\-type
+option is not required.  The
+.BR nfsref (8)
+command operates on whatever junction contents are available.
+.SH EXAMPLES
+Suppose you have two file servers,
+.I top.example.net
+and
+.IR home.example.net .
+You want all your clients to mount
+.I top.example.net:/
+and then see the files under
+.I home.example.net:/
+automatically in
+.IR top:/home .
+.P
+On
+.IR top.example.net ,
+you might issue this command as root:
+.RS
+.sp
+# mkdir /home
+.br
+# nfsref --type=nfs-basic add /home home.example.net /
+.br
+Created junction /home.
+.sp
+.RE
+.SH FILES
+.TP
+.I /etc/exports
+NFS server export table
+.SH "SEE ALSO"
+.BR exports (5)
+.sp
+RFC 5661 for a description of NFS version 4 referrals
+.SH "AUTHOR"
+Chuck Lever <chuck.lever@oracle.com>
diff --git a/utils/nfsref/remove.c b/utils/nfsref/remove.c
new file mode 100644
index 0000000..1a4e371
--- /dev/null
+++ b/utils/nfsref/remove.c
@@ -0,0 +1,145 @@
+/**
+ * @file utils/nfsref/remove.c
+ * @brief Remove junction metadata from a local file system object
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <stdio.h>
+
+#include <unistd.h>
+#include <errno.h>
+
+#include "junction.h"
+#include "xlog.h"
+#include "nfsref.h"
+
+/**
+ * Display help message for "remove" subcommand
+ *
+ * @param progname NUL-terminated C string containing name of program
+ * @return program exit status
+ */
+int
+nfsref_remove_help(const char *progname)
+{
+	fprintf(stderr, " \n");
+
+	fprintf(stderr, "Usage: %s [ -t type ] remove <junction path>\n\n",
+		progname);
+
+	fprintf(stderr, "Remove the junction at <junction path>.  For FedFS "
+			"junctions, FSL and FSN\n");
+	fprintf(stderr, "records are removed from the NSDB.\n");
+
+	return EXIT_SUCCESS;
+}
+
+/**
+ * Remove an NFS locations-style junction
+ *
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @return program exit status
+ */
+static int
+nfsref_remove_nfs_basic(const char *junct_path)
+{
+	int status = EXIT_FAILURE;
+	FedFsStatus retval;
+
+	xlog(D_GENERAL, "%s: Removing FedFS junction from %s",
+		__func__, junct_path);
+
+	retval = nfs_delete_junction(junct_path);
+	switch (retval) {
+	case FEDFS_OK:
+		printf("Removed nfs-basic junction from %s\n", junct_path);
+		status = EXIT_SUCCESS;
+		break;
+	case FEDFS_ERR_NOTJUNCT:
+		xlog(L_ERROR, "%s is not an nfs-basic junction", junct_path);
+		break;
+	default:
+		xlog(L_ERROR, "Failed to delete %s: %s",
+			junct_path, nsdb_display_fedfsstatus(retval));
+	}
+
+	return status;
+}
+
+/**
+ * Remove any NFS junction information
+ *
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @return program exit status
+ */
+static int
+nfsref_remove_unspecified(const char *junct_path)
+{
+	FedFsStatus retval;
+
+	xlog(D_GENERAL, "%s: Removing junction from %s",
+		__func__, junct_path);
+
+	retval = nfs_delete_junction(junct_path);
+	if (retval != FEDFS_OK) {
+		if (retval != FEDFS_ERR_NOTJUNCT)
+			goto out_err;
+	}
+
+	printf("Removed junction from %s\n", junct_path);
+	return EXIT_SUCCESS;
+
+out_err:
+	switch (retval) {
+	case FEDFS_ERR_NOTJUNCT:
+		xlog(L_ERROR, "No junction information found in %s", junct_path);
+		break;
+	default:
+		xlog(L_ERROR, "Failed to delete %s: %s",
+			junct_path, nsdb_display_fedfsstatus(retval));
+	}
+	return EXIT_FAILURE;
+}
+
+/**
+ * Remove an NFS junction
+ *
+ * @param type type of junction to add
+ * @param junct_path NUL-terminated C string containing pathname of junction
+ * @return program exit status
+ */
+int
+nfsref_remove(enum nfsref_type type, const char *junct_path)
+{
+	switch (type) {
+	case NFSREF_TYPE_UNSPECIFIED:
+		return nfsref_remove_unspecified(junct_path);
+	case NFSREF_TYPE_NFS_BASIC:
+		return nfsref_remove_nfs_basic(junct_path);
+	default:
+		xlog(L_ERROR, "Unrecognized junction type");
+	}
+	return EXIT_FAILURE;
+}

