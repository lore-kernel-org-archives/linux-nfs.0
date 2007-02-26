From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 01/11] nfs-utils: mount: non-nfs mount options
Date: Mon, 26 Feb 2007 06:17:21 -0500
Message-ID: <45E2C1C1.9050302@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070008010903040509040908"
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdoc-0000C8-PZ
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:14:46 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdoe-00069v-36
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:14:48 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBEloW000490
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:47 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBEls7005402
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:47 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBEjvL025452
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:46 -0500
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
--------------070008010903040509040908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070008010903040509040908
Content-Type: text/x-patch;
 name="patch-01.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-01.dif"

commit 806b02f63fe6e01946d84a1f14c74e977be76530
Author: Amit Gud <agud@redhat.com>
Date:   Sat Feb 24 14:31:13 2007 -0500

    Added the following non-nfs mount options as suggested
    but upstream code reviews:
    
        [no]auto, [no]users, [no]user, [no]owner, [no]group
    	    _netdev, comment
    
    Signed-off-by: Amit Gud <agud@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/include/fstab.h b/support/include/fstab.h
index 52af743..1134a2a 100644
--- a/support/include/fstab.h
+++ b/support/include/fstab.h
@@ -3,6 +3,10 @@
 
 #include "nfs_mntent.h"
 
+#ifndef _PATH_FSTAB
+#define _PATH_FSTAB "/etc/fstab"
+#endif
+
 int mtab_is_writable(void);
 int mtab_does_not_exist(void);
 
@@ -16,6 +20,10 @@ struct mntentchn *getmntoptfile (const char *file);
 struct mntentchn *getmntdirbackward (const char *dir, struct mntentchn *mc);
 struct mntentchn *getmntdevbackward (const char *dev, struct mntentchn *mc);
 
+struct mntentchn *fstab_head (void);
+struct mntentchn *getfsfile (const char *file);
+struct mntentchn *getfsspec (const char *spec);
+
 void lock_mtab (void);
 void unlock_mtab (void);
 void update_mtab (const char *special, nfs_mntent_t *with);
diff --git a/support/include/nfs_mntent.h b/support/include/nfs_mntent.h
index 76f348e..ec5dfd4 100644
--- a/support/include/nfs_mntent.h
+++ b/support/include/nfs_mntent.h
@@ -7,10 +7,10 @@
 #define _NFS_MNTENT_H
 
 typedef struct nfs_mntent_s {
-	const char *mnt_fsname;
-	const char *mnt_dir;
-	const char *mnt_type;
-	const char *mnt_opts;
+	char *mnt_fsname;
+	char *mnt_dir;
+	char *mnt_type;
+	char *mnt_opts;
 	int mnt_freq;
 	int mnt_passno;
 } nfs_mntent_t;
diff --git a/support/nfs/fstab.c b/support/nfs/fstab.c
index 8dc7d66..a9cbdf3 100644
--- a/support/nfs/fstab.c
+++ b/support/nfs/fstab.c
@@ -78,10 +78,10 @@ mtab_is_writable() {
 
 /* Contents of mtab and fstab ---------------------------------*/
 
-struct mntentchn mounttable;
-static int got_mtab = 0;
+struct mntentchn mounttable, fstab;
+static int got_mtab = 0, got_fstab = 0;
 
-static void read_mounttable(void);
+static void read_mounttable(void), read_fstab(void);
 
 struct mntentchn *
 mtab_head() {
@@ -96,6 +96,13 @@ my_free(const void *s) {
 		free((void *) s);
 }
 
+struct mntentchn *
+fstab_head() {
+	if (!got_fstab)
+		read_fstab();
+	return &fstab;
+}
+
 static void
 discard_mntentchn(struct mntentchn *mc0) {
 	struct mntentchn *mc, *mc1;
@@ -167,6 +174,26 @@ read_mounttable() {
         read_mntentchn(mfp, fnam, mc);
 }
 
+static void
+read_fstab() {
+	mntFILE *mfp = NULL;
+	const char *fnam;
+	struct mntentchn *mc = &fstab;
+
+	got_fstab = 1;
+	mc->nxt = mc->prev = NULL;
+
+	fnam = _PATH_FSTAB;
+	mfp = nfs_setmntent (fnam, "r");
+	if (mfp == NULL || mfp->mntent_fp == NULL) {
+		int errsv = errno;
+		error(_("warning: can't open %s: %s"),
+			_PATH_FSTAB, strerror (errsv));
+		return;
+	}
+	read_mntentchn(mfp, fnam, mc);
+}
+
 /*
  * Given the directory name NAME, and the place MCPREV we found it last time,
  * try to find more occurrences.
@@ -201,6 +228,30 @@ getmntdevbackward (const char *name, struct mntentchn *mcprev) {
 	return NULL;
 }
 
+/* Find the dir FILE in fstab.  */
+struct mntentchn *
+getfsfile (const char *file) {
+	struct mntentchn *mc, *mc0;
+
+	mc0 = fstab_head();
+	for (mc = mc0->nxt; mc && mc != mc0; mc = mc->nxt)
+		if (streq(mc->m.mnt_dir, file))
+			return mc;
+	return NULL;
+}
+
+/* Find the device SPEC in fstab.  */
+struct mntentchn *
+getfsspec (const char *spec) {
+	struct mntentchn *mc, *mc0;
+
+	mc0 = fstab_head();
+	for (mc = mc0->nxt; mc && mc != mc0; mc = mc->nxt)
+		if (streq(mc->m.mnt_fsname, spec))
+			return mc;
+	return NULL;
+}
+
 /* Updating mtab ----------------------------------------------*/
 
 /* Flag for already existing lock file. */
diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 4a2f437..1fbbd1d 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -14,9 +14,10 @@ MAINTAINERCLEANFILES = Makefile.in
 
 install-exec-hook:
 	(cd $(DESTDIR)$(sbindir) && \
-	  ln -sf $(sbin_PROGRAMS) mount.nfs4 && \
-	  ln -sf $(sbin_PROGRAMS) umount.nfs && \
-	  ln -sf $(sbin_PROGRAMS) umount.nfs4)
+	  chmod +s $(sbin_PROGRAMS) && \
+	  cp -p $(sbin_PROGRAMS) $(DESTDIR)$(sbindir)/mount.nfs4 && \
+	  cp -p $(sbin_PROGRAMS) $(DESTDIR)$(sbindir)/umount.nfs && \
+	  cp -p $(sbin_PROGRAMS) $(DESTDIR)$(sbindir)/umount.nfs4)
 uninstall-hook:
 	(cd $(DESTDIR)$(sbindir) && \
 	    rm -f mount.nfs4 umount.nfs umount.nfs4)
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 5e0e599..05ff90f 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -28,6 +28,7 @@
 #include <sys/mount.h>
 #include <getopt.h>
 #include <mntent.h>
+#include <pwd.h>
 
 #include "fstab.h"
 #include "xcommon.h"
@@ -74,6 +75,12 @@ struct opt_map {
   int  mask;                    /* flag mask value */
 };
 
+/* Custom mount options for our own purposes.  */
+/* Maybe these should now be freed for kernel use again */
+#define MS_DUMMY	0x00000000
+#define MS_USERS	0x40000000
+#define MS_USER		0x20000000
+
 static const struct opt_map opt_map[] = {
   { "defaults", 0, 0, 0         },      /* default options */
   { "ro",       1, 0, MS_RDONLY },      /* read-only */
@@ -90,6 +97,18 @@ static const struct opt_map opt_map[] = {
   { "remount",  0, 0, MS_REMOUNT},      /* Alter flags of mounted FS */
   { "bind",     0, 0, MS_BIND   },      /* Remount part of tree elsewhere */
   { "rbind",    0, 0, MS_BIND|MS_REC }, /* Idem, plus mounted subtrees */
+  { "auto",     0, 0, MS_DUMMY },       /* Can be mounted using -a */
+  { "noauto",   0, 0, MS_DUMMY },       /* Can  only be mounted explicitly */
+  { "users",    0, 0, MS_USERS  },      /* Allow ordinary user to mount */
+  { "nousers",  0, 1, MS_USERS  },      /* Forbid ordinary user to mount */
+  { "user",     0, 0, MS_USER   },      /* Allow ordinary user to mount */
+  { "nouser",   0, 1, MS_USER   },      /* Forbid ordinary user to mount */
+  { "owner",    0, 0, MS_DUMMY  },      /* Let the owner of the device mount */
+  { "noowner",  0, 0, MS_DUMMY  },      /* Device owner has no special privs */
+  { "group",    0, 0, MS_DUMMY  },      /* Let the group of the device mount */
+  { "nogroup",  0, 0, MS_DUMMY  },      /* Device group has no special privs */
+  { "_netdev",  0, 0, MS_DUMMY},        /* Device requires network */
+  { "comment",  0, 0, MS_DUMMY},        /* fstab comment only (kudzu,_netdev)*/
 
   /* add new options here */
 #ifdef MS_NOSUB
@@ -104,6 +123,7 @@ static const struct opt_map opt_map[] = {
   { "mand",     0, 0, MS_MANDLOCK },    /* Allow mandatory locks on this FS */
   { "nomand",   0, 1, MS_MANDLOCK },    /* Forbid mandatory locks on this FS */
 #endif
+  { "loop",     1, 0, MS_DUMMY   },      /* use a loop device */
 #ifdef MS_NOATIME
   { "atime",    0, 1, MS_NOATIME },     /* Update access time */
   { "noatime",  0, 0, MS_NOATIME },     /* Do not update access time */
@@ -121,6 +141,12 @@ static char * fix_opts_string (int flags, const char *extra_opts) {
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
@@ -132,9 +158,20 @@ static char * fix_opts_string (int flags, const char *extra_opts) {
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
@@ -146,8 +183,16 @@ int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, char *opt
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
 
 	lock_mtab();
 
@@ -239,20 +284,56 @@ static void parse_opts (const char *options, int *flags, char **extra_opts)
 
 }
 
+/*
+ * Look for an option in a comma-separated list
+ */
+int
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
+char *
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
 static void mount_error(char *node)
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
 
@@ -261,16 +342,13 @@ int main(int argc, char *argv[])
 	int c, flags = 0, nfs_mount_vers = 0, mnt_err = 1, fake = 0;
 	char *spec, *mount_point, *extra_opts = NULL;
 	char *mount_opts = NULL, *p;
+	struct mntentchn *mc;
+	uid_t uid = getuid();
 
 	progname = argv[0];
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
@@ -352,9 +430,33 @@ int main(int argc, char *argv[])
 
 	spec = argv[1];
 	mount_point = canonicalize(argv[2]);
-	
+
 	parse_opts(mount_opts, &flags, &extra_opts);
 
+	if (uid != 0 && !(flags & MS_USERS) && !(flags & MS_USER)) {
+		fprintf(stderr, "%s: permission denied\n", progname);
+		exit(1);
+	}
+
+	if ((flags & MS_USER || flags & MS_USERS) && uid != 0) {
+		/* check if fstab has entry, and further see if the user or users option is given */
+		if ((mc = getfsspec(spec)) == NULL &&
+		    (mc = getfsfile(spec)) == NULL) {
+			fprintf(stderr, "%s: permission denied - invalid option\n", progname);
+			exit(1);
+		}
+		else {
+			if((flags & MS_USER) && !contains(mc->m.mnt_opts, "user")) {
+				fprintf(stderr, "%s: permission denied - invalid option\n", progname);
+				exit(1);
+			}
+			if((flags & MS_USERS) && !contains(mc->m.mnt_opts, "users")) {
+				fprintf(stderr, "%s: permission denied - invalid option\n", progname);
+				exit(1);
+			}
+		}
+	}
+
 	if (!strcmp(progname, "mount.nfs4") || nfs_mount_vers == 4) {
 		nfs_mount_vers = 4;
 		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
@@ -367,16 +469,19 @@ int main(int argc, char *argv[])
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
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 1fd74c8..2200362 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -80,5 +80,7 @@ struct nfs_mount_data {
 
 int nfsmount(const char *, const char *, int *, char **, char **, int *, int);
 void mount_errors(char *, int, int);
+int contains(const char *, const char *);
+char *get_value(const char *, const char *);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 28f4244..dfbcb7c 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -23,12 +23,14 @@
 #include <mntent.h>
 #include <sys/mount.h>
 #include <ctype.h>
+#include <pwd.h>
 
 #include "xcommon.h"
 #include "fstab.h"
 #include "nls.h"
 #include "conn.h"
 
+#include "nfs_mount.h"
 #include "mount_constants.h"
 #include "mount.h"
 #include "nfsumount.h"
@@ -307,7 +309,7 @@ int _nfsumount(const char *spec, const char *opts)
 		goto out_bad;
 	return nfs_call_umount(&mnt_server, &dirname);
  out_bad:
-	printf("%s: %s: not found or not mounted\n", progname, spec);
+	fprintf(stderr, "%s: %s: not found or not mounted\n", progname, spec);
 	return 0;
 }
 
@@ -376,6 +378,21 @@ int nfsumount(int argc, char *argv[])
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

--------------070008010903040509040908
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070008010903040509040908
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070008010903040509040908--
