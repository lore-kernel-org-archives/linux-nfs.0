From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - 4 of 6 - nfsstat - removed needless warning
Date: Wed, 18 Jun 2003 14:00:57 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF0A8D9.5070301@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000006000106010102000709"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ShDu-0000IJ-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 10:59:54 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h5IHxlK15717
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 13:59:47 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------000006000106010102000709
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Reworked the diagnostics of nfsstat so warnings
are not displayed for statistics that are not
asked for and don't exist.

SteveD.


--------------000006000106010102000709
Content-Type: text/plain;
 name="nfs-utils-1.0.3-04-nfsstat-gooddiags.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.3-04-nfsstat-gooddiags.patch"

--- nfs-utils-1.0.1/utils/nfsstat/nfsstat.c.org	2002-05-05 19:33:30.000000000 -0400
+++ nfs-utils-1.0.1/utils/nfsstat/nfsstat.c	2003-01-07 16:01:02.000000000 -0500
@@ -124,6 +124,8 @@
 	int		opt_all = 0,
 			opt_srv = 0,
 			opt_clt = 0,
+			srv_info = 0,
+			clt_info = 0,
 			opt_prt = 0;
 	int		c;
 
@@ -184,9 +186,25 @@
 			"server.\n");
 	}
 
-	if ((opt_srv && !parse_statfile(NFSSVCSTAT, svcinfo))
-	 || (opt_clt && !parse_statfile(NFSCLTSTAT, cltinfo)))
-		return 2;
+	if (opt_srv) {
+		srv_info = parse_statfile(NFSSVCSTAT, svcinfo);
+		if (srv_info == 0 && opt_clt == 0) {
+			fprintf(stderr, "Warning: No Server Stats (%s: %m).\n", NFSSVCSTAT);
+			return 2;
+		}
+		if (srv_info == 0)
+			opt_srv = 0;
+	}
+
+	if (opt_clt) {
+		clt_info = parse_statfile(NFSCLTSTAT, cltinfo);
+		if (opt_srv == 0 && clt_info == 0) {
+			fprintf(stderr, "Warning: No Client Stats (%s: %m).\n", NFSCLTSTAT);
+			return 2;
+		}
+		if (clt_info == 0)
+			opt_clt = 0;
+	}
 
 	if (opt_srv) {
 		if (opt_prt & PRNT_NET) {
@@ -338,8 +356,8 @@
 	 * be a fatal error -- it usually means the module isn't loaded.
 	 */
 	if ((fp = fopen(name, "r")) == NULL) {
-		fprintf(stderr, "Warning: %s: %m\n", name);
-		return 1;
+		// fprintf(stderr, "Warning: %s: %m\n", name);
+		return 0;
 	}
 
 	while (fgets(buffer, sizeof(buffer), fp) != NULL) {

--------------000006000106010102000709--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
