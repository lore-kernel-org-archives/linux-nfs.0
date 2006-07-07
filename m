From: Amit Gud <agud@redhat.com>
Subject: [PATCH] Fix NFS mount options in mount.nfs
Date: Fri, 07 Jul 2006 13:45:43 -0400
Message-ID: <44AE9DC7.4050606@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090504040208050603050609"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	sesse@debian.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyuLF-0005gk-9J
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 10:42:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyuLD-0002t8-0l
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 10:42:13 -0700
To: Neil Brown <neilb@suse.de>
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
--------------090504040208050603050609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


--------------090504040208050603050609
Content-Type: text/plain;
 name="fix-mount-options.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-mount-options.patch"

Fix NFS mount options.


Signed-off-by: Amit Gud <agud@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>

---
diff -uprN -X dontdiff nfs-utils/utils/mount/Makefile.am nfs-utils-ag/utils/mount/Makefile.am
--- nfs-utils/utils/mount/Makefile.am	2006-07-02 17:34:58.000000000 -0400
+++ nfs-utils-ag/utils/mount/Makefile.am	2006-07-07 13:15:44.000000000 -0400
@@ -14,9 +14,10 @@ MAINTAINERCLEANFILES = Makefile.in
 
 install-exec-hook:
 	(cd $(DESTDIR)$(sbindir) && \
-	  ln -sf $(sbin_PROGRAMS) mount.nfs4 && \
-	  ln -sf $(sbin_PROGRAMS) umount.nfs && \
-	  ln -sf $(sbin_PROGRAMS) umount.nfs4)
+	  chmod +s $(sbin_PROGRAMS) && \
+	  cp $(sbin_PROGRAMS) /sbin/mount.nfs4 && \
+	  cp $(sbin_PROGRAMS) /sbin/umount.nfs && \
+	  cp $(sbin_PROGRAMS) /sbin/umount.nfs4)
 uninstall-hook:
 	(cd $(DESTDIR)$(sbindir) && \
 	    rm -f mount.nfs4 umount.nfs umount.nfs4)
diff -uprN -X dontdiff nfs-utils/utils/mount/mount.c nfs-utils-ag/utils/mount/mount.c
--- nfs-utils/utils/mount/mount.c	2006-07-02 17:34:58.000000000 -0400
+++ nfs-utils-ag/utils/mount/mount.c	2006-07-07 12:49:41.000000000 -0400
@@ -28,6 +28,7 @@
 #include <sys/mount.h>
 #include <getopt.h>
 #include <mntent.h>
+#include <pwd.h>
 
 #include "fstab.h"
 #include "xcommon.h"
@@ -74,6 +75,14 @@ struct opt_map {
   int  mask;                    /* flag mask value */
 };
 
+/* Custom mount options for our own purposes.  */
+/* Maybe these should now be freed for kernel use again */
+#define MS_DUMMY	0x00000000
+#define MS_USERS	0x40000000
+#define MS_USER		0x20000000
+#define MS_OWNER	0x10000000
+#define MS_GROUP	0x08000000
+
 static const struct opt_map opt_map[] = {
   { "defaults", 0, 0, 0         },      /* default options */
   { "ro",       1, 0, MS_RDONLY },      /* read-only */
@@ -90,6 +99,18 @@ static const struct opt_map opt_map[] = 
   { "remount",  0, 0, MS_REMOUNT},      /* Alter flags of mounted FS */
   { "bind",     0, 0, MS_BIND   },      /* Remount part of tree elsewhere */
   { "rbind",    0, 0, MS_BIND|MS_REC }, /* Idem, plus mounted subtrees */
+  { "auto",     0, 0, MS_DUMMY },      /* Can be mounted using -a */
+  { "noauto",   0, 0, MS_DUMMY },      /* Can  only be mounted explicitly */
+  { "users",    0, 0, MS_USERS  },      /* Allow ordinary user to mount */
+  { "nousers",  0, 0, MS_USERS  },      /* Forbid ordinary user to mount */
+  { "user",     0, 0, MS_USER   },      /* Allow ordinary user to mount */
+  { "nouser",   0, 0, MS_USER   },      /* Forbid ordinary user to mount */
+  { "owner",    0, 0, MS_OWNER  },      /* Let the owner of the device mount */
+  { "noowner",  0, 0, MS_OWNER  },      /* Device owner has no special privs */
+  { "group",    0, 0, MS_GROUP  },      /* Let the group of the device mount */
+  { "nogroup",  0, 0, MS_GROUP  },      /* Device group has no special privs */
+  { "_netdev",  0, 0, MS_DUMMY},      /* Device requires network */
+  { "comment",  0, 0, MS_DUMMY},      /* fstab comment only (kudzu,_netdev)*/
 
   /* add new options here */
 #ifdef MS_NOSUB
@@ -104,6 +125,7 @@ static const struct opt_map opt_map[] = 
   { "mand",     0, 0, MS_MANDLOCK },    /* Allow mandatory locks on this FS */
   { "nomand",   0, 1, MS_MANDLOCK },    /* Forbid mandatory locks on this FS */
 #endif
+  { "loop",     1, 0, MS_DUMMY   },      /* use a loop device */
 #ifdef MS_NOATIME
   { "atime",    0, 1, MS_NOATIME },     /* Update access time */
   { "noatime",  0, 0, MS_NOATIME },     /* Do not update access time */
@@ -121,6 +143,12 @@ static char * fix_opts_string (int flags
 	char *new_opts;
 
 	new_opts = xstrdup((flags & MS_RDONLY) ? "ro" : "rw");
+	if (flags & MS_USER) {
+		struct passwd *pw = getpwuid(getuid());
+		if(pw)
+			new_opts = xstrconcat3(new_opts, ",user=", pw->pw_name);
+	}
+	
 	for (om = opt_map; om->opt != NULL; om++) {
 		if (om->skip)
 			continue;
@@ -132,9 +160,20 @@ static char * fix_opts_string (int flags
 	if (extra_opts && *extra_opts) {
 		new_opts = xstrconcat3(new_opts, ",", extra_opts);
 	}
+
 	return new_opts;
 }
 
+void copy_mntent(struct mntent *ment, nfs_mntent_t *nment)
+{
+	/* Not sure why nfs_mntent_t should exist */
+	strcpy(nment->mnt_fsname, ment->mnt_fsname);
+	strcpy(nment->mnt_dir, ment->mnt_dir);
+	strcpy(nment->mnt_type, ment->mnt_type);
+	strcpy(nment->mnt_opts, ment->mnt_opts);
+	nment->mnt_freq = ment->mnt_freq;
+	nment->mnt_passno = ment->mnt_passno;
+}
 
 int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, char *opts, int freq, int passno)
 {
@@ -146,8 +185,16 @@ int add_mtab(char *fsname, char *mount_p
 	ment.mnt_dir = mount_point;
 	ment.mnt_type = fstype;
 	ment.mnt_opts = fix_opts_string(flags, opts);
-	ment.mnt_freq = 0;
-	ment.mnt_passno= 0;
+	ment.mnt_freq = freq;
+	ment.mnt_passno= passno;
+
+	if(flags & MS_REMOUNT) {
+		nfs_mntent_t nment;
+		
+		copy_mntent(&ment, &nment);
+		update_mtab(nment.mnt_dir, &nment);
+		return 0;
+	}
 
 	if ((fd = open(MOUNTED"~", O_RDWR|O_CREAT|O_EXCL, 0600)) == -1)	{
 		fprintf(stderr, "Can't get "MOUNTED"~ lock file");
@@ -246,16 +293,16 @@ static void mount_error(char *node)
 {
 	switch(errno) {
 		case ENOTDIR:
-			printf("%s: mount point %s is not a directory\n", progname, node);
+			fprintf(stderr, "%s: mount point %s is not a directory\n", progname, node);
 			break;
 		case EBUSY:
-			printf("%s: %s is already mounted or busy\n", progname, node);
+			fprintf(stderr, "%s: %s is already mounted or busy\n", progname, node);
 			break;
 		case ENOENT:
-			printf("%s: mount point %s does not exist\n", progname, node);
+			fprintf(stderr, "%s: mount point %s does not exist\n", progname, node);
 			break;
 		default:
-			printf("%s: %s\n", progname, strerror(errno));
+			fprintf(stderr, "%s: %s\n", progname, strerror(errno));
 	}
 }
 
@@ -269,11 +316,6 @@ int main(int argc, char *argv[])
 	if ((p = strrchr(progname, '/')) != NULL)
 		progname = p+1;
 
-	if (getuid() != 0) {
-		printf("%s: only root can do that.\n", progname);
-		exit(1);
-	}
-
 	if(!strncmp(progname, "umount", strlen("umount"))) {
 		if(argc < 2) {
 			umount_usage();
@@ -358,6 +400,11 @@ int main(int argc, char *argv[])
 	
 	parse_opts(mount_opts, &flags, &extra_opts);
 
+	if (getuid() != 0 && !(flags & MS_USERS) && !(flags & MS_USER)) {
+		fprintf(stderr, "%s: permission denied.\n", progname);
+		exit(1);
+	}
+
 	if (!strcmp(progname, "mount.nfs4") || nfs_mount_vers == 4) {
 		nfs_mount_vers = 4;
 		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
@@ -370,16 +417,19 @@ int main(int argc, char *argv[])
 	}
 
 	if (!mnt_err && !fake) {
-		mnt_err = do_mount_syscall(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
+		if(!(flags & MS_REMOUNT)) {
+			mnt_err = do_mount_syscall(spec, mount_point,
+					nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
 		
-		if(mnt_err) {
-			mount_error(mount_point);
-			exit(-1);
+			if(mnt_err) {
+				mount_error(mount_point);
+				exit(-1);
+			}
 		}
-
-		if(!nomtab)
+		if(!nomtab) {
 			add_mtab(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs",
 				 flags, extra_opts, 0, 0);
+		}
 	}
 
 	return 0;
diff -uprN -X dontdiff nfs-utils/utils/mount/nfsumount.c nfs-utils-ag/utils/mount/nfsumount.c
--- nfs-utils/utils/mount/nfsumount.c	2006-07-02 17:34:58.000000000 -0400
+++ nfs-utils-ag/utils/mount/nfsumount.c	2006-07-07 12:49:41.000000000 -0400
@@ -23,6 +23,7 @@
 #include <mntent.h>
 #include <sys/mount.h>
 #include <ctype.h>
+#include <pwd.h>
 
 #include "xcommon.h"
 #include "fstab.h"
@@ -156,6 +157,42 @@ static void complain(int err, const char
   }
 }
 
+/*
+ * Look for an option in a comma-separated list
+ */
+static int
+contains(const char *list, const char *s) {
+	int n = strlen(s);
+
+	while (*list) {
+		if (strncmp(list, s, n) == 0 &&
+		  (list[n] == 0 || list[n] == ','))
+			return 1;
+		while (*list && *list++ != ',') ;
+	}
+	return 0;
+}
+
+/*
+ * If list contains "user=peter" and we ask for "user=", return "peter"
+ */
+static char *
+get_value(const char *list, const char *s) {
+	const char *t;
+	int n = strlen(s);
+
+	while (*list) {
+		if (strncmp(list, s, n) == 0) {
+			s = t = list+n;
+			while (*s && *s != ',')
+				s++;
+			return xstrndup(t, s-t);
+		}
+		while (*list && *list++ != ',') ;
+	}
+	return 0;
+}
+
 int add_mtab2(const char *spec, const char *node, const char *type,
 		const char *opts, struct mntentchn *mc)
 {
@@ -307,7 +344,7 @@ int _nfsumount(const char *spec, const c
 		goto out_bad;
 	return nfs_call_umount(&mnt_server, &dirname);
  out_bad:
-	printf("%s: %s: not found or not mounted\n", progname, spec);
+	fprintf(stderr, "%s: %s: not found or not mounted\n", progname, spec);
 	return 0;
 }
 
@@ -376,6 +413,21 @@ int nfsumount(int argc, char *argv[])
 		printf(_("Could not find %s in mtab\n"), spec);
 
 	if(mc) {
+		if(contains(mc->m.mnt_opts, "user") && getuid() != 0) {
+			struct passwd *pw = getpwuid(getuid());
+			if(!pw || strcmp(pw->pw_name, get_value(mc->m.mnt_opts, "user="))) {
+				fprintf(stderr, "%s: permission denied to unmount %s\n",
+						progname, spec);
+				exit(1);
+			}
+		} else {
+			if(!contains(mc->m.mnt_opts, "users") && getuid() != 0) {
+				fprintf(stderr, "%s: only root can unmount %s from %s\n",
+						progname, mc->m.mnt_fsname, mc->m.mnt_dir);
+				exit(1);
+			}
+		}
+
 		ret = _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
 		if(ret)
 			ret = add_mtab2(mc->m.mnt_fsname, mc->m.mnt_dir,

--------------090504040208050603050609
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------090504040208050603050609
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090504040208050603050609--
