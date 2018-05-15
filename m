Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59746 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752323AbeEOPyx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 11:54:53 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id BC60C40200A0
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 15:54:52 +0000 (UTC)
Message-ID: <1526399690.7441.10.camel@redhat.com>
Subject: [PATCH v3 6/8] nfs-utils: Add nfsconftool cli
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 15 May 2018 16:54:50 +0100
In-Reply-To: <1526399410.7441.4.camel@redhat.com>
References: <1526399410.7441.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This tool uses the conffile facilities to allow commandline
querying of configuration settings and to dump the current
config for diagnosis and testing

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 Makefile.am                |   2 +-
 configure.ac               |   1 +
 tools/Makefile.am          |   2 +
 tools/nfsconf/Makefile.am  |   8 ++
 tools/nfsconf/nfsconfcli.c | 180 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 192 insertions(+), 1 deletion(-)
 create mode 100644 tools/nfsconf/Makefile.am
 create mode 100644 tools/nfsconf/nfsconfcli.c

diff --git a/Makefile.am b/Makefile.am
index e1f39aa..0022084 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -2,7 +2,7 @@
 
 AUTOMAKE_OPTIONS = foreign
 
-SUBDIRS = tools support utils linux-nfs tests systemd
+SUBDIRS = support tools utils linux-nfs tests systemd
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/configure.ac b/configure.ac
index 5a11636..b925666 100644
--- a/configure.ac
+++ b/configure.ac
@@ -616,6 +616,7 @@ AC_CONFIG_FILES([
 	tools/rpcgen/Makefile
 	tools/mountstats/Makefile
 	tools/nfs-iostat/Makefile
+	tools/nfsconf/Makefile
 	utils/Makefile
 	utils/blkmapd/Makefile
 	utils/nfsdcltrack/Makefile
diff --git a/tools/Makefile.am b/tools/Makefile.am
index f2ce282..4266da4 100644
--- a/tools/Makefile.am
+++ b/tools/Makefile.am
@@ -6,6 +6,8 @@ if CONFIG_RPCGEN
 OPTDIRS += rpcgen
 endif
 
+OPTDIRS += nfsconf
+
 SUBDIRS = locktest rpcdebug nlmtest mountstats nfs-iostat $(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/tools/nfsconf/Makefile.am b/tools/nfsconf/Makefile.am
new file mode 100644
index 0000000..0042db9
--- /dev/null
+++ b/tools/nfsconf/Makefile.am
@@ -0,0 +1,8 @@
+## Process this file with automake to produce Makefile.in
+
+bin_PROGRAMS = nfsconftool
+
+nfsconftool_SOURCES = nfsconfcli.c
+nfsconftool_LDADD = ../../support/nfs/libnfsconf.la
+
+MAINTAINERCLEANFILES = Makefile.in
diff --git a/tools/nfsconf/nfsconfcli.c b/tools/nfsconf/nfsconfcli.c
new file mode 100644
index 0000000..034ec51
--- /dev/null
+++ b/tools/nfsconf/nfsconfcli.c
@@ -0,0 +1,180 @@
+#include <stdlib.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <getopt.h>
+#include <string.h>
+#include <errno.h>
+#include "config.h"
+#include "conffile.h"
+#include "xlog.h"
+
+typedef enum {
+	MODE_NONE,
+	MODE_GET,
+	MODE_ISSET,
+	MODE_DUMP
+} confmode_t;
+
+static void usage(const char *name)
+{
+	fprintf(stderr, "Usage: %s [-v] [--file filename.conf] ...\n", name);
+	fprintf(stderr, "Options:\n");
+	fprintf(stderr, " -v			Increase Verbosity\n");
+	fprintf(stderr, " --file filename.conf	Load this config file\n");
+	fprintf(stderr, "     (Default config file: " NFS_CONFFILE "\n");
+	fprintf(stderr, "Modes:\n");
+	fprintf(stderr, "  --dump [outputfile]\n");
+	fprintf(stderr, "      Outputs the configuration to the named file\n");
+	fprintf(stderr, "  --get [--arg subsection] {section} {tag}\n");
+	fprintf(stderr, "      Output one specific config value\n");
+	fprintf(stderr, "  --isset [--arg subsection] {section} {tag}\n");
+	fprintf(stderr, "      Return code indicates if config value is present\n");
+}
+
+int main(int argc, char **argv)
+{
+	const char * val;
+	char * confpath = NFS_CONFFILE;
+	char * arg = NULL;
+	int verbose=0;
+	int ret = 0;
+	char * dumpfile = NULL;
+
+	confmode_t mode = MODE_NONE;
+
+	while (1) {
+		int c;
+		int index = 0;
+		struct option long_options[] = {
+			{"get",		no_argument, 0, 'g' },
+			{"arg",	  required_argument, 0, 'a' },
+			{"isset", 	no_argument, 0, 'i' },
+			{"dump",  optional_argument, 0, 'd' },
+			{"file",  required_argument, 0, 'f' },
+			{"verbose",	no_argument, 0, 'v' },
+			{NULL,			  0, 0, 0 }
+		};
+
+		c = getopt_long(argc, argv, "ga:id::f:v", long_options, &index);
+		if (c == -1) break;
+
+		switch (c) {
+			case 0:
+				break;
+			case 'f':
+				/* user specified souce path for config */
+				confpath = optarg;
+				break;
+			case 'a':
+				/* user supplied a sub-section name */
+				arg = optarg;
+				break;
+			case 'v':
+				verbose++;
+				break;
+			case 'g':
+				mode = MODE_GET;
+				break;
+			case 'i':
+				mode = MODE_ISSET;
+				break;
+			case 'd':
+				/* check if user supplied a filename for dump */
+				if (optarg == NULL && argv[optind] != NULL
+				    && argv[optind][0] != '-')
+					optarg = argv[optind++];
+				mode = MODE_DUMP;
+				dumpfile = optarg;
+				break;
+			default:
+				usage(argv[0]);
+				return 1;
+		}
+	}
+
+	/* configure the logging that conffile.c uses */
+	if (verbose)
+		xlog_config(D_ALL, 1);
+	xlog_stderr(1);
+	xlog_syslog(0);
+	xlog_open("nfsconftool");
+
+	if (mode == MODE_NONE) {
+		fprintf(stderr, "Error: No MODE selected.\n");
+		usage(argv[0]);
+		return 1;
+	}
+
+	if (conf_init_file(confpath)) {
+		/* config file was missing or had an error, warn about it */
+		if (verbose || mode != MODE_ISSET)
+			fprintf(stderr, "Error loading config file %s\n",
+				confpath);
+		/* this isnt fatal for --isset */
+		if (mode != MODE_ISSET)
+			return 1;
+	}
+
+	/* --dump mode, output the current configuration */
+	if (mode == MODE_DUMP) {
+		/* default to writing it to stdout */
+		FILE *out = stdout;
+
+		/* user specified a file to write to instead */
+		if (dumpfile) {
+			out = fopen(dumpfile, "w");
+			if (out == NULL) {
+				fprintf(stderr, "Error opening dumpfile %s: %s\n",
+					dumpfile, strerror(errno));
+				ret = 2;
+				goto cleanup;
+			}
+			if (verbose)
+				printf("Dumping config to %s\n", dumpfile);
+		}
+
+		/* output the configuration */
+		conf_report(out);
+
+		/* close that user specified file */
+		if (dumpfile)
+			fclose(out);
+	} else
+	/* --iset and --get share a lot of code */
+	if (mode == MODE_GET || mode == MODE_ISSET) {
+		char * section = NULL;
+		char * tag = NULL;
+
+		/* test they supplied section and tag names */
+		if (optind+1 >= argc) {
+			fprintf(stderr, "Error: insufficient arguments for mode\n");
+			usage(argv[0]);
+			ret = 2;
+			goto cleanup;
+		}
+
+		/* now we have a section and tag name */
+		section = argv[optind++];
+		tag = argv[optind++];
+
+		/* retrieve the specified tags value */
+		val = conf_get_section(section, arg, tag);
+		if (val != NULL) {
+			/* ret=0, success, mode --get wants to output the value as well */
+			if (mode == MODE_GET)
+				printf("%s\n", val);
+		} else {
+			/* ret=1, no value found, tell the user if they asked */
+			if (mode == MODE_GET && verbose)
+				fprintf(stderr, "Tag '%s' not found\n", tag);
+			ret = 1;
+		}
+	} else {
+		fprintf(stderr, "Mode not yet implimented.\n");
+		ret = 2;
+	}
+
+cleanup:
+	conf_cleanup();
+	return ret;
+}
-- 
1.8.3.1




