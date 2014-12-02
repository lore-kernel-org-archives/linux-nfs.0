Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:49105 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbaLBMrh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2014 07:47:37 -0500
Subject: [PATCH 2/3] [RFC] nfs-utils: change internal rpcgen to support
 separate builddir
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Date: Tue, 02 Dec 2014 13:39:59 +0100
Message-ID: <20141202123959.13015.26461.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
References: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcgen uses absolute paths (based on the input) when generating the
output files, thus breaking builds using a separate build directory.
I'm not sure this is the best (or even an acceptable) approach, but
it works for me...consider it an RFC :)
---
 tools/rpcgen/rpc_main.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/rpcgen/rpc_main.c b/tools/rpcgen/rpc_main.c
index 28aa60c..f81da47 100644
--- a/tools/rpcgen/rpc_main.c
+++ b/tools/rpcgen/rpc_main.c
@@ -44,6 +44,7 @@ static char sccsid[] = "@(#)rpc_main.c 1.30 89/03/30 (C) 1987 SMI";
 #include <unistd.h>
 #include <ctype.h>
 #include <errno.h>
+#include <libgen.h>
 #include "rpc_parse.h"
 #include "rpc_util.h"
 #include "rpc_scan.h"
@@ -389,7 +390,7 @@ c_output(char *infile, char *define, int extend, char *outfile)
 	open_output(infile, outfilename);
 	add_warning();
 	if (infile && (include = extendfile(infile, ".h"))) {
-		f_print(fout, "#include \"%s\"\n", include);
+		f_print(fout, "#include \"%s\"\n", basename(include));
 		free(include);
 		/* .h file already contains rpc/rpc.h */
 	} else
@@ -523,7 +524,7 @@ s_output(int argc, char **argv, char *infile, char *define, int extend,
 	open_output(infile, outfilename);
 	add_warning();
 	if (infile && (include = extendfile(infile, ".h"))) {
-		f_print(fout, "#include \"%s\"\n", include);
+		f_print(fout, "#include \"%s\"\n", basename(include));
 		free(include);
 	} else
 	  f_print(fout, "#include <rpc/rpc.h>\n");
@@ -630,7 +631,7 @@ l_output(char *infile, char *define, int extend, char *outfile)
 	if (Cflag)
 	  f_print (fout, "#include <memory.h> /* for memset */\n");
 	if (infile && (include = extendfile(infile, ".h"))) {
-		f_print(fout, "#include \"%s\"\n", include);
+		f_print(fout, "#include \"%s\"\n", basename(include));
 		free(include);
 	} else
 	  f_print(fout, "#include <rpc/rpc.h>\n");

