From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] mount.nfs: protocol version set on command line being ignored
Date: Thu, 08 Oct 2009 11:13:48 -0400
Message-ID: <4ACE01AC.3000806@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5554 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608AbZJHPOY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2009 11:14:24 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n98FDwTL015485
	for <linux-nfs@vger.kernel.org>; Thu, 8 Oct 2009 11:13:58 -0400
Received: from xenhat.boston.devel.redhat.com (xenhat.boston.devel.redhat.com [10.16.60.47])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n98FDvnl013191
	for <linux-nfs@vger.kernel.org>; Thu, 8 Oct 2009 11:13:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is a bug that was found in some recent test cycles...


Author: Steve Dickson <steved@redhat.com>
Date:   Thu Oct 8 10:56:57 2009 -0400

    There are a number of different mount options that can be
    used to set the protocol version on the command line. The
    config file code needs to know about each option so the
    command line value will override the config file value.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index e347b0e..b0aa6f0 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -185,6 +185,20 @@ void free_all(void)
 		free(entry);
 	}
 }
+static char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
+int inline check_vers(char *mopt, char *field)
+{
+	int i;
+
+	if (strncmp("mountvers", field, strlen("mountvers") != 0 &&
+			(strcasecmp(field, "nfsvers") == 0 || 
+				strcasecmp(field, "vers") == 0))) {
+		for (i=0; versions[i]; i++) 
+			if (strcasestr(mopt, versions[i]) != NULL)
+				return 1;
+	}
+	return 0;
+}
 /*
  * Parse the given section of the configuration 
  * file to if there are any mount options set.
@@ -207,6 +221,12 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 		snprintf(buf, BUFSIZ, "%s=", node->field);
 		if (opts && strcasestr(opts, buf) != NULL)
 			continue;
+		/* 
+		 * Protocol verions can be set in a number of ways
+		 */
+		if (opts && check_vers(opts, node->field))
+			continue;
+
 		if (lookup_entry(node->field) != NULL)
 			continue;
 		buf[0] = '\0';
