Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758Ab0ARVrS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2010 16:47:18 -0500
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o0ILlIQ7024502
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 18 Jan 2010 16:47:18 -0500
Received: from badhat.bos.devel.redhat.com (vpn-233-71.phx2.redhat.com [10.3.233.71])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o0ILlHov010667
	for <linux-nfs@vger.kernel.org>; Mon, 18 Jan 2010 16:47:18 -0500
Message-ID: <4B54D6E5.7030609@RedHat.com>
Date: Mon, 18 Jan 2010 16:47:17 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Configuration file parser ignoring options
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jan 18 16:45:26 EST 2010

    mount.nfs: Configuration file parser ignoring options

    When the protocol version is set on the command line,
    none of the variables set in the configuration file
    are passed down to the kernel due to a bug in the 
    parsing routine. 

Tested-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>

diff -up nfs-utils-1.2.1/utils/mount/configfile.c.orig nfs-utils-1.2.1/utils/mount/configfile.c
--- nfs-utils-1.2.1/utils/mount/configfile.c.orig	2009-11-04 06:13:56.000000000 -0500
+++ nfs-utils-1.2.1/utils/mount/configfile.c	2010-01-18 15:39:02.973739055 -0500
@@ -194,13 +194,29 @@ void free_all(void)
 static char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
 int inline check_vers(char *mopt, char *field)
 {
-	int i;
+	int i, found=0;
 
-	if (strncmp("mountvers", field, strlen("mountvers")) != 0) {
-		for (i=0; versions[i]; i++) 
-			if (strcasestr(mopt, versions[i]) != NULL)
-				return 1;
+	/*
+	 * First check to see if the config setting is one 
+	 * of the many version settings
+	 */
+	for (i=0; versions[i]; i++) { 
+		if (strcasestr(field, versions[i]) != NULL) {
+			found++;
+			break;
+		}
+	}
+	if (!found)
+		return 0;
+	/*
+	 * It appears the version is being set, now see
+	 * if the version appears on the command 
+	 */
+	for (i=0; versions[i]; i++)  {
+		if (strcasestr(mopt, versions[i]) != NULL)
+			return 1;
 	}
+
 	return 0;
 }
 
