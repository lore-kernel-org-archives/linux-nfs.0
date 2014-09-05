Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy1-pub.mail.unifiedlayer.com ([69.89.25.95]:36845 "HELO
	gproxy1-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750712AbaIERI4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 13:08:56 -0400
Received: from [98.248.107.106] (port=50460 helo=monster.martins.cc)
	by box503.bluehost.com with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.82)
	(envelope-from <linux@martins.cc>)
	id 1XPwtn-0004Fi-1T
	for linux-nfs@vger.kernel.org; Fri, 05 Sep 2014 11:02:11 -0600
Received: from monster.martins.cc (monster.martins.cc [127.0.0.1])
	by monster.martins.cc (Postfix) with ESMTP id 6A8AB60056
	for <linux-nfs@vger.kernel.org>; Fri,  5 Sep 2014 10:02:08 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: Henrique Martins <linux@martins.cc>
Subject: F20 nfs-utils exportfs patch
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Date: Fri, 05 Sep 2014 10:02:08 -0700
Message-ID: <14393.1409936528@monster.martins.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8


Attaching path to exportfs that:
- in client.c/client_lookup:
    changes the (x)log level for unresolvable entries in
    /etc/exports from L_ERROR to L_WARNING,
- in hostname.c/host_addrinfo:
    changes the (x)log level for unresolvable entries in
    /etc/exports from D_GENERAL to D_PARSE,
- in export.c/export_read:
    counts the number of exported volume entries and
    generates a (x)log L_ERROR if no volumes are exported.

Built and tested on a Fedora 20 system.

-- Henrique


--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline; filename=nfs-utils-1.3.0-exportfs.patch

--- nfs-utils-1.3.0/support/export/client.c.orig	2014-09-05 08:21:37.568364360 -0700
+++ nfs-utils-1.3.0/support/export/client.c	2014-09-05 08:21:41.709451778 -0700
@@ -277,7 +277,7 @@
 	if (htype == MCL_FQDN && !canonical) {
 		ai = host_addrinfo(hname);
 		if (!ai) {
-			xlog(L_ERROR, "Failed to resolve %s", hname);
+			xlog(L_WARNING, "Failed to resolve %s", hname);
 			goto out;
 		}
 		hname = ai->ai_canonname;
--- nfs-utils-1.3.0/support/export/hostname.c.orig	2014-09-05 08:09:07.387551291 -0700
+++ nfs-utils-1.3.0/support/export/hostname.c	2014-09-05 08:09:13.799573723 -0700
@@ -175,11 +175,11 @@
 	case 0:
 		return ai;
 	case EAI_SYSTEM:
-		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
+		xlog(D_PARSE, "%s: failed to resolve %s: (%d) %m",
 				__func__, hostname, errno);
 		break;
 	default:
-		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
+		xlog(D_PARSE, "%s: failed to resolve %s: %s",
 				__func__, hostname, gai_strerror(error));
 		break;
 	}
--- nfs-utils-1.3.0/support/export/export.c.orig	2014-03-25 08:12:07.000000000 -0700
+++ nfs-utils-1.3.0/support/export/export.c	2014-09-05 09:23:37.424105125 -0700
@@ -76,15 +76,22 @@
 	struct exportent	*eep;
 	nfs_export		*exp;

+        int volumes = 0;
+
 	setexportent(fname, "r");
 	while ((eep = getexportent(0,1)) != NULL) {
 		exp = export_lookup(eep->e_hostname, eep->e_path, 0);
-		if (!exp)
-			export_create(eep, 0);
+		if (!exp) {
+			exp = export_create(eep, 0);
+                        if (exp)
+                        	volumes++;
+                }
 		else
 			warn_duplicated_exports(exp, eep);
 	}
 	endexportent();
+        if (volumes == 0)
+        	xlog(L_ERROR, "no or all unresolvable export entries");
 }

 /**

--=-=-=--
