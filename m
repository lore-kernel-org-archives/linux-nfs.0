From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils: -o remout uses unallocated memory
Date: Wed, 25 Oct 2006 13:55:31 -0400
Message-ID: <453FA513.5020905@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020007070301050401080202"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcmyV-0002C0-J1
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 10:55:36 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcmyW-0003hk-4g
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 10:55:36 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9PHtWhx027021
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 13:55:32 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9PHtVRs026994
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 13:55:31 -0400
Received: from [10.12.32.32] (dickson.boston.devel.redhat.com [10.12.32.32])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	k9PHtVoO009051
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 13:55:31 -0400
To: nfs@lists.sourceforge.net
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
--------------020007070301050401080202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------020007070301050401080202
Content-Type: text/x-patch;
 name="nfs-utils-1.0.10-mount-remount.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.10-mount-remount.patch"

This patch stops -o reomount from using unallocated
memory and turns back on the call to the sys_mount.
Granted NFS does not support remounts, but I still
think its a good idea to make the syscall... 

That patch also ensures that the mount version is 
set correctly... 

The patch is against nfs-utils-1.0.10.

Signed-off-by: Steve Dickson <steved@redhat.com>
------------------------------

--- nfs-utils-1.0.9/utils/mount/mount.c.orig	2006-10-25 10:52:32.000000000 -0400
+++ nfs-utils-1.0.9/utils/mount/mount.c	2006-10-25 12:09:52.000000000 -0400
@@ -163,16 +163,29 @@ static char * fix_opts_string (int flags
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
+free_mntent(struct mntent *ment, int remount)
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
@@ -190,8 +203,9 @@ int add_mtab(char *fsname, char *mount_p
 	if(flags & MS_REMOUNT) {
 		nfs_mntent_t nment;
 		
-		copy_mntent(&ment, &nment);
+		dup_mntent(&ment, &nment);
 		update_mtab(nment.mnt_dir, &nment);
+		free_mntent(&nment, 1);
 		return 0;
 	}
 
@@ -341,10 +355,11 @@ static void mount_error(char *node)
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
@@ -375,6 +390,10 @@ int main(int argc, char *argv[])
 		return 0;
 	}
 
+	nfs_mount_vers = NFS_MOUNT_VERS_DEFAULT;
+	if (!strcmp(progname, "mount.nfs4"))
+		nfs_mount_vers = 4;
+
 	while ((c = getopt_long (argc - 2, argv + 2, "rt:vVwfno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
@@ -465,9 +484,9 @@ int main(int argc, char *argv[])
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
@@ -475,21 +494,19 @@ int main(int argc, char *argv[])
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
-
-		if(mnt_err) {
-			mount_error(mount_point);
-			exit(EX_FAIL);
-		}
+	mnt_err = do_mount_syscall(spec, mount_point,
+			nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
+
+	if(mnt_err) {
+		mount_error(mount_point);
+		exit(EX_FAIL);
 	}
+
 	if(!nomtab) {
 		add_mtab(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs",
 			 flags, extra_opts, 0, 0);

--------------020007070301050401080202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------020007070301050401080202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020007070301050401080202--
