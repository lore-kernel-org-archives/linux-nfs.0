From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 10/11] nfs-utils: mount: Stop v4 umounts from ping
 remote mountds
Date: Mon, 26 Feb 2007 06:19:06 -0500
Message-ID: <45E2C22A.6090706@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040000090405090408010001"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdqL-0000RV-7i
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:16:33 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdqM-0006jd-0a
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:16:35 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBGXx5001304
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:33 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBGXsK005853
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:33 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBGVWs025626
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:32 -0500
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

This is a multi-part message in MIME format.
--------------040000090405090408010001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------040000090405090408010001
Content-Type: text/x-patch;
 name="patch-10.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-10.dif"

commit 7f9cc56de079b1c53f912fc2abe31203e79782f4
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Feb 24 16:18:22 2007 -0500

    Stop v4 umounts from ping remote mountds
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 5894e3a..bb06341 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -19,6 +19,7 @@
 
 #include <stdio.h>
 #include <errno.h>
+#include <unistd.h>
 #include <getopt.h>
 #include <mntent.h>
 #include <sys/mount.h>
@@ -333,7 +334,7 @@ void umount_usage()
 
 int nfsumount(int argc, char *argv[])
 {
-	int c, ret;
+	int c, ret, v4=0;
 	char *spec;
 	struct mntentchn *mc;
 
@@ -371,39 +372,33 @@ int nfsumount(int argc, char *argv[])
 	mc = getmntdirbackward(spec, NULL);
 	if (!mc)
 		mc = getmntdevbackward(spec, NULL);
-	if (!mc && verbose)
-		printf(_("Could not find %s in mtab\n"), spec);
-
-	if(mc) {
-		if(contains(mc->m.mnt_opts, "user") && getuid() != 0) {
-			struct passwd *pw = getpwuid(getuid());
-			if(!pw || strcmp(pw->pw_name, get_value(mc->m.mnt_opts, "user="))) {
-				fprintf(stderr, "%s: permission denied to unmount %s\n",
-						progname, spec);
-				exit(1);
-			}
-		} else {
-			if(!contains(mc->m.mnt_opts, "users") && getuid() != 0) {
-				fprintf(stderr, "%s: only root can unmount %s from %s\n",
-						progname, mc->m.mnt_fsname, mc->m.mnt_dir);
-				exit(1);
-			}
-		}
-
-		ret = 0;
-		if(!force && !lazy)
-			ret = _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
-		if(!ret)
-			ret = add_mtab2(mc->m.mnt_fsname, mc->m.mnt_dir,
-				mc->m.mnt_type, mc->m.mnt_opts, mc);
+	if (mc == NULL) {
+		fprintf(stderr, "%s: Unable to find '%s' in mount table\n",
+				progname, spec);
+		exit(1);
 	}
-	else {
-		ret = 0;
-		if(!force && !lazy)
-			ret = _nfsumount(spec, NULL);
-		if(!ret)
-			ret = add_mtab2(spec, spec, spec, spec, NULL);
+	if(contains(mc->m.mnt_opts, "user") && getuid() != 0) {
+		struct passwd *pw = getpwuid(getuid());
+		if(!pw || strcmp(pw->pw_name, get_value(mc->m.mnt_opts, "user="))) {
+			fprintf(stderr, "%s: permission denied to unmount %s\n",
+					progname, spec);
+			exit(1);
+		}
+	} else {
+		if(!contains(mc->m.mnt_opts, "users") && getuid() != 0) {
+			fprintf(stderr, "%s: only root can unmount %s from %s\n",
+					progname, mc->m.mnt_fsname, mc->m.mnt_dir);
+			exit(1);
+		}
 	}
+	v4 = contains(mc->m.mnt_type, "nfs4");
+
+	ret = 0;
+	if(!force && !lazy && !v4)
+		ret = _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
+	if(!ret)
+		ret = add_mtab2(mc->m.mnt_fsname, mc->m.mnt_dir,
+			mc->m.mnt_type, mc->m.mnt_opts, mc);
 
 	return(ret);
 }

--------------040000090405090408010001
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------040000090405090408010001
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040000090405090408010001--
