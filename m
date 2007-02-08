From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 12/12] Add option to svcgssd to enable libnfsidmap
	debugging.
Date: Thu, 08 Feb 2007 17:27:51 -0500
Message-ID: <20070208222750.23464.34565.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk8-0006t0-2l
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:52 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFHk9-0004RH-FW
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:54 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
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

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

As suggested by Glenn Machin <GMachin@sandia.gov>.  Allow svcgssd
to turn on libnfsidmap debugging.  This uses a new command-line
parameter so that it can be enabled independently from other
debugging.
---

 utils/gssd/svcgssd.c   |   16 ++++++++++++++--
 utils/gssd/svcgssd.man |    8 ++++++--
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 0db3762..37e0407 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -54,6 +54,7 @@ #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <signal.h>
+#include <nfsidmap.h>
 #include "nfslib.h"
 #include "svcgssd.h"
 #include "gss_util.h"
@@ -154,7 +155,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r]\n",
+	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i]\n",
 		progname);
 	exit(1);
 }
@@ -166,15 +167,19 @@ main(int argc, char *argv[])
 	int fg = 0;
 	int verbosity = 0;
 	int rpc_verbosity = 0;
+	int idmap_verbosity = 0;
 	int opt;
 	extern char *optarg;
 	char *progname;
 
-	while ((opt = getopt(argc, argv, "fvrnp:")) != -1) {
+	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
 				break;
+			case 'i':
+				idmap_verbosity++;
+				break;
 			case 'n':
 				get_creds = 0;
 				break;
@@ -203,6 +208,13 @@ #else
 		printerr(0, "Warning: rpcsec_gss library does not "
 			    "support setting debug level\n");
 #endif
+#ifdef HAVE_NFS4_SET_DEBUG
+        nfs4_set_debug(idmap_verbosity, NULL);
+#else
+	if (idmap_verbosity > 0)
+		printerr(0, "Warning: your nfsidmap library does not "
+			    "support setting debug level\n");
+#endif
 
 	if (gssd_check_mechs() != 0) {
 		printerr(0, "ERROR: Problem with gssapi library\n");
diff --git a/utils/gssd/svcgssd.man b/utils/gssd/svcgssd.man
index a770662..1a015e1 100644
--- a/utils/gssd/svcgssd.man
+++ b/utils/gssd/svcgssd.man
@@ -2,11 +2,11 @@
 .\" rpc.svcgssd(8)
 .\"
 .\" Copyright (C) 2003 J. Bruce Fields <bfields@umich.edu>
-.TH rpc.svcgssd 8 "17 Mar 2003"
+.TH rpc.svcgssd 8 "12 Jan 2007"
 .SH NAME
 rpc.svcgssd \- server-side rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.svcgssd [-v] [-r] [-f] [-p pipefsdir]"
+.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p pipefsdir]"
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -31,6 +31,10 @@ Increases the verbosity of the output (c
 .B -r
 If the rpcsec_gss library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
+.TP
+.B -i
+If the nfsidmap library supports setting debug level,
+increases the verbosity of the output (can be specified multiple times).
 
 .SH SEE ALSO
 .BR rpc.gssd(8),

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
