From: bpm@sgi.com
Subject: [ RFC PATCH 5/4 ] Add wsync export option to nfs-utils
Date: Wed, 3 Feb 2010 17:47:58 -0600
Message-ID: <20100203234758.GI5702@sgi.com>
References: <20100203233755.17677.96582.stgit@case>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:38104 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757779Ab0BCXrY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 18:47:24 -0500
Received: from whiskey.americas.sgi.com (whiskey.americas.sgi.com [128.162.233.19])
	by relay3.corp.sgi.com (Postfix) with ESMTP id BF904AC038
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 15:47:23 -0800 (PST)
In-Reply-To: <20100203233755.17677.96582.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=out

commit 0eacb0dffa603b6fa2dded1d99e9e1d2be73c5da
Author: Ben Myers <bpm@sgi.com>
Date:   Wed Feb 3 16:05:22 2010 -0600

diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
index 1547a87..8119b9a 100644
--- a/support/include/nfs/export.h
+++ b/support/include/nfs/export.h
@@ -17,7 +17,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40, 80, 100 unused */
+#define NFSEXP_WSYNC		0x0040
+/* 80, 100 unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index a93941c..51b94d8 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -223,6 +223,7 @@ putexportent(struct exportent *ep)
 	FILE	*fp;
 	int	*id, i;
 	char	*esc=ep->e_path;
+	char	*syncchar;
 
 	if (!efp)
 		return;
@@ -236,7 +237,14 @@ putexportent(struct exportent *ep)
 
 	fprintf(fp, "\t%s(", ep->e_hostname);
 	fprintf(fp, "%s,", (ep->e_flags & NFSEXP_READONLY)? "ro" : "rw");
-	fprintf(fp, "%ssync,", (ep->e_flags & NFSEXP_ASYNC)? "a" : "");
+	if (ep->e_flags & NFSEXP_ASYNC) {
+		syncchar = "a";
+	} else if (ep->e_flags & NFSEXP_WSYNC) {
+		syncchar = "w";
+	} else {
+		syncchar = "";
+	}
+	fprintf(fp, "%ssync,", syncchar);
 	fprintf(fp, "%swdelay,", (ep->e_flags & NFSEXP_GATHERED_WRITES)?
 				"" : "no_");
 	fprintf(fp, "%shide,", (ep->e_flags & NFSEXP_NOHIDE)?
@@ -519,7 +527,10 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
 			clearflags(NFSEXP_ASYNC, active, ep);
 		else if (!strcmp(opt, "async"))
 			setflags(NFSEXP_ASYNC, active, ep);
-		else if (!strcmp(opt, "nohide"))
+		else if (!strcmp(opt, "wsync")) {
+			clearflags(NFSEXP_ASYNC, active, ep);
+			setflags(NFSEXP_WSYNC, active, ep);
+		} else if (!strcmp(opt, "nohide"))
 			setflags(NFSEXP_NOHIDE, active, ep);
 		else if (!strcmp(opt, "hide"))
 			clearflags(NFSEXP_NOHIDE, active, ep);

--3V7upXqbjpZ4EhLz--
