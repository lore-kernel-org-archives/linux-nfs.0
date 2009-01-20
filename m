From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] mountd: Don't do tcp wrapper check when there are no rules
Date: Tue, 20 Jan 2009 06:22:58 -0500
Message-ID: <4975B412.9070509@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33850 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757863AbZATLZY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jan 2009 06:25:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Its been point out that if there are are no rules in either 
/etc/hosts.deny or /etc/hosts.allow there is no need to do any
validity checking on the incoming address.

Unfortunately there is no interface that will easily
let me know if there are any rules so I simply read
in both files looking for non-commented lines.

steved.
  

commit 5f09a2bacb4bf0a906e2d19931568b91fb6c5088
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Jan 20 06:16:56 2009 -0500

    mountd: Don't do tcp wrapper check when there are no rules
    
    If there are no rules in either /etc/hosts.deny or
    /etc/hosts.allow there is no need to do the host validation.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index 977dfca..af9813c 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -34,6 +34,7 @@
 #ifdef HAVE_CONFIG_H
 #include <config.h>
 #endif
+#include <stdio.h>
 #include <tcpwrapper.h>
 #include <unistd.h>
 #include <string.h>
@@ -55,6 +56,8 @@
 #include <rpc/rpcent.h>
 #endif
 
+static int check_files(void);
+static int check_rules(void);
 static void logit(int severity, struct sockaddr_in *addr,
 		  u_long procnum, u_long prognum, char *text);
 static void toggle_verboselog(int sig);
@@ -263,8 +266,40 @@ void    check_startup(void)
     (void) signal(SIGINT, toggle_verboselog);
 }
 
-/* check_files - check to see if either access files have changed */
+/*
+ * check_rules - check to see if any entries exist in
+ * either hosts file.
+ */
+int check_rules()
+{
+	FILE *fp;
+	char buf[BUFSIZ];
+
+ 	if ((fp = fopen("/etc/hosts.allow", "r")) == NULL)
+		return 0;
+
+	while (fgets(buf, BUFSIZ, fp) != NULL) {
+		if (buf[0] == '#')
+			continue;
+		fclose(fp);
+		return 1;
+	}
+	fclose(fp);
+
+	if ((fp = fopen("/etc/hosts.deny", "r")) == NULL)
+		return 0;
 
+	while (fgets(buf, BUFSIZ, fp) != NULL) {
+		if (buf[0] == '#')
+			continue;
+		fclose(fp);
+		return 1;
+	}
+	fclose(fp);
+	return 0;
+}
+  
+/* check_files - check to see if either access files have changed */
 static int check_files()
 {
 	static time_t allow_mtime, deny_mtime;
@@ -306,6 +341,13 @@ u_long  prog;
 	if (acc && changed == 0)
 		return (acc->access);
 
+	/*
+	 * See if there are any rules to be applied,
+	 * if not, no need to check the address
+	 */
+	if (check_rules() == 0)
+		goto done;
+
 	if (!(from_local(addr) || good_client(daemon, addr))) {
 		log_bad_host(addr, proc, prog);
 		if (acc)
@@ -317,10 +359,12 @@ u_long  prog;
 	if (verboselog)
 		log_client(addr, proc, prog);
 
+done:
 	if (acc)
 		acc->access = TRUE;
 	else 
 		haccess_add(addr, proc, prog, TRUE);
+
     return (TRUE);
 }
 
