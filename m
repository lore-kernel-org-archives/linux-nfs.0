Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:58729 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754508AbaIZOoU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 10:44:20 -0400
Received: by mail-wg0-f45.google.com with SMTP id x13so9227329wgg.4
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2014 07:44:18 -0700 (PDT)
Received: from [192.168.1.188] (ipbcc2b967.dynamic.kabel-deutschland.de. [188.194.185.103])
        by mx.google.com with ESMTPSA id lu12sm2457482wic.4.2014.09.26.07.44.17
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 07:44:17 -0700 (PDT)
Message-ID: <54257BC0.9040806@gmail.com>
Date: Fri, 26 Sep 2014 16:44:16 +0200
From: Andreas Reis <andreas.reis@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH] exportfs: Completely unexport directory by path alone
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Patch to allow complete unexport of a directory without having to state each of its clients.

Ie, "exportfs -u /foo/bar" unexports all entries matching that path.

Useful when one doesn't want to / can't do the bookkeeping required otherwise.

Signed-off-by: Andreas Reis <andreas.reis@gmail.com>
---
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index bdea12b..ae90808 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -393,65 +393,90 @@ unexportfs_parsed(char *hname, char *path, int verbose)
 {
 	nfs_export	*exp;
 	struct addrinfo *ai = NULL;
-	int		htype;
-	int		success = 0;
-
-	if ((htype = client_gettype(hname)) == MCL_FQDN) {
-		ai = host_addrinfo(hname);
-		if (ai)
-			hname = ai->ai_canonname;
+	int		htype = 0;
+	bool		success = false;
+
+	if(hname) {
+		if ((htype = client_gettype(hname)) == MCL_FQDN) {
+			ai = host_addrinfo(hname);
+			if (ai)
+				hname = ai->ai_canonname;
+		}
 	}
 
-	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
-		if (path && strcmp(path, exp->m_export.e_path))
-			continue;
-		if (htype != exp->m_client->m_type)
-			continue;
-		if (htype == MCL_FQDN
-		    && !matchhostname(exp->m_export.e_hostname,
-					  hname))
-			continue;
-		if (htype != MCL_FQDN
-		    && strcasecmp(exp->m_export.e_hostname, hname))
-			continue;
-		if (verbose) {
-#if 0
-			if (exp->m_exported) {
-				printf("unexporting %s:%s from kernel\n",
-				       exp->m_client->m_hostname,
-				       exp->m_export.e_path);
+	do {
+
+		for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
+			if (path && strcmp(path, exp->m_export.e_path))
+				continue;
+			if (htype != exp->m_client->m_type)
+				continue;
+			if (hname) {
+				if (htype == MCL_FQDN
+				    && !matchhostname(exp->m_export.e_hostname,
+							  hname))
+					continue;
+				if (htype != MCL_FQDN
+				    && strcasecmp(exp->m_export.e_hostname, hname))
+					continue;
 			}
-			else
+			if (verbose) {
+#if 0
+				if (exp->m_exported) {
+					printf("unexporting %s:%s from kernel\n",
+					       exp->m_client->m_hostname,
+					       exp->m_export.e_path);
+				}
+				else
 #endif
-				printf("unexporting %s:%s\n",
-					exp->m_client->m_hostname,
-					exp->m_export.e_path);
-		}
+					printf("unexporting %s:%s\n",
+						exp->m_client->m_hostname,
+						exp->m_export.e_path);
+			}
 #if 0
-		if (exp->m_exported && !export_unexport(exp))
-			error(exp, errno);
+			if (exp->m_exported && !export_unexport(exp))
+				error(exp, errno);
 #endif
-		exp->m_xtabent = 0;
-		exp->m_mayexport = 0;
-		success = 1;
+			exp->m_xtabent = 0;
+			exp->m_mayexport = 0;
+			success = true;
+		}
+
+		if(hname)
+			break;
+ 		else
+			++htype;
+
+	} while(htype < MCL_MAXTYPES);
+
+	if (!success) {
+		if(hname)
+			xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname, path);
+		else
+			xlog(L_ERROR, "No clients of '%s' found to unexport.", path);
 	}
-	if (!success)
-		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname, path);
 
-	freeaddrinfo(ai);
+	if(hname)
+		freeaddrinfo(ai);
 }
 
 static int unexportfs_generic(char *arg, int verbose)
 {
-	char *path;
+	char *path = strchr(arg, ':');
 
-	if ((path = strchr(arg, ':')) != NULL)
+	if (path) {
 		*path++ = '\0';
+		if (*path != '/')
+			return 1;
+		unexportfs_parsed(arg, path, verbose);
+	} else {
+		// unqualified unexport
+		if (*arg != '/')
+			return 1;
+		// NULL as signal
+		unexportfs_parsed(NULL, arg, verbose);
+	}
 
-	if (!path || *path != '/')
-		return 1;
-
-	unexportfs_parsed(arg, path, verbose);
 	return 0;
 }
 
