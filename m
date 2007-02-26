From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 07/11] nfs-utils: mount: Fixed -o remount
Date: Mon, 26 Feb 2007 06:18:32 -0500
Message-ID: <45E2C208.7020804@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080305020903030108080507"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdpl-0000Ko-1n
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:57 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdpm-0006TX-M8
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:59 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFwqB001011
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:58 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFvDK005747
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:57 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBFuAg025594
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:57 -0500
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
--------------080305020903030108080507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------080305020903030108080507
Content-Type: text/x-patch;
 name="patch-07.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-07.dif"

commit d507c76527acc3415395cd70cc08d02e32dbe181
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Feb 24 15:56:54 2007 -0500

    Stop remounts (i.e. -o remount) from dropping core.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 8440055..00aee61 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -163,16 +163,29 @@ static char * fix_opts_string (int flags, const char *extra_opts) {
 	return new_opts;
 }
 
-void copy_mntent(struct mntent *ment, nfs_mntent_t *nment)
+static inline void dup_mntent(struct mntent *ment, nfs_mntent_t *nment)
 {
 	/* Not sure why nfs_mntent_t should exist */
-	strcpy(nment->mnt_fsname, ment->mnt_fsname);
-	strcpy(nment->mnt_dir, ment->mnt_dir);
-	strcpy(nment->mnt_type, ment->mnt_type);
-	strcpy(nment->mnt_opts, ment->mnt_opts);
+	nment->mnt_fsname = strdup(ment->mnt_fsname);
+	nment->mnt_dir = strdup(ment->mnt_dir);
+	nment->mnt_type = strdup(ment->mnt_type);
+	nment->mnt_opts = strdup(ment->mnt_opts);
 	nment->mnt_freq = ment->mnt_freq;
 	nment->mnt_passno = ment->mnt_passno;
 }
+static inline void 
+free_mntent(nfs_mntent_t *ment, int remount)
+{
+	free(ment->mnt_fsname);
+	free(ment->mnt_dir);
+	free(ment->mnt_type);
+	/* 
+	 * Note: free(ment->mnt_opts) happens in discard_mntentchn()
+	 * via update_mtab() on remouts
+	 */
+	 if (!remount)
+	 	free(ment->mnt_opts);
+}
 
 int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, char *opts, int freq, int passno)
 {
@@ -189,8 +202,9 @@ int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, char *opt
 	if(flags & MS_REMOUNT) {
 		nfs_mntent_t nment;
 		
-		copy_mntent(&ment, &nment);
+		dup_mntent(&ment, &nment);
 		update_mtab(nment.mnt_dir, &nment);
+		free_mntent(&nment, 1);
 		return 0;
 	}
 
@@ -337,10 +351,11 @@ static void mount_error(char *node)
 			fprintf(stderr, "%s: %s\n", progname, strerror(errno));
 	}
 }
+#define NFS_MOUNT_VERS_DEFAULT 3
 
 int main(int argc, char *argv[])
 {
-	int c, flags = 0, nfs_mount_vers = 0, mnt_err = 1, fake = 0;
+	int c, flags = 0, nfs_mount_vers, mnt_err = 1, fake = 0;
 	char *spec, *mount_point, *extra_opts = NULL;
 	char *mount_opts = NULL, *p;
 	struct mntentchn *mc;
@@ -371,6 +386,10 @@ int main(int argc, char *argv[])
 		return 0;
 	}
 
+	nfs_mount_vers = NFS_MOUNT_VERS_DEFAULT;
+	if (!strcmp(progname, "mount.nfs4"))
+		nfs_mount_vers = 4;
+
 	while ((c = getopt_long (argc - 2, argv + 2, "rt:vVwfno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
@@ -461,9 +480,9 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (!strcmp(progname, "mount.nfs4") || nfs_mount_vers == 4) {
-		nfs_mount_vers = 4;
-		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
+	if (nfs_mount_vers == 4) {
+		mnt_err = nfs4mount(spec, mount_point, &flags, 
+			&extra_opts, &mount_opts, 0);
 	}
 	else {
 		if (!strcmp(progname, "mount.nfs")) {
@@ -471,21 +490,19 @@ int main(int argc, char *argv[])
 					&extra_opts, &mount_opts, &nfs_mount_vers, 0);
 		}
 	}
-
 	if (fake)
 		return 0;
 	if (mnt_err)
 		exit(EX_FAIL);
 
-	if(!(flags & MS_REMOUNT)) {
-		mnt_err = do_mount_syscall(spec, mount_point,
-				nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
+	mnt_err = do_mount_syscall(spec, mount_point,
+			nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
 
-		if(mnt_err) {
-			mount_error(mount_point);
-			exit(EX_FAIL);
-		}
+	if(mnt_err) {
+		mount_error(mount_point);
+		exit(EX_FAIL);
 	}
+
 	if(!nomtab) {
 		add_mtab(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs",
 			 flags, extra_opts, 0, 0);

--------------080305020903030108080507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080305020903030108080507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080305020903030108080507--
