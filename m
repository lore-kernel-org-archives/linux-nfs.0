From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 3/3] nfs-utils: Enabling TCP wrappers
Date: Mon, 15 Dec 2008 12:11:26 -0500
Message-ID: <49468FBE.2000705@RedHat.com>
References: <49468BC7.2000907@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39071 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754452AbYLORNi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2008 12:13:38 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mBFHDcZi008509
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:13:38 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mBFHDbxK010552
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:13:37 -0500
Received: from [10.16.60.47] (xenhat.boston.devel.redhat.com [10.16.60.47])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mBFHDawb024921
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:13:37 -0500
In-Reply-To: <49468BC7.2000907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit e1956712782b4bb7b4369420bfada972e5bc4398
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Dec 15 11:44:51 2008 -0500

    To ensure the hash table of clients has valid
    access rights, check the modification times on
    both access files. If one of them have change,
    update the hash entry instead of creating a
    new entry.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index f7fd3a9..c0c5af7 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -45,6 +45,9 @@
 #include <sys/types.h>
 #include <sys/signal.h>
 #include <sys/queue.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
 #ifdef SYSV40
 #include <netinet/in.h>
 #include <rpc/rpcent.h>
@@ -246,6 +249,33 @@ void    check_startup(void)
     (void) signal(SIGINT, toggle_verboselog);
 }
 
+/* check_files - check to see if either access files have changed */
+
+int check_files()
+{
+	static time_t allow_mtime, deny_mtime;
+	struct stat astat, dstat;
+	int changed = 0;
+
+	if (stat("/etc/hosts.allow", &astat) < 0)
+		astat.st_mtime = 0;
+	if (stat("/etc/hosts.deny", &dstat) < 0)
+		dstat.st_mtime = 0;
+
+	if(!astat.st_mtime || !dstat.st_mtime)
+		return changed;
+
+	if (astat.st_mtime != allow_mtime)
+		changed = 1;
+	else if (dstat.st_mtime != deny_mtime)
+		changed = 1;
+
+	allow_mtime = astat.st_mtime;
+	deny_mtime = dstat.st_mtime;
+
+	return changed;
+}
+
 /* check_default - additional checks for NULL, DUMP, GETPORT and unknown */
 
 int
@@ -256,20 +286,27 @@ u_long  proc;
 u_long  prog;
 {
 	haccess_t *acc = NULL;
+	int changed = check_files();
 
 	acc = haccess_lookup(addr, proc, prog);
-	if (acc)
+	if (acc && changed == 0)
 		return (acc->access);
 
 	if (!(from_local(addr) || good_client(daemon, addr))) {
 		log_bad_host(addr, proc, prog);
-		haccess_add(addr, proc, prog, FALSE);
+		if (acc)
+			acc->access = FALSE;
+		else 
+			haccess_add(addr, proc, prog, FALSE);
 		return (FALSE);
 	}
 	if (verboselog)
 		log_client(addr, proc, prog);
 
-	haccess_add(addr, proc, prog, TRUE);
+	if (acc)
+		acc->access = TRUE;
+	else 
+		haccess_add(addr, proc, prog, TRUE);
     return (TRUE);
 }
 
