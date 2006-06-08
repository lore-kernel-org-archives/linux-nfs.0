From: Amit Gud <agud@redhat.com>
Subject: [PATCH 1 / 2] Move NFS mount code from util-linux to nfs-utils
Date: Thu, 08 Jun 2006 15:10:32 -0400
Message-ID: <44887628.5020901@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010301040808030501080808"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoPqp-0003uD-R3
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 12:07:28 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FoPqo-0001FE-Dq
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 12:07:28 -0700
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
--------------010301040808030501080808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


--------------010301040808030501080808
Content-Type: text/plain;
 name="nfsmount-migration-to-nfsutils-v2.patch"
Content-Disposition: inline; filename="nfsmount-migration-to-nfsutils-v2.patch"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mx1.redhat.com id
	k58J7HJw011138

Adds the mount directory and the code to mount and umount the NFS file sy=
stem.


Signed-off-by: Amit Gud <agud@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>

---
diff -uprN nfs-utils-1.0.8/utils/Makefile.am nfs-utils-1.0.8-ag/utils/Mak=
efile.am
--- nfs-utils-1.0.8/utils/Makefile.am	2006-03-26 19:30:08.000000000 -0500
+++ nfs-utils-1.0.8-ag/utils/Makefile.am	2006-06-08 11:22:22.096815000 -0=
400
@@ -17,6 +17,7 @@ endif
 SUBDIRS =3D \
 	exportfs \
 	lockd \
+	mount \
 	mountd \
 	nfsd \
 	nfsstat \
diff -uprN nfs-utils-1.0.8/utils/mount/Makefile.am nfs-utils-1.0.8-ag/uti=
ls/mount/Makefile.am
--- nfs-utils-1.0.8/utils/mount/Makefile.am	1969-12-31 19:00:00.000000000=
 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/Makefile.am	2006-06-08 11:37:04.260840=
000 -0400
@@ -0,0 +1,41 @@
+## Process this file with automake to produce Makefile.in
+
+man8_MANS	=3D mount.nfs.man umount.nfs.man
+
+sbin_PROGRAMS	=3D mount.nfs
+EXTRA_DIST =3D nfsmount.x $(man8_MANS)
+mount_nfs_SOURCES =3D mount.c nfsmount.c nfs4mount.c nfsumount.c \
+		  nfsmount_xdr.c mount_constants.h nfs4_mount.h nfsmount.h \
+		  nfs_mount4.h
+
+mount_nfs_LDADD =3D ../../support/nfs/libnfs.a
+
+MAINTAINERCLEANFILES =3D Makefile.in
+
+install-exec-hook:
+	(cd $(DESTDIR)$(sbindir) && \
+	  ln -sf $(sbin_PROGRAMS) mount.nfs4 && \
+	  ln -sf $(sbin_PROGRAMS) umount.nfs && \
+	  ln -sf $(sbin_PROGRAMS) umount.nfs4)
+uninstall-hook:
+	(cd $(DESTDIR)$(sbindir) && \
+	    rm -f mount.nfs4 umount.nfs umount.nfs4)
+
+
+install-man-links:
+	(cd $(DESTDIR)$(man8dir) && \
+	  for m in $(man8_MANS) $(dist_man8_MANS) $(nodist_man8_MANS); do \
+	    inst=3D`echo $$m | sed -e 's/man$$/8/'`; \
+	    rm -f $(RPCPREFIX)$$inst ; \
+	    $(LN_S) $$inst $(RPCPREFIX)$$inst ; \
+	  ln -sf mount.nfs.8 mount.nfs4.8
+	  ln -sf umount.nfs.8 umount.nfs4.8
+	  done)
+
+uninstall-man-links:
+	(cd $(DESTDIR)$(man8dir) && \
+	  for m in $(man8_MANS) $(dist_man8_MANS) $(nodist_man8_MANS); do \
+	    inst=3D`echo $$m | sed -e 's/man$$/8/'`; \
+	    rm -f $(RPCPREFIX)$$inst ; \
+	  done)
+
diff -uprN nfs-utils-1.0.8/utils/mount/mount.c nfs-utils-1.0.8-ag/utils/m=
ount/mount.c
--- nfs-utils-1.0.8/utils/mount/mount.c	1969-12-31 19:00:00.000000000 -05=
00
+++ nfs-utils-1.0.8-ag/utils/mount/mount.c	2006-06-08 11:22:22.107815000 =
-0400
@@ -0,0 +1,357 @@
+/*
+ * mount.c -- Linux NFS mount
+ *
+ * Copyright (C) 2006 Amit Gud <agud@redhat.com>
+ *
+ * - Basic code and wrapper around mount and umount code of NFS.
+ *   Based on util-linux/mount/mount.c.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#include <unistd.h>
+#include <sys/types.h>
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <sys/mount.h>
+#include <getopt.h>
+#include <mntent.h>
+
+#include "fstab.h"
+#include "xcommon.h"
+#include "mount_constants.h"
+#include "nfs_paths.h"
+
+#define MTAB_FILE "/etc/mtab"
+
+extern int nfsumount(int, char **);
+extern int nfs4mount(const char *, const char *, int *, char **,
+		char **, int);
+extern int nfsmount(const char *, const char *, int *, char **,
+		char **, int *, int);
+
+char *progname;
+int nomtab;
+int verbose;
+int mounttype;
+
+extern void umount_usage();
+
+static struct option longopts[] =3D {
+  { "fake", 0, 0, 'f' },
+  { "fork", 0, 0, 'F' },
+  { "help", 0, 0, 'h' },
+  { "no-mtab", 0, 0, 'n' },
+  { "read-only", 0, 0, 'r' },
+  { "ro", 0, 0, 'r' },
+  { "verbose", 0, 0, 'v' },
+  { "version", 0, 0, 'V' },
+  { "read-write", 0, 0, 'w' },
+  { "rw", 0, 0, 'w' },
+  { "options", 1, 0, 'o' },
+  { "nfsvers", 1, 0, 't' },
+  { "bind", 0, 0, 128 },
+  { "replace", 0, 0, 129 },
+  { "after", 0, 0, 130 },
+  { "before", 0, 0, 131 },
+  { "over", 0, 0, 132 },
+  { "move", 0, 0, 133 },
+  { "guess-fstype", 1, 0, 134 },
+  { NULL, 0, 0, 0 }
+};
+
+/* Map from -o and fstab option strings to the flag argument to mount(2)=
.  */
+struct opt_map {
+  const char *opt;              /* option name */
+  int  skip;                    /* skip in mtab option string */
+  int  inv;                     /* true if flag value should be inverted=
 */
+  int  mask;                    /* flag mask value */
+};
+
+static const struct opt_map opt_map[] =3D {
+  { "defaults", 0, 0, 0         },      /* default options */
+  { "ro",       1, 0, MS_RDONLY },      /* read-only */
+  { "rw",       1, 1, MS_RDONLY },      /* read-write */
+  { "exec",     0, 1, MS_NOEXEC },      /* permit execution of binaries =
*/
+  { "noexec",   0, 0, MS_NOEXEC },      /* don't execute binaries */
+  { "suid",     0, 1, MS_NOSUID },      /* honor suid executables */
+  { "nosuid",   0, 0, MS_NOSUID },      /* don't honor suid executables =
*/
+  { "dev",      0, 1, MS_NODEV  },      /* interpret device files  */
+  { "nodev",    0, 0, MS_NODEV  },      /* don't interpret devices */
+  { "sync",     0, 0, MS_SYNCHRONOUS},  /* synchronous I/O */
+  { "async",    0, 1, MS_SYNCHRONOUS},  /* asynchronous I/O */
+  { "dirsync",  0, 0, MS_DIRSYNC},      /* synchronous directory modific=
ations */
+  { "remount",  0, 0, MS_REMOUNT},      /* Alter flags of mounted FS */
+  { "bind",     0, 0, MS_BIND   },      /* Remount part of tree elsewher=
e */
+  { "rbind",    0, 0, MS_BIND|MS_REC }, /* Idem, plus mounted subtrees *=
/
+
+  /* add new options here */
+#ifdef MS_NOSUB
+  { "sub",      0, 1, MS_NOSUB  },      /* allow submounts */
+  { "nosub",    0, 0, MS_NOSUB  },      /* don't allow submounts */
+#endif
+#ifdef MS_SILENT
+  { "quiet",    0, 0, MS_SILENT    },   /* be quiet  */
+  { "loud",     0, 1, MS_SILENT    },   /* print out messages. */
+#endif
+#ifdef MS_MANDLOCK
+  { "mand",     0, 0, MS_MANDLOCK },    /* Allow mandatory locks on this=
 FS */
+  { "nomand",   0, 1, MS_MANDLOCK },    /* Forbid mandatory locks on thi=
s FS */
+#endif
+#ifdef MS_NOATIME
+  { "atime",    0, 1, MS_NOATIME },     /* Update access time */
+  { "noatime",  0, 0, MS_NOATIME },     /* Do not update access time */
+#endif
+#ifdef MS_NODIRATIME
+  { "diratime", 0, 1, MS_NODIRATIME },  /* Update dir access times */
+  { "nodiratime", 0, 0, MS_NODIRATIME },/* Do not update dir access time=
s */
+#endif
+  { NULL,	0, 0, 0		}
+};
+
+/* Try to build a canonical options string.  */
+static char * fix_opts_string (int flags, const char *extra_opts) {
+	const struct opt_map *om;
+	char *new_opts;
+
+	new_opts =3D xstrdup((flags & MS_RDONLY) ? "ro" : "rw");
+	for (om =3D opt_map; om->opt !=3D NULL; om++) {
+		if (om->skip)
+			continue;
+		if (om->inv || !om->mask || (flags & om->mask) !=3D om->mask)
+			continue;
+		new_opts =3D xstrconcat3(new_opts, ",", om->opt);
+		flags &=3D ~om->mask;
+	}
+	if (extra_opts && *extra_opts) {
+		new_opts =3D xstrconcat3(new_opts, ",", extra_opts);
+	}
+	return new_opts;
+}
+
+
+int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, c=
har *opts, int freq, int passno)
+{
+	struct mntent ment;
+	int fd;
+	FILE *mtab;
+
+	ment.mnt_fsname =3D fsname;
+	ment.mnt_dir =3D mount_point;
+	ment.mnt_type =3D fstype;
+	ment.mnt_opts =3D fix_opts_string(flags, opts);
+	ment.mnt_freq =3D 0;
+	ment.mnt_passno=3D 0;
+
+	if ((fd =3D open(MTAB_FILE"~", O_RDWR|O_CREAT|O_EXCL, 0600)) =3D=3D -1)=
	{
+		fprintf(stderr, "Can't get "MOUNTED"~ lock file");
+		return 1;
+	}
+        close(fd);
+
+        if ((mtab =3D setmntent(MTAB_FILE, "a+")) =3D=3D NULL) {
+		fprintf(stderr, "Can't open " MTAB_FILE);
+		return 1;
+	}
+
+        if (addmntent(mtab, &ment) =3D=3D 1) {
+		fprintf(stderr, "Can't write mount entry");
+		return 1;
+	}
+
+        if (fchmod(fileno(mtab), 0644) =3D=3D -1) {
+		fprintf(stderr, "Can't set perms on "MTAB_FILE);
+		return 1;
+	}
+
+	endmntent(mtab);
+
+	if (unlink(MTAB_FILE"~") =3D=3D -1) {
+		fprintf(stderr, "Can't remove "MTAB_FILE"~");
+		return 1;
+	}
+
+	return 0;
+}
+
+int do_mount_syscall(char *spec, char *node, char *type, int flags, void=
 *data)
+{
+	int ret;
+
+	ret =3D mount(spec, node, type, flags, data);
+
+	return ret;
+}
+
+void mount_usage()
+{
+	printf("usage: %s remotetarget dir [-rvnh] [-t version] [-o nfsoptions]=
\n", progname);
+	printf("options:\n\t-r\t\tmount readonly\n");
+	printf("\t-v\t\tverbose\n");
+	printf("\t-n\t\tno mtab updation\n");
+	printf("\t-h\t\tprint this help\n");
+	printf("\tversion\t\tnfs4 - NFS version 4, nfs - older NFS version supp=
orted\n");
+	printf("\tnfsoptions\tRefer mount.nfs(8) or nfs(5)\n\n");
+}
+
+static inline void
+parse_opt(const char *opt, int *mask, char *extra_opts, int len) {
+	const struct opt_map *om;
+
+	for (om =3D opt_map; om->opt !=3D NULL; om++) {
+		if (!strcmp (opt, om->opt)) {
+			if (om->inv)
+				*mask &=3D ~om->mask;
+			else
+				*mask |=3D om->mask;
+			return;
+		}
+	}
+
+	len -=3D strlen(extra_opts);
+
+	if (*extra_opts && --len > 0)
+		strcat(extra_opts, ",");
+
+	if ((len -=3D strlen(opt)) > 0)
+		strcat(extra_opts, opt);
+}
+
+/* Take -o options list and compute 4th and 5th args to mount(2).  flags
+   gets the standard options (indicated by bits) and extra_opts all the =
rest */
+static void parse_opts (const char *options, int *flags, char **extra_op=
ts)
+{
+	if (options !=3D NULL) {
+		char *opts =3D xstrdup(options);
+		char *opt;
+		int len =3D strlen(opts) + 20;
+
+		*extra_opts =3D xmalloc(len);
+		**extra_opts =3D '\0';
+
+		for (opt =3D strtok(opts, ","); opt; opt =3D strtok(NULL, ","))
+			parse_opt(opt, flags, *extra_opts, len);
+
+		free(opts);
+	}
+
+}
+
+int main(int argc, char *argv[])
+{
+	int c, flags =3D 0, nfs_mount_vers =3D 0, mnt_err =3D 1;
+	char *spec, *mount_point, *extra_opts =3D NULL;
+	char *mount_opts =3D NULL, *p;
+
+	progname =3D argv[0];
+	if ((p =3D strrchr(progname, '/')) !=3D NULL)
+		progname =3D p+1;
+
+	if (getuid() !=3D 0) {
+		printf("%s: only root can do that.\n", progname);
+		exit(1);
+	}
+
+	if(!strncmp(progname, "umount", strlen("umount"))) {
+		if(argc < 2) {
+			umount_usage();
+			exit(1);
+		}
+		return(nfsumount(argc, argv));
+	}
+
+	if (argc < 3 || argv[1][0] =3D=3D '-' || argv[2][0] =3D=3D '-') {
+		mount_usage();
+		exit(1);
+	}
+
+	spec =3D canonicalize(argv[1]);
+	mount_point =3D canonicalize(argv[2]);
+
+	argv +=3D 2;
+	argc -=3D 2;
+
+	while ((c =3D getopt_long (argc, argv, "rt:hvno:",
+				longopts, NULL)) !=3D -1) {
+		switch (c) {
+		case 'r':
+			flags |=3D MS_RDONLY;
+			break;
+		case 't':
+			nfs_mount_vers =3D (strncmp(optarg, "nfs4", 4)) ? 3 : 4;
+			break;
+		case 'v':
+			++verbose;
+			break;
+		case 'n':
+			++nomtab;
+			break;
+		case 'o':              /* specify mount options */
+			if (mount_opts)
+				mount_opts =3D xstrconcat3(mount_opts, ",", optarg);
+			else
+				mount_opts =3D xstrdup(optarg);
+			break;
+		case 128: /* bind */
+			mounttype =3D MS_BIND;
+			break;
+		case 129: /* replace */
+			mounttype =3D MS_REPLACE;
+			break;
+		case 130: /* after */
+			mounttype =3D MS_AFTER;
+			break;
+		case 131: /* before */
+			mounttype =3D MS_BEFORE;
+			break;
+		case 132: /* over */
+			mounttype =3D MS_OVER;
+			break;
+		case 133: /* move */
+			mounttype =3D MS_MOVE;
+			break;
+		case 135: /* rbind */
+			mounttype =3D MS_BIND | MS_REC;
+			break;
+		case 'h':
+		default:
+			mount_usage();
+			exit(1);
+		}
+	}
+
+
+	parse_opts(mount_opts, &flags, &extra_opts);
+
+	if (!strcmp(progname, "mount.nfs4") || nfs_mount_vers =3D=3D 4) {
+		nfs_mount_vers =3D 4;
+		mnt_err =3D nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_o=
pts, 0);
+	}
+
+	/* fall back to v3 if v4 didn't work */
+	if (mnt_err && errno !=3D EBUSY && errno !=3D ENOENT) {
+		nfs_mount_vers =3D 3;
+		mnt_err =3D nfsmount(spec, mount_point, &flags, &extra_opts, &mount_op=
ts, &nfs_mount_vers, 0);
+	}
+
+	if (!mnt_err) {
+		do_mount_syscall(spec, mount_point, nfs_mount_vers =3D=3D 4 ? "nfs4" :=
 "nfs", flags, mount_opts);
+		if(!nomtab)
+			add_mtab(spec, mount_point, nfs_mount_vers =3D=3D 4 ? "nfs4" : "nfs",
+				 flags, extra_opts, 0, 0);
+	}
+
+	return 0;
+}
+
diff -uprN nfs-utils-1.0.8/utils/mount/mount_constants.h nfs-utils-1.0.8-=
ag/utils/mount/mount_constants.h
--- nfs-utils-1.0.8/utils/mount/mount_constants.h	1969-12-31 19:00:00.000=
000000 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/mount_constants.h	2006-06-08 11:22:22.=
113815000 -0400
@@ -0,0 +1,74 @@
+#ifndef _NFS_MOUNT_CONSTANTS_H
+#define _NFS_MOUNT_CONSTANTS_H
+
+#ifndef MS_RDONLY
+#define MS_RDONLY	 1	/* Mount read-only */
+#endif
+#ifndef MS_NOSUID
+#define MS_NOSUID	 2	/* Ignore suid and sgid bits */
+#endif
+#ifndef MS_NODEV
+#define MS_NODEV	 4	/* Disallow access to device special files */
+#endif
+#ifndef MS_NOEXEC
+#define MS_NOEXEC	 8	/* Disallow program execution */
+#endif
+#ifndef MS_SYNCHRONOUS
+#define MS_SYNCHRONOUS	16	/* Writes are synced at once */
+#endif
+#ifndef MS_REMOUNT
+#define MS_REMOUNT	32	/* Alter flags of a mounted FS */
+#endif
+#ifndef MS_MANDLOCK
+#define MS_MANDLOCK	64	/* Allow mandatory locks on an FS */
+#endif
+#ifndef MS_DIRSYNC
+#define MS_DIRSYNC	128	/* Directory modifications are synchronous */
+#endif
+
+#ifndef MS_ACTION_MASK
+#define	MS_ACTION_MASK	0x380
+/* Remount, but new filesystem may be different from old. Atomic
+   (i.e. there is no interval when nothing is mounted at the mountpoint).
+   If new fs differs from the old one and old is busy - -EBUSY. */
+#define	MS_REPLACE	0x080	/* 128 */
+/* After, Before: as soon as we get unions these will add a new member
+   in the end or beginning of the chain. Fail if there is a stack
+   on the mountpoint. */
+#define	MS_AFTER	0x100	/* 256 */
+#define	MS_BEFORE	0x180
+/* Over: if nothing mounted on a mountpoint - same as if none of these
+flags had been set; if we have a union with more than one element - fail=
;
+if we have a stack or plain mount - mount atop of it, forming a stack. *=
/
+#define	MS_OVER		0x200	/* 512 */
+#endif
+#ifndef MS_NOATIME
+#define MS_NOATIME	0x400	/* 1024: Do not update access times. */
+#endif
+#ifndef MS_NODIRATIME
+#define MS_NODIRATIME   0x800	/* 2048: Don't update directory access tim=
es */
+#endif
+#ifndef MS_BIND
+#define	MS_BIND		0x1000	/* 4096: Mount existing tree also elsewhere */
+#endif
+#ifndef MS_MOVE
+#define MS_MOVE		0x2000	/* 8192: Atomically move tree */
+#endif
+#ifndef MS_REC
+#define MS_REC		0x4000	/* 16384: Recursive loopback */
+#endif
+#ifndef MS_VERBOSE
+#define MS_VERBOSE	0x8000	/* 32768 */
+#endif
+/*
+ * Magic mount flag number. Had to be or-ed to the flag values.
+ */
+#ifndef MS_MGC_VAL
+#define MS_MGC_VAL 0xC0ED0000	/* magic flag number to indicate "new" fla=
gs */
+#endif
+#ifndef MS_MGC_MSK
+#define MS_MGC_MSK 0xffff0000	/* magic flag number mask */
+#endif
+
+#endif /* _NFS_MOUNT_CONSTANTS_H */
+
diff -uprN nfs-utils-1.0.8/utils/mount/mount.nfs.man nfs-utils-1.0.8-ag/u=
tils/mount/mount.nfs.man
--- nfs-utils-1.0.8/utils/mount/mount.nfs.man	1969-12-31 19:00:00.0000000=
00 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/mount.nfs.man	2006-06-08 11:22:22.1188=
15000 -0400
@@ -0,0 +1,87 @@
+.\"@(#)mount.nfs.8"
+.TH MOUNT.NFS 8 "5 Jun 2006"
+.SH NAME
+mount.nfs, mount.nfs4 \- mount a Network File System
+.SH SYNOPSIS
+.BI "mount.nfs" " remotetarget dir" " [\-rvnh ] [\-t " version "] [\-o "=
 options "]
+.SH DESCRIPTION
+.BR mount.nfs
+is a part of=20
+.BR nfs (5)
+utilities package, which provides NFS client functionality.
+
+.BR mount.nfs=20
+is meant to be used by the
+.BR mount (8)
+command for mounting NFS shares. This subcommand, however, can also be u=
sed as a standalone command with limited functionality.
+
+.BR mount.nfs=20
+is used for mounting NFSv4 file system, while=20
+.BR mount.nfs=20
+is used to mount NFS file systems with older versions.
+.I remotetarget=20
+is a server share usually in the form of=20
+.BR servername:/path/to/share.
+.I dir=20
+is the directory on which the file system is to be mounted.
+
+.SH OPTIONS
+.TP
+.BI "\-r"
+Mount file system readonly.
+.TP
+.BI "\-v"
+Be verbose.
+.TP
+.BI "\-n"
+Make no updation to mtab. By default, an entry is created in=20
+.I /etc/mtab=20
+for every mounted file system. Use this option to skip making an entry.
+.TP
+.BI "\-h"
+Print help message.
+.TP
+.BI "version"
+Specify NFS file system version. Either
+.BR nfs4=20
+or=20
+.BR nfs.
+By default=20
+.BR mount.nfs4=20
+takes version 4, and=20
+.BR mount.nfs=20
+takes any supported older version.
+.TP
+.BI "nfsoptions"
+Refer=20
+.BR nfs(5)
+or
+.BR mount(8)=20
+manual pages.
+
+.SH NOTE
+For further information please refer=20
+.BR nfs (5)
+and
+.BR mount (8)
+manual pages.
+
+.SH FILES
+.TP 18n
+.I /etc/fstab
+file system table
+.TP
+.I /etc/mtab
+table of mounted file systems
+
+.PD
+.SH "SEE ALSO"
+.BR nfs (5),
+.BR mount (8),
+
+.SH BUGS
+Please notify current developers of NFS of any bugs in the current softw=
are or mail nfs@lists.sourceforge.net
+
+.SH "AUTHOR"
+Amit Gud <agud@redhat.com>
+
diff -uprN nfs-utils-1.0.8/utils/mount/nfs4mount.c nfs-utils-1.0.8-ag/uti=
ls/mount/nfs4mount.c
--- nfs-utils-1.0.8/utils/mount/nfs4mount.c	1969-12-31 19:00:00.000000000=
 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfs4mount.c	2006-06-08 11:27:25.318390=
000 -0400
@@ -0,0 +1,450 @@
+/*
+ * nfs4mount.c -- Linux NFS mount
+ * Copyright (C) 2002 Trond Myklebust <trond.myklebust@fys.uio.no>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Note: this file based on the original nfsmount.c
+ *
+ * 2006-06-06 Amit Gud <agud@redhat.com>
+ * - Moved to nfs-utils/utils/mount from util-linux/mount.
+ */
+
+#include <linux/posix_types.h>
+#include <asm/posix_types.h>
+#undef __FD_CLR
+#undef __FD_SET
+#undef __FD_ISSET
+#undef __FD_ZERO
+
+#include <unistd.h>
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+#include <netdb.h>
+#include <time.h>
+#include <sys/stat.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <rpc/auth.h>
+#include <rpc/rpc.h>
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
+#include "nfs4_mount.h"
+#include "nls.h"
+#include "conn.h"
+#include "xcommon.h"
+
+#if defined(VAR_LOCK_DIR)
+#define DEFAULT_DIR VAR_LOCK_DIR
+#else
+#define DEFAULT_DIR "/var/lock/subsys"
+#endif
+
+extern void mount_errors(char *, int , int );
+extern int verbose;
+
+char *IDMAPLCK =3D DEFAULT_DIR "/rpcidmapd";
+#define idmapd_check() do { \
+	if (access(IDMAPLCK, F_OK)) { \
+		printf(_("Warning: rpc.idmapd appears not to be running.\n" \
+			"         All uids will be mapped to the nobody uid.\n")); \
+	} \
+} while(0);
+
+char *GSSDLCK =3D DEFAULT_DIR "/rpcgssd";
+#define gssd_check() do { \
+		if (access(GSSDLCK, F_OK)) { \
+			printf(_("Warning: rpc.gssd appears not to be running.\n")); \
+		} \
+} while(0);=20
+
+#ifndef NFS_PORT
+#define NFS_PORT 2049
+#endif
+
+struct {
+	char    *flavour;
+	int     fnum;
+} flav_map[] =3D {
+	{ "krb5",	RPC_AUTH_GSS_KRB5	},
+	{ "krb5i",	RPC_AUTH_GSS_KRB5I	},
+	{ "krb5p",	RPC_AUTH_GSS_KRB5P	},
+	{ "lipkey",	RPC_AUTH_GSS_LKEY	},
+	{ "lipkey-i",	RPC_AUTH_GSS_LKEYI	},
+	{ "lipkey-p",	RPC_AUTH_GSS_LKEYP	},
+	{ "spkm3",	RPC_AUTH_GSS_SPKM	},
+	{ "spkm3i",	RPC_AUTH_GSS_SPKMI	},
+	{ "spkm3p",	RPC_AUTH_GSS_SPKMP	},
+	{ "unix",	AUTH_UNIX		},
+	{ "sys",	AUTH_SYS		},
+	{ "null",	AUTH_NULL		},
+	{ "none",	AUTH_NONE		},
+};
+
+#define FMAPSIZE		(sizeof(flav_map)/sizeof(flav_map[0]))
+#define MAX_USER_FLAVOUR	16
+
+static int parse_sec(char *sec, int *pseudoflavour)
+{
+	int i, num_flavour =3D 0;
+
+	for (sec =3D strtok(sec, ":"); sec; sec =3D strtok(NULL, ":")) {
+		if (num_flavour >=3D MAX_USER_FLAVOUR) {
+			fprintf(stderr,
+				_("mount: maximum number of security flavors "
+				  "exceeded\n"));
+			return 0;
+		}
+		for (i =3D 0; i < FMAPSIZE; i++) {
+			if (strcmp(sec, flav_map[i].flavour) =3D=3D 0) {
+				pseudoflavour[num_flavour++] =3D flav_map[i].fnum;
+				break;
+			}
+		}
+		if (i =3D=3D FMAPSIZE) {
+			fprintf(stderr,
+				_("mount: unknown security type %s\n"), sec);
+			return 0;
+		}
+	}
+	if (!num_flavour)
+		fprintf(stderr,
+			_("mount: no security flavors passed to sec=3D option\n"));
+	return num_flavour;
+}
+
+static int parse_devname(char *hostdir, char **hostname, char **dirname)
+{
+	char *s;
+
+	if (!(s =3D strchr(hostdir, ':'))) {
+		fprintf(stderr,
+			_("mount: "
+			  "directory to mount not in host:dir format\n"));
+		return -1;
+	}
+	*hostname =3D hostdir;
+	*dirname =3D s + 1;
+	*s =3D '\0';
+	/* Ignore all but first hostname in replicated mounts
+	   until they can be fully supported. (mack@sgi.com) */
+	if ((s =3D strchr(hostdir, ','))) {
+		*s =3D '\0';
+		fprintf(stderr,
+			_("mount: warning: "
+			  "multiple hostnames not supported\n"));
+	}
+	return 0;
+}
+
+static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *=
addr)
+{
+	struct hostent *hp;
+	addr->sin_family =3D AF_INET;
+
+	if (inet_aton(hostname, &addr->sin_addr))
+		return 0;
+	if ((hp =3D gethostbyname(hostname)) =3D=3D NULL) {
+		fprintf(stderr, _("mount: can't get address for %s\n"),
+			hostname);
+		return -1;
+	}
+	if (hp->h_length > sizeof(struct in_addr)) {
+		fprintf(stderr,
+			_("mount: got bad hp->h_length\n"));
+		hp->h_length =3D sizeof(struct in_addr);
+	}
+	memcpy(&addr->sin_addr, hp->h_addr, hp->h_length);
+	return 0;
+}
+
+static int get_my_ipv4addr(char *ip_addr, int len)
+{
+	char myname[1024];
+	struct sockaddr_in myaddr;
+
+	if (gethostname(myname, sizeof(myname))) {
+		fprintf(stderr, _("mount: can't determine client address\n"));
+		return -1;
+	}
+	if (fill_ipv4_sockaddr(myname, &myaddr))
+		return -1;
+	snprintf(ip_addr, len, "%s", inet_ntoa(myaddr.sin_addr));
+	ip_addr[len-1] =3D '\0';
+	return 0;
+}
+
+int nfs4mount(const char *spec, const char *node, int *flags,
+	      char **extra_opts, char **mount_opts,
+	      int running_bg)
+{
+	static struct nfs4_mount_data data;
+	static char hostdir[1024];
+	static char ip_addr[16] =3D "127.0.0.1";
+	static struct sockaddr_in server_addr;
+	static int pseudoflavour[MAX_USER_FLAVOUR];
+	int num_flavour =3D 0;
+
+	char *hostname, *dirname, *old_opts;
+	char new_opts[1024];
+	char *opt, *opteq;
+	char *s;
+	int val;
+	int bg, soft, intr;
+	int nocto, noac;
+	int retry;
+	int retval;
+	time_t timeout, t;
+
+	retval =3D EX_FAIL;
+	if (strlen(spec) >=3D sizeof(hostdir)) {
+		fprintf(stderr, _("mount: "
+				  "excessively long host:dir argument\n"));
+		goto fail;
+	}
+	strcpy(hostdir, spec);
+	if (parse_devname(hostdir, &hostname, &dirname))
+		goto fail;
+
+	if (fill_ipv4_sockaddr(hostname, &server_addr))
+		goto fail;
+	if (get_my_ipv4addr(ip_addr, sizeof(ip_addr)))
+		goto fail;
+
+	/* add IP address to mtab options for use when unmounting */
+	s =3D inet_ntoa(server_addr.sin_addr);
+	old_opts =3D *extra_opts;
+	if (!old_opts)
+		old_opts =3D "";
+	if (strlen(old_opts) + strlen(s) + 10 >=3D sizeof(new_opts)) {
+		fprintf(stderr, _("mount: "
+				  "excessively long option argument\n"));
+		goto fail;
+	}
+	snprintf(new_opts, sizeof(new_opts), "%s%saddr=3D%s",
+		 old_opts, *old_opts ? "," : "", s);
+	*extra_opts =3D xstrdup(new_opts);
+
+	/* Set default options.
+	 * rsize/wsize and timeo are left 0 in order to
+	 * let the kernel decide.
+	 */
+	memset(&data, 0, sizeof(data));
+	data.retrans	=3D 3;
+	data.acregmin	=3D 3;
+	data.acregmax	=3D 60;
+	data.acdirmin	=3D 30;
+	data.acdirmax	=3D 60;
+	data.proto	=3D IPPROTO_TCP;
+
+	bg =3D 0;
+	soft =3D 0;
+	intr =3D NFS4_MOUNT_INTR;
+	nocto =3D 0;
+	noac =3D 0;
+	retry =3D 10000;		/* 10000 minutes ~ 1 week */
+
+	/*
+	 * NFSv4 specifies that the default port should be 2049
+	 */
+	server_addr.sin_port =3D htons(NFS_PORT);
+
+	/* parse options */
+
+	for (opt =3D strtok(old_opts, ","); opt; opt =3D strtok(NULL, ",")) {
+		if ((opteq =3D strchr(opt, '=3D'))) {
+			val =3D atoi(opteq + 1);=09
+			*opteq =3D '\0';
+			if (!strcmp(opt, "rsize"))
+				data.rsize =3D val;
+			else if (!strcmp(opt, "wsize"))
+				data.wsize =3D val;
+			else if (!strcmp(opt, "timeo"))
+				data.timeo =3D val;
+			else if (!strcmp(opt, "retrans"))
+				data.retrans =3D val;
+			else if (!strcmp(opt, "acregmin"))
+				data.acregmin =3D val;
+			else if (!strcmp(opt, "acregmax"))
+				data.acregmax =3D val;
+			else if (!strcmp(opt, "acdirmin"))
+				data.acdirmin =3D val;
+			else if (!strcmp(opt, "acdirmax"))
+				data.acdirmax =3D val;
+			else if (!strcmp(opt, "actimeo")) {
+				data.acregmin =3D val;
+				data.acregmax =3D val;
+				data.acdirmin =3D val;
+				data.acdirmax =3D val;
+			}
+			else if (!strcmp(opt, "retry"))
+				retry =3D val;
+			else if (!strcmp(opt, "port"))
+				server_addr.sin_port =3D htons(val);
+			else if (!strcmp(opt, "proto")) {
+				if (!strncmp(opteq+1, "tcp", 3))
+					data.proto =3D IPPROTO_TCP;
+				else if (!strncmp(opteq+1, "udp", 3))
+					data.proto =3D IPPROTO_UDP;
+				else
+					printf(_("Warning: Unrecognized proto=3D option.\n"));
+			} else if (!strcmp(opt, "clientaddr")) {
+				if (strlen(opteq+1) >=3D sizeof(ip_addr))
+					printf(_("Invalid client address %s"),
+								opteq+1);
+				strncpy(ip_addr,opteq+1, sizeof(ip_addr));
+				ip_addr[sizeof(ip_addr)-1] =3D '\0';
+			} else if (!strcmp(opt, "sec")) {
+				num_flavour =3D parse_sec(opteq+1, pseudoflavour);
+				if (!num_flavour)
+					goto fail;
+			} else if (!strcmp(opt, "addr")) {
+				/* ignore */;
+			} else {
+				printf(_("unknown nfs mount parameter: "
+					 "%s=3D%d\n"), opt, val);
+				goto fail;
+			}
+		} else {
+			val =3D 1;
+			if (!strncmp(opt, "no", 2)) {
+				val =3D 0;
+				opt +=3D 2;
+			}
+			if (!strcmp(opt, "bg"))=20
+				bg =3D val;
+			else if (!strcmp(opt, "fg"))=20
+				bg =3D !val;
+			else if (!strcmp(opt, "soft"))
+				soft =3D val;
+			else if (!strcmp(opt, "hard"))
+				soft =3D !val;
+			else if (!strcmp(opt, "intr"))
+				intr =3D val;
+			else if (!strcmp(opt, "cto"))
+				nocto =3D !val;
+			else if (!strcmp(opt, "ac"))
+				noac =3D !val;
+			else {
+				printf(_("unknown nfs mount option: "
+					 "%s%s\n"), val ? "" : "no", opt);
+				goto fail;
+			}
+		}
+	}
+
+	data.flags =3D (soft ? NFS4_MOUNT_SOFT : 0)
+		| (intr ? NFS4_MOUNT_INTR : 0)
+		| (nocto ? NFS4_MOUNT_NOCTO : 0)
+		| (noac ? NFS4_MOUNT_NOAC : 0);
+
+	/*
+	 * Give a warning if the rpc.idmapd daemon is not running
+	 */
+	idmapd_check();
+
+	if (num_flavour =3D=3D 0)
+		pseudoflavour[num_flavour++] =3D AUTH_UNIX;
+	else {
+		/*
+		 * ditto with rpc.gssd daemon
+		 */
+		gssd_check();
+	}
+	data.auth_flavourlen =3D num_flavour;
+	data.auth_flavours =3D pseudoflavour;
+
+	data.client_addr.data =3D ip_addr;
+	data.client_addr.len =3D strlen(ip_addr);
+
+	data.mnt_path.data =3D dirname;
+	data.mnt_path.len =3D strlen(dirname);
+
+	data.hostname.data =3D hostname;
+	data.hostname.len =3D strlen(hostname);
+	data.host_addr =3D (struct sockaddr *)&server_addr;
+	data.host_addrlen =3D sizeof(server_addr);
+
+#ifdef NFS_MOUNT_DEBUG
+	printf("rsize =3D %d, wsize =3D %d, timeo =3D %d, retrans =3D %d\n",
+	       data.rsize, data.wsize, data.timeo, data.retrans);
+	printf("acreg (min, max) =3D (%d, %d), acdir (min, max) =3D (%d, %d)\n"=
,
+	       data.acregmin, data.acregmax, data.acdirmin, data.acdirmax);
+	printf("port =3D %d, bg =3D %d, retry =3D %d, flags =3D %.8x\n",
+	       ntohs(server_addr.sin_port), bg, retry, data.flags);
+	printf("soft =3D %d, intr =3D %d, nocto =3D %d, noac =3D %d\n",
+	       (data.flags & NFS4_MOUNT_SOFT) !=3D 0,
+	       (data.flags & NFS4_MOUNT_INTR) !=3D 0,
+	       (data.flags & NFS4_MOUNT_NOCTO) !=3D 0,
+	       (data.flags & NFS4_MOUNT_NOAC) !=3D 0);
+
+	if (num_flavour > 0) {
+		int pf_cnt, i;
+
+		printf("sec =3D ");
+		for (pf_cnt =3D 0; pf_cnt < num_flavour; pf_cnt++) {
+			for (i =3D 0; i < FMAPSIZE; i++) {
+				if (flav_map[i].fnum =3D=3D pseudoflavour[pf_cnt]) {
+					printf("%s", flav_map[i].flavour);
+					break;
+				}
+			}
+			printf("%s", (pf_cnt < num_flavour-1) ? ":" : "\n");
+		}
+	}
+	printf("proto =3D %s\n", (data.proto =3D=3D IPPROTO_TCP) ? "tcp" : "udp=
");
+#endif
+
+	timeout =3D time(NULL) + 60 * retry;
+	data.version =3D NFS4_MOUNT_VERSION;
+	for (;;) {
+		if (verbose) {
+			fprintf(stderr,=20
+				"mount: pinging: prog %d vers %d prot %s port %d\n",=20
+				NFS_PROGRAM, 4, data.proto =3D=3D IPPROTO_UDP ? "udp" : "tcp",=20
+				ntohs(server_addr.sin_port));
+		}
+		clnt_ping(&server_addr, NFS_PROGRAM, 4, data.proto);
+		if (rpc_createerr.cf_stat =3D=3D RPC_SUCCESS)
+			break;
+
+		switch(rpc_createerr.cf_stat){
+		case RPC_TIMEDOUT:
+			break;
+		case RPC_SYSTEMERROR:
+			if (errno =3D=3D ETIMEDOUT)
+				break;
+		default:
+			mount_errors(hostname, 0, bg);
+			goto fail;
+		}
+		t =3D time(NULL);
+		if (t >=3D timeout) {
+			mount_errors(hostname, 0, bg);
+			goto fail;
+		}
+		mount_errors(hostname, 1, bg);
+		continue;
+	}
+
+	*mount_opts =3D (char *) &data;
+	/* clean up */
+	return 0;
+
+fail:
+	return retval;
+}
diff -uprN nfs-utils-1.0.8/utils/mount/nfs4_mount.h nfs-utils-1.0.8-ag/ut=
ils/mount/nfs4_mount.h
--- nfs-utils-1.0.8/utils/mount/nfs4_mount.h	1969-12-31 19:00:00.00000000=
0 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfs4_mount.h	2006-06-08 11:22:22.13081=
6000 -0400
@@ -0,0 +1,85 @@
+#ifndef _LINUX_NFS4_MOUNT_H
+#define _LINUX_NFS4_MOUNT_H
+
+/*
+ *  linux/include/linux/nfs4_mount.h
+ *
+ *  Copyright (C) 2002  Trond Myklebust
+ *
+ *  structure passed from user-space to kernel-space during an nfsv4 mou=
nt
+ */
+
+/*
+ * WARNING!  Do not delete or change the order of these fields.  If
+ * a new field is required then add it to the end.  The version field
+ * tracks which fields are present.  This will ensure some measure of
+ * mount-to-kernel version compatibility.  Some of these aren't used yet
+ * but here they are anyway.
+ */
+#define NFS4_MOUNT_VERSION	1
+
+struct nfs_string {
+	unsigned int len;
+	const char* data;
+};
+
+struct nfs4_mount_data {
+	int version;				/* 1 */
+	int flags;				/* 1 */
+	int rsize;				/* 1 */
+	int wsize;				/* 1 */
+	int timeo;				/* 1 */
+	int retrans;				/* 1 */
+	int acregmin;				/* 1 */
+	int acregmax;				/* 1 */
+	int acdirmin;				/* 1 */
+	int acdirmax;				/* 1 */
+
+	/* see the definition of 'struct clientaddr4' in RFC3010 */
+	struct nfs_string client_addr;		/* 1 */
+
+	/* Mount path */
+	struct nfs_string mnt_path;		/* 1 */
+
+	/* Server details */
+	struct nfs_string hostname;		/* 1 */
+	/* Server IP address */
+	unsigned int host_addrlen;		/* 1 */
+	struct sockaddr* host_addr;		/* 1 */
+
+	/* Transport protocol to use */
+	int proto;				/* 1 */
+
+	/* Pseudo-flavours to use for authentication. See RFC2623 */
+	int auth_flavourlen;			/* 1 */
+	int *auth_flavours;			/* 1 */
+};
+
+/* bits in the flags field */
+/* Note: the fields that correspond to existing NFSv2/v3 mount options
+ * 	 should mirror the values from include/linux/nfs_mount.h
+ */
+
+#define NFS4_MOUNT_SOFT		0x0001	/* 1 */
+#define NFS4_MOUNT_INTR		0x0002	/* 1 */
+#define NFS4_MOUNT_NOCTO	0x0010	/* 1 */
+#define NFS4_MOUNT_NOAC		0x0020	/* 1 */
+#define NFS4_MOUNT_STRICTLOCK	0x1000	/* 1 */
+#define NFS4_MOUNT_FLAGMASK	0xFFFF
+
+/* pseudoflavors: */
+
+#define RPC_AUTH_GSS_KRB5       390003
+#define RPC_AUTH_GSS_KRB5I      390004
+#define RPC_AUTH_GSS_KRB5P      390005
+#define RPC_AUTH_GSS_LKEY       390006
+#define RPC_AUTH_GSS_LKEYI      390007
+#define RPC_AUTH_GSS_LKEYP      390008
+#define RPC_AUTH_GSS_SPKM       390009
+#define RPC_AUTH_GSS_SPKMI      390010
+#define RPC_AUTH_GSS_SPKMP      390011
+
+int nfs4mount(const char *, const char *, int *, char **,
+	char **, int);
+
+#endif
diff -uprN nfs-utils-1.0.8/utils/mount/nfsmount.c nfs-utils-1.0.8-ag/util=
s/mount/nfsmount.c
--- nfs-utils-1.0.8/utils/mount/nfsmount.c	1969-12-31 19:00:00.000000000 =
-0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfsmount.c	2006-06-08 11:26:54.5956160=
00 -0400
@@ -0,0 +1,1245 @@
+/*
+ * nfsmount.c -- Linux NFS mount
+ * Copyright (C) 1993 Rick Sladkey <jrs@world.std.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Wed Feb  8 12:51:48 1995, biro@yggdrasil.com (Ross Biro): allow all p=
ort
+ * numbers to be specified on the command line.
+ *
+ * Fri, 8 Mar 1996 18:01:39, Swen Thuemmler <swen@uni-paderborn.de>:
+ * Omit the call to connect() for Linux version 1.3.11 or later.
+ *
+ * Wed Oct  1 23:55:28 1997: Dick Streefland <dick_streefland@tasking.co=
m>
+ * Implemented the "bg", "fg" and "retry" mount options for NFS.
+ *
+ * 1999-02-22 Arkadiusz Mi=B6kiewicz <misiek@pld.ORG.PL>
+ * - added Native Language Support
+ *=20
+ * Modified by Olaf Kirch and Trond Myklebust for new NFS code,
+ * plus NFSv3 stuff.
+ *
+ * 2006-06-06 Amit Gud <agud@redhat.com>
+ * - Moved with modifcations to nfs-utils/utils/mount from util-linux/mo=
unt.
+ */
+
+/*
+ * nfsmount.c,v 1.1.1.1 1993/11/18 08:40:51 jrs Exp
+ */
+
+#include <ctype.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <netdb.h>
+#include <time.h>
+#include <rpc/rpc.h>
+#include <rpc/pmap_prot.h>
+#include <rpc/pmap_clnt.h>
+#include <sys/socket.h>
+#include <sys/time.h>
+#include <sys/utsname.h>
+#include <sys/stat.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <mntent.h>
+#include <paths.h>
+#include <syslog.h>
+
+#include "conn.h"
+#include "xcommon.h"
+#include "nfsmount.h"
+#include "mount_constants.h"
+#include "nfs_mount.h"
+#include "nls.h"
+
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
+#ifndef NFS_PORT
+#define NFS_PORT 2049
+#endif
+#ifndef NFS_FHSIZE
+#define NFS_FHSIZE 32
+#endif
+
+extern int nfs_call_umount(clnt_addr_t *, dirpath *);
+extern void mount_errors(char *, int , int );
+
+static char *nfs_strerror(int stat);
+
+#define MAKE_VERSION(p,q,r)	(65536*(p) + 256*(q) + (r))
+#define MAX_NFSPROT ((nfs_mount_version >=3D 4) ? 3 : 2)
+#define MAX_MNTPROT ((nfs_mount_version >=3D 4) ? 3 : 2)
+#define HAVE_RELIABLE_TCP (nfs_mount_version >=3D 4)
+
+#ifndef HAVE_INET_ATON
+#define inet_aton(a,b) (0)
+#endif
+
+typedef dirpath mnt2arg_t;
+typedef dirpath mnt3arg_t;
+typedef dirpath mntarg_t;
+
+typedef struct fhstatus  mnt2res_t;
+typedef struct mountres3 mnt3res_t;
+typedef union {
+	mnt2res_t nfsv2;
+	mnt3res_t nfsv3;
+} mntres_t;
+
+static char errbuf[BUFSIZ];
+static char *erreob =3D &errbuf[BUFSIZ];
+extern int verbose;
+
+/* Convert RPC errors into strings */
+int rpc_strerror(int);
+int rpc_strerror(int spos)
+{
+	int cf_stat =3D rpc_createerr.cf_stat;=20
+	int pos=3D0, cf_errno =3D rpc_createerr.cf_error.re_errno;
+	char *ptr, *estr =3D clnt_sperrno(cf_stat);
+	char *tmp;
+
+	if (estr) {
+		if ((ptr =3D index(estr, ':')))
+			estr =3D ++ptr;
+
+		tmp =3D &errbuf[spos];
+		if (cf_stat =3D=3D RPC_SYSTEMERROR)
+			pos =3D snprintf(tmp, (erreob - tmp),=20
+				"System Error: %s", strerror(cf_errno));
+		else
+			pos =3D snprintf(tmp, (erreob - tmp), "RPC Error:%s", estr);
+	}
+	return (pos);
+}
+void mount_errors(char *, int, int);
+void mount_errors(char *server, int will_retry, int bg)
+{
+	int pos =3D 0;
+	char *tmp;
+	static int onlyonce =3D 0;
+
+	tmp =3D &errbuf[pos];
+	if (bg)=20
+		pos =3D snprintf(tmp, (erreob - tmp),=20
+			"mount to NFS server '%s' failed: ", server);
+	else
+		pos =3D snprintf(tmp, (erreob - tmp),=20
+			"mount: mount to NFS server '%s' failed: ", server);
+
+	tmp =3D &errbuf[pos];
+	if (rpc_createerr.cf_stat =3D=3D RPC_TIMEDOUT) {
+		pos =3D snprintf(tmp, (erreob - tmp), "timed out %s",=20
+			will_retry ? "(retrying)" : "(giving up)");
+	} else {
+		pos +=3D rpc_strerror(pos);
+		tmp =3D &errbuf[pos];
+		if (bg) {
+			pos =3D snprintf(tmp, (erreob - tmp), " %s",
+				will_retry ? "(retrying)" : "(giving up)");
+		}
+	}
+	if (bg) {
+		if (onlyonce++ < 1)
+			openlog("mount", LOG_CONS|LOG_PID, LOG_AUTH);
+		syslog(LOG_ERR, "%s.", errbuf);
+	} else
+		fprintf(stderr, "%s.\n", errbuf);
+}
+
+/* Define the order in which to probe for UDP/TCP services */
+enum plist {
+	use_tcp =3D 0,
+	udp_tcp,
+	udp_only,
+};
+static const u_int *
+proto_probelist(enum plist list)
+{
+	static const u_int probe_udp_tcp[] =3D { IPPROTO_UDP, IPPROTO_TCP, 0 };
+	static const u_int probe_both[] =3D { IPPROTO_TCP, IPPROTO_UDP, 0 };
+	static const u_int probe_udponly[] =3D { IPPROTO_UDP, 0 };
+
+	if (list =3D=3D use_tcp)
+		return probe_both;
+	if (list =3D=3D udp_tcp)
+		return probe_udp_tcp;
+	return probe_udponly;
+}
+
+/* Define the order in which NFS versions are probed on portmapper */
+static const u_long *
+nfs_probelist(const int vers)
+{
+	static const u_long nfs2_probe[] =3D { 2, 0};
+	static const u_long nfs3_probe[] =3D { 3, 2, 0};
+	switch (vers) {
+	case 3:
+		return nfs3_probe;
+	default:
+		return nfs2_probe;
+	}
+}
+
+/* Define the order in which Mountd versions are probed on portmapper */
+static const u_long *
+mnt_probelist(const int vers)
+{
+	static const u_long mnt1_probe[] =3D { 1, 2, 0 };
+	static const u_long mnt3_probe[] =3D { 3, 1, 2, 0 };
+	switch (vers) {
+	case 3:
+		return mnt3_probe;
+	default:
+		return mnt1_probe;
+	}
+}
+
+static int
+linux_version_code(void) {
+	struct utsname my_utsname;
+	int p, q, r;
+
+	if (uname(&my_utsname) =3D=3D 0) {
+		p =3D atoi(strtok(my_utsname.release, "."));
+		q =3D atoi(strtok(NULL, "."));
+		r =3D atoi(strtok(NULL, "."));
+		return MAKE_VERSION(p,q,r);
+	}
+	return 0;
+}
+
+/*
+ * Unfortunately, the kernel prints annoying console messages
+ * in case of an unexpected nfs mount version (instead of
+ * just returning some error).  Therefore we'll have to try
+ * and figure out what version the kernel expects.
+ *
+ * Variables:
+ *	NFS_MOUNT_VERSION: these nfsmount sources at compile time
+ *	nfs_mount_version: version this source and running kernel can handle
+ */
+int nfs_mount_version =3D NFS_MOUNT_VERSION;
+
+int
+find_kernel_nfs_mount_version(void) {
+	static int kernel_version =3D -1;
+	int mnt_version =3D NFS_MOUNT_VERSION;
+
+	if (kernel_version =3D=3D -1)
+		kernel_version =3D linux_version_code();
+
+	if (kernel_version) {
+	     if (kernel_version < MAKE_VERSION(2,1,32))
+		  mnt_version =3D 1;
+	     else if (kernel_version < MAKE_VERSION(2,2,18))
+		  mnt_version =3D 3;
+	     else if (kernel_version < MAKE_VERSION(2,3,0))
+		  mnt_version =3D 4; /* since 2.2.18pre9 */
+	     else if (kernel_version < MAKE_VERSION(2,3,99))
+		  mnt_version =3D 3;
+	     else if (kernel_version < MAKE_VERSION(2,6,3))
+		  mnt_version =3D 4;
+	     else
+		  mnt_version =3D 6;
+	}
+	if (mnt_version > NFS_MOUNT_VERSION)
+	     mnt_version =3D NFS_MOUNT_VERSION;
+	return mnt_version;
+}
+
+int nfs_gethostbyname(const char *, struct sockaddr_in *);
+int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
+{
+	struct hostent *hp;
+
+	saddr->sin_family =3D AF_INET;
+	if (!inet_aton(hostname, &saddr->sin_addr)) {
+		if ((hp =3D gethostbyname(hostname)) =3D=3D NULL) {
+			fprintf(stderr, _("mount: can't get address for %s\n"),
+				hostname);
+			return 0;
+		} else {
+			if (hp->h_length > sizeof(*saddr)) {
+				fprintf(stderr,
+					_("mount: got bad hp->h_length\n"));
+				hp->h_length =3D sizeof(*saddr);
+			}
+			memcpy(&saddr->sin_addr, hp->h_addr, hp->h_length);
+		}
+	}
+	return 1;
+}
+
+/*
+ * getport() is very similar to pmap_getport() with
+ * the exception this version uses a non-reserve ports=20
+ * instead of reserve ports since reserve ports
+ * are not needed for pmap requests.
+ */
+static u_short
+getport(
+	struct sockaddr_in *saddr,=20
+	u_long prog,=20
+	u_long vers,=20
+	u_int prot)
+{
+	u_short port;
+	int    socket;
+	CLIENT *clnt =3D NULL;
+	struct pmap parms;
+	enum clnt_stat stat;
+
+	saddr->sin_port =3D htons (PMAPPORT);
+	socket =3D get_socket(saddr, prot, FALSE);
+
+	switch (prot) {
+	case IPPROTO_UDP:
+		clnt =3D clntudp_bufcreate(saddr,
+					 PMAPPROG, PMAPVERS, TIMEOUT, &socket,
+					 UDPMSGSIZE, UDPMSGSIZE);
+		break;
+	case IPPROTO_TCP:
+		clnt =3D clnttcp_create(saddr,
+			PMAPPROG, PMAPVERS, &socket, 50, 500);
+		break;
+	}
+	if (clnt !=3D NULL) {
+		parms.pm_prog =3D prog;
+		parms.pm_vers =3D vers;
+		parms.pm_prot =3D prot;
+		parms.pm_port =3D 0;    /* not needed or used */
+
+		stat =3D clnt_call(clnt, PMAPPROC_GETPORT, (xdrproc_t)xdr_pmap,
+			(caddr_t)&parms, (xdrproc_t)xdr_u_short, (caddr_t)&port, TIMEOUT);
+		if (stat) {
+			clnt_geterr(clnt, &rpc_createerr.cf_error);
+			rpc_createerr.cf_stat =3D stat;
+		}
+		clnt_destroy(clnt);
+		if (stat !=3D RPC_SUCCESS)
+			port =3D 0;
+		else if (port =3D=3D 0)
+			rpc_createerr.cf_stat =3D RPC_PROGNOTREGISTERED;
+	}
+	if (socket !=3D 1)
+		close(socket);
+
+	return port;
+}
+
+/*
+ * Use the portmapper to discover whether or not the service we want is
+ * available. The lists 'versions' and 'protos' define ordered sequences
+ * of service versions and udp/tcp protocols to probe for.
+ */
+static int
+probe_port(clnt_addr_t *server,=20
+	   const u_long *versions,
+	   const u_int *protos)
+{
+	struct sockaddr_in *saddr =3D &server->saddr;
+	struct pmap *pmap =3D &server->pmap;
+	const u_long prog =3D pmap->pm_prog, *p_vers;
+	const u_int prot =3D (u_int)pmap->pm_prot,
+		*p_prot;
+	const u_short port =3D (u_short) pmap->pm_port;
+	u_long vers =3D pmap->pm_vers;
+	u_short p_port;
+	p_prot =3D prot ? &prot : protos;
+	p_vers =3D vers ? &vers : versions;
+	rpc_createerr.cf_stat =3D 0;
+	for (;;) {
+		saddr->sin_port =3D htons(PMAPPORT);
+		p_port =3D getport(saddr, prog, *p_vers, *p_prot);
+		if (p_port) {
+			if (!port || port =3D=3D p_port) {
+				saddr->sin_port =3D htons(p_port);
+				if (verbose) {
+					fprintf(stderr,=20
+						"mount: trying %s prog %ld vers %ld prot %s port %d\n",=20
+						inet_ntoa(saddr->sin_addr), prog, *p_vers,
+						*p_prot =3D=3D IPPROTO_UDP ? "udp" : "tcp", p_port);
+				}
+				if (clnt_ping(saddr, prog, *p_vers, *p_prot))
+					goto out_ok;
+				if (rpc_createerr.cf_stat =3D=3D RPC_TIMEDOUT)
+					goto out_bad;
+			}
+		}
+		if (rpc_createerr.cf_stat !=3D RPC_PROGNOTREGISTERED)=20
+			goto out_bad;
+
+		if (!prot) {
+			if (*++p_prot)
+				continue;
+			p_prot =3D protos;
+		}
+		if (vers =3D=3D pmap->pm_vers) {
+			p_vers =3D versions;
+			vers =3D 0;
+		}
+		if (vers || !*++p_vers)
+			break;
+	}
+out_bad:
+	return 0;
+
+ out_ok:
+	if (!vers)
+		pmap->pm_vers =3D *p_vers;
+	if (!prot)
+		pmap->pm_prot =3D *p_prot;
+	if (!port)
+		pmap->pm_port =3D p_port;
+	rpc_createerr.cf_stat =3D 0;
+	return 1;
+}
+
+static int
+probe_nfsport(clnt_addr_t *nfs_server)
+{
+	const struct pmap *pmap =3D &nfs_server->pmap;
+	const u_long *probe_vers;
+	const u_int *probe_prot;
+
+	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
+		return 1;
+	probe_vers =3D nfs_probelist(MAX_NFSPROT);
+	probe_prot =3D proto_probelist(HAVE_RELIABLE_TCP ? use_tcp : udp_only);
+	return probe_port(nfs_server, probe_vers, probe_prot);
+}
+
+int probe_mntport(clnt_addr_t *mnt_server)
+{
+	const struct pmap *pmap =3D &mnt_server->pmap;
+	const u_long *probe_vers;
+	const u_int *probe_prot;
+
+	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
+		return 1;
+	probe_vers =3D mnt_probelist(MAX_MNTPROT);
+	probe_prot =3D proto_probelist(HAVE_RELIABLE_TCP ? udp_tcp : udp_only);
+	return probe_port(mnt_server, probe_vers, probe_prot);
+}
+
+static int
+probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+{
+	struct pmap *nfs_pmap =3D &nfs_server->pmap;
+	struct pmap *mnt_pmap =3D &mnt_server->pmap;
+	struct pmap save_nfs, save_mnt;
+	int res;
+	const u_long *probe_vers;
+
+	if (mnt_pmap->pm_vers && !nfs_pmap->pm_vers)
+		nfs_pmap->pm_vers =3D mntvers_to_nfs(mnt_pmap->pm_vers);
+	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers)
+		mnt_pmap->pm_vers =3D nfsvers_to_mnt(nfs_pmap->pm_vers);
+	if (nfs_pmap->pm_vers)
+		goto version_fixed;
+	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
+	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
+	for (probe_vers =3D mnt_probelist(MAX_MNTPROT); *probe_vers; probe_vers=
++) {
+		nfs_pmap->pm_vers =3D mntvers_to_nfs(*probe_vers);
+		if ((res =3D probe_nfsport(nfs_server) !=3D 0)) {
+			mnt_pmap->pm_vers =3D nfsvers_to_mnt(nfs_pmap->pm_vers);
+			if ((res =3D probe_mntport(mnt_server)) !=3D 0)
+				return 1;
+			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
+		}
+		switch (rpc_createerr.cf_stat) {
+		case RPC_PROGVERSMISMATCH:
+		case RPC_PROGNOTREGISTERED:
+			break;
+		default:
+			goto out_bad;
+		}
+		memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
+	}
+ out_bad:
+	return 0;
+ version_fixed:
+	if (!probe_nfsport(nfs_server))
+		goto out_bad;
+	return probe_mntport(mnt_server);
+}
+
+static inline enum clnt_stat
+nfs3_mount(CLIENT *clnt, mnt3arg_t *mnt3arg, mnt3res_t *mnt3res)
+{
+	return clnt_call(clnt, MOUNTPROC3_MNT,
+			 (xdrproc_t) xdr_dirpath, (caddr_t) mnt3arg,
+			 (xdrproc_t) xdr_mountres3, (caddr_t) mnt3res,
+			 TIMEOUT);
+}
+
+static inline enum clnt_stat
+nfs2_mount(CLIENT *clnt, mnt2arg_t *mnt2arg, mnt2res_t *mnt2res)
+{
+	return clnt_call(clnt, MOUNTPROC_MNT,
+			 (xdrproc_t) xdr_dirpath, (caddr_t) mnt2arg,
+			 (xdrproc_t) xdr_fhstatus, (caddr_t) mnt2res,
+			 TIMEOUT);
+}
+
+static int
+nfs_call_mount(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server,
+	       mntarg_t *mntarg, mntres_t *mntres)
+{
+	CLIENT *clnt;
+	enum clnt_stat stat;
+	int msock;
+
+	if (!probe_bothports(mnt_server, nfs_server))
+		goto out_bad;
+
+	clnt =3D mnt_openclnt(mnt_server, &msock);
+	if (!clnt)
+		goto out_bad;
+	/* make pointers in xdr_mountres3 NULL so
+	 * that xdr_array allocates memory for us
+	 */
+	memset(mntres, 0, sizeof(*mntres));
+	switch (mnt_server->pmap.pm_vers) {
+	case 3:
+		stat =3D nfs3_mount(clnt, mntarg, &mntres->nfsv3);
+		break;
+	case 2:
+	case 1:
+		stat =3D nfs2_mount(clnt, mntarg, &mntres->nfsv2);
+		break;
+	default:
+		goto out_bad;
+	}
+	if (stat !=3D RPC_SUCCESS) {
+		clnt_geterr(clnt, &rpc_createerr.cf_error);
+		rpc_createerr.cf_stat =3D stat;
+	}
+	mnt_closeclnt(clnt, msock);
+	if (stat =3D=3D RPC_SUCCESS)
+		return 1;
+ out_bad:
+	return 0;
+}
+
+static int
+parse_options(char *old_opts, struct nfs_mount_data *data,
+	      int *bg, int *retry, clnt_addr_t *mnt_server,
+	      clnt_addr_t *nfs_server, char *new_opts, const int opt_size)
+{
+	struct sockaddr_in *mnt_saddr =3D &mnt_server->saddr;
+	struct pmap *mnt_pmap =3D &mnt_server->pmap;
+	struct pmap *nfs_pmap =3D &nfs_server->pmap;
+	int len;
+	char *opt, *opteq;
+	char *mounthost =3D NULL;
+	char cbuf[128];
+
+	data->flags =3D 0;
+	*bg =3D 0;
+
+	len =3D strlen(new_opts);
+	for (opt =3D strtok(old_opts, ","); opt; opt =3D strtok(NULL, ",")) {
+		if (strlen(opt) >=3D sizeof(cbuf))
+			goto bad_parameter;
+		if ((opteq =3D strchr(opt, '=3D')) && isdigit(opteq[1])) {
+			int val =3D atoi(opteq + 1);=09
+			*opteq =3D '\0';
+/* printf("opt=3D%s\n", opt); */
+			if (!strcmp(opt, "rsize"))
+				data->rsize =3D val;
+			else if (!strcmp(opt, "wsize"))
+				data->wsize =3D val;
+			else if (!strcmp(opt, "timeo"))
+				data->timeo =3D val;
+			else if (!strcmp(opt, "retrans"))
+				data->retrans =3D val;
+			else if (!strcmp(opt, "acregmin"))
+				data->acregmin =3D val;
+			else if (!strcmp(opt, "acregmax"))
+				data->acregmax =3D val;
+			else if (!strcmp(opt, "acdirmin"))
+				data->acdirmin =3D val;
+			else if (!strcmp(opt, "acdirmax"))
+				data->acdirmax =3D val;
+			else if (!strcmp(opt, "actimeo")) {
+				data->acregmin =3D val;
+				data->acregmax =3D val;
+				data->acdirmin =3D val;
+				data->acdirmax =3D val;
+			}
+			else if (!strcmp(opt, "retry"))
+				*retry =3D val;
+			else if (!strcmp(opt, "port"))
+				nfs_pmap->pm_port =3D val;
+			else if (!strcmp(opt, "mountport"))
+			        mnt_pmap->pm_port =3D val;
+			else if (!strcmp(opt, "mountprog"))
+				mnt_pmap->pm_prog =3D val;
+			else if (!strcmp(opt, "mountvers"))
+				mnt_pmap->pm_vers =3D val;
+			else if (!strcmp(opt, "mounthost"))
+				mounthost=3Dxstrndup(opteq+1, strcspn(opteq+1," \t\n\r,"));
+			else if (!strcmp(opt, "nfsprog"))
+				nfs_pmap->pm_prog =3D val;
+			else if (!strcmp(opt, "nfsvers") ||
+				 !strcmp(opt, "vers")) {
+				nfs_pmap->pm_vers =3D val;
+				opt =3D "nfsvers";
+#if NFS_MOUNT_VERSION >=3D 2
+			} else if (!strcmp(opt, "namlen")) {
+				if (nfs_mount_version >=3D 2)
+					data->namlen =3D val;
+				else
+					goto bad_parameter;
+#endif
+			} else if (!strcmp(opt, "addr")) {
+				/* ignore */;
+				continue;
+ 			} else
+				goto bad_parameter;
+			sprintf(cbuf, "%s=3D%s,", opt, opteq+1);
+		} else if (opteq) {
+			*opteq =3D '\0';
+			if (!strcmp(opt, "proto")) {
+				if (!strcmp(opteq+1, "udp")) {
+					nfs_pmap->pm_prot =3D IPPROTO_UDP;
+					mnt_pmap->pm_prot =3D IPPROTO_UDP;
+#if NFS_MOUNT_VERSION >=3D 2
+					data->flags &=3D ~NFS_MOUNT_TCP;
+				} else if (!strcmp(opteq+1, "tcp") &&
+					   nfs_mount_version > 2) {
+					nfs_pmap->pm_prot =3D IPPROTO_TCP;
+					mnt_pmap->pm_prot =3D IPPROTO_TCP;
+					data->flags |=3D NFS_MOUNT_TCP;
+#endif
+				} else
+					goto bad_parameter;
+#if NFS_MOUNT_VERSION >=3D 5
+			} else if (!strcmp(opt, "sec")) {
+				char *secflavor =3D opteq+1;
+				/* see RFC 2623 */
+				if (nfs_mount_version < 5) {
+					printf(_("Warning: ignoring sec=3D%s option\n"), secflavor);
+					continue;
+				} else if (!strcmp(secflavor, "sys"))
+					data->pseudoflavor =3D AUTH_SYS;
+				else if (!strcmp(secflavor, "krb5"))
+					data->pseudoflavor =3D AUTH_GSS_KRB5;
+				else if (!strcmp(secflavor, "krb5i"))
+					data->pseudoflavor =3D AUTH_GSS_KRB5I;
+				else if (!strcmp(secflavor, "krb5p"))
+					data->pseudoflavor =3D AUTH_GSS_KRB5P;
+				else if (!strcmp(secflavor, "lipkey"))
+					data->pseudoflavor =3D AUTH_GSS_LKEY;
+				else if (!strcmp(secflavor, "lipkey-i"))
+					data->pseudoflavor =3D AUTH_GSS_LKEYI;
+				else if (!strcmp(secflavor, "lipkey-p"))
+					data->pseudoflavor =3D AUTH_GSS_LKEYP;
+				else if (!strcmp(secflavor, "spkm3"))
+					data->pseudoflavor =3D AUTH_GSS_SPKM;
+				else if (!strcmp(secflavor, "spkm3i"))
+					data->pseudoflavor =3D AUTH_GSS_SPKMI;
+				else if (!strcmp(secflavor, "spkm3p"))
+					data->pseudoflavor =3D AUTH_GSS_SPKMP;
+				else {
+					printf(_("Warning: Unrecognized security flavor %s.\n"),
+						secflavor);
+					goto bad_parameter;
+				}
+				data->flags |=3D NFS_MOUNT_SECFLAVOUR;
+#endif
+			} else if (!strcmp(opt, "mounthost"))
+			        mounthost=3Dxstrndup(opteq+1,
+						   strcspn(opteq+1," \t\n\r,"));
+			 else if (!strcmp(opt, "context")) {
+ 				char *context =3D opteq + 1;
+ 			=09
+ 				if (strlen(context) > NFS_MAX_CONTEXT_LEN) {
+ 					printf(_("context parameter exceeds limit of %d\n"),
+ 						 NFS_MAX_CONTEXT_LEN);
+					goto bad_parameter;
+ 				}
+ 				strncpy(data->context, context, NFS_MAX_CONTEXT_LEN);
+ 			} else
+				goto bad_parameter;
+			sprintf(cbuf, "%s=3D%s,", opt, opteq+1);
+		} else {
+			int val =3D 1;
+			if (!strncmp(opt, "no", 2)) {
+				val =3D 0;
+				opt +=3D 2;
+			}
+			if (!strcmp(opt, "bg"))=20
+				*bg =3D val;
+			else if (!strcmp(opt, "fg"))=20
+				*bg =3D !val;
+			else if (!strcmp(opt, "soft")) {
+				data->flags &=3D ~NFS_MOUNT_SOFT;
+				if (val)
+					data->flags |=3D NFS_MOUNT_SOFT;
+			} else if (!strcmp(opt, "hard")) {
+				data->flags &=3D ~NFS_MOUNT_SOFT;
+				if (!val)
+					data->flags |=3D NFS_MOUNT_SOFT;
+			} else if (!strcmp(opt, "intr")) {
+				data->flags &=3D ~NFS_MOUNT_INTR;
+				if (val)
+					data->flags |=3D NFS_MOUNT_INTR;
+			} else if (!strcmp(opt, "posix")) {
+				data->flags &=3D ~NFS_MOUNT_POSIX;
+				if (val)
+					data->flags |=3D NFS_MOUNT_POSIX;
+			} else if (!strcmp(opt, "cto")) {
+				data->flags &=3D ~NFS_MOUNT_NOCTO;
+				if (!val)
+					data->flags |=3D NFS_MOUNT_NOCTO;
+			} else if (!strcmp(opt, "ac")) {
+				data->flags &=3D ~NFS_MOUNT_NOAC;
+				if (!val)
+					data->flags |=3D NFS_MOUNT_NOAC;
+#if NFS_MOUNT_VERSION >=3D 2
+			} else if (!strcmp(opt, "tcp")) {
+				data->flags &=3D ~NFS_MOUNT_TCP;
+				if (val) {
+					if (nfs_mount_version < 2)
+						goto bad_option;
+					nfs_pmap->pm_prot =3D IPPROTO_TCP;
+					mnt_pmap->pm_prot =3D IPPROTO_TCP;
+					data->flags |=3D NFS_MOUNT_TCP;
+				} else {
+					mnt_pmap->pm_prot =3D IPPROTO_UDP;
+					nfs_pmap->pm_prot =3D IPPROTO_UDP;
+				}
+			} else if (!strcmp(opt, "udp")) {
+				data->flags &=3D ~NFS_MOUNT_TCP;
+				if (!val) {
+					if (nfs_mount_version < 2)
+						goto bad_option;
+					nfs_pmap->pm_prot =3D IPPROTO_TCP;
+					mnt_pmap->pm_prot =3D IPPROTO_TCP;
+					data->flags |=3D NFS_MOUNT_TCP;
+				} else {
+					nfs_pmap->pm_prot =3D IPPROTO_UDP;
+					mnt_pmap->pm_prot =3D IPPROTO_UDP;
+				}
+#endif
+#if NFS_MOUNT_VERSION >=3D 3
+			} else if (!strcmp(opt, "lock")) {
+				data->flags &=3D ~NFS_MOUNT_NONLM;
+				if (!val) {
+					if (nfs_mount_version < 3)
+						goto bad_option;
+					data->flags |=3D NFS_MOUNT_NONLM;
+				}
+#endif
+#if NFS_MOUNT_VERSION >=3D 4
+			} else if (!strcmp(opt, "broken_suid")) {
+				data->flags &=3D ~NFS_MOUNT_BROKEN_SUID;
+				if (val) {
+					if (nfs_mount_version < 4)
+						goto bad_option;
+					data->flags |=3D NFS_MOUNT_BROKEN_SUID;
+				}
+			} else if (!strcmp(opt, "acl")) {
+				data->flags &=3D ~NFS_MOUNT_NOACL;
+				if (!val)
+					data->flags |=3D NFS_MOUNT_NOACL;
+#endif
+			} else {
+			bad_option:
+				printf(_("Unsupported nfs mount option: "
+					 "%s%s\n"), val ? "" : "no", opt);
+				goto out_bad;
+			}
+			sprintf(cbuf, val ? "%s,":"no%s,", opt);
+		}
+		len +=3D strlen(cbuf);
+		if (len >=3D opt_size) {
+			printf(_("mount: excessively long option argument\n"));
+			goto out_bad;
+		}
+		strcat(new_opts, cbuf);
+	}
+	/* See if the nfs host =3D mount host. */
+	if (mounthost) {
+		if (!nfs_gethostbyname(mounthost, mnt_saddr))
+			goto out_bad;
+		*mnt_server->hostname =3D mounthost;
+	}
+	return 1;
+ bad_parameter:
+	printf(_("Bad nfs mount parameter: %s\n"), opt);
+ out_bad:
+	return 0;
+}
+
+static inline int
+nfsmnt_check_compat(const struct pmap *nfs_pmap, const struct pmap *mnt_=
pmap)
+{
+	if (nfs_pmap->pm_vers &&=20
+		(nfs_pmap->pm_vers > MAX_NFSPROT || nfs_pmap->pm_vers < 2)) {
+		if (nfs_pmap->pm_vers =3D=3D 4)
+			fprintf(stderr, _("'vers=3D4' is not supported.  "
+				"Use '-t nfs4' instead.\n"));
+		else
+			fprintf(stderr, _("NFS version %ld is not supported.\n"),=20
+				nfs_pmap->pm_vers);
+		goto out_bad;
+	}
+	if (mnt_pmap->pm_vers > MAX_MNTPROT) {
+		fprintf(stderr, _("NFS mount version %ld s not supported.\n"),=20
+			mnt_pmap->pm_vers);
+		goto out_bad;
+	}
+	return 1;
+ out_bad:
+	return 0;
+}
+
+int
+nfsmount(const char *spec, const char *node, int *flags,
+	 char **extra_opts, char **mount_opts, int *nfs_mount_vers,
+	 int running_bg)
+{
+	static char *prev_bg_host;
+	char hostdir[1024];
+	char *hostname, *dirname, *old_opts, *mounthost =3D NULL;
+	char new_opts[1024], cbuf[1024];
+	static struct nfs_mount_data data;
+	int val;
+	static int doonce =3D 0;
+
+	clnt_addr_t mnt_server =3D { &mounthost, };
+	clnt_addr_t nfs_server =3D { &hostname, };
+	struct sockaddr_in *nfs_saddr =3D &nfs_server.saddr;
+	struct pmap  *mnt_pmap =3D &mnt_server.pmap,=20
+		     *nfs_pmap =3D &nfs_server.pmap;
+	struct pmap  save_mnt, save_nfs;
+
+	int fsock;
+
+	mntres_t mntres;
+
+	struct stat statbuf;
+	char *s;
+	int bg, retry;
+	int retval;
+	time_t t;
+	time_t prevt;
+	time_t timeout;
+
+	/* The version to try is either specified or 0
+	   In case it is 0 we tell the caller what we tried */
+	if (!*nfs_mount_vers)
+		*nfs_mount_vers =3D find_kernel_nfs_mount_version();
+	nfs_mount_version =3D *nfs_mount_vers;
+
+	retval =3D EX_FAIL;
+	fsock =3D -1;
+	if (strlen(spec) >=3D sizeof(hostdir)) {
+		fprintf(stderr, _("mount: "
+				  "excessively long host:dir argument\n"));
+		goto fail;
+	}
+	strcpy(hostdir, spec);
+	if ((s =3D strchr(hostdir, ':'))) {
+		hostname =3D hostdir;
+		dirname =3D s + 1;
+		*s =3D '\0';
+		/* Ignore all but first hostname in replicated mounts
+		   until they can be fully supported. (mack@sgi.com) */
+		if ((s =3D strchr(hostdir, ','))) {
+			*s =3D '\0';
+			fprintf(stderr,
+				_("mount: warning: "
+				  "multiple hostnames not supported\n"));
+		}
+	} else {
+		fprintf(stderr,
+			_("mount: "
+			  "directory to mount not in host:dir format\n"));
+		goto fail;
+	}
+
+	if (!nfs_gethostbyname(hostname, nfs_saddr))
+		goto fail;
+	mounthost =3D hostname;
+	memcpy (&mnt_server.saddr, nfs_saddr, sizeof (mnt_server.saddr));
+
+	/* add IP address to mtab options for use when unmounting */
+
+	s =3D inet_ntoa(nfs_saddr->sin_addr);
+	old_opts =3D *extra_opts;
+	if (!old_opts)
+		old_opts =3D "";
+
+	/* Set default options.
+	 * rsize/wsize (and bsize, for ver >=3D 3) are left 0 in order to
+	 * let the kernel decide.
+	 * timeo is filled in after we know whether it'll be TCP or UDP. */
+	memset(&data, 0, sizeof(data));
+	data.acregmin	=3D 3;
+	data.acregmax	=3D 60;
+	data.acdirmin	=3D 30;
+	data.acdirmax	=3D 60;
+#if NFS_MOUNT_VERSION >=3D 2
+	data.namlen	=3D NAME_MAX;
+#endif
+	data.pseudoflavor =3D AUTH_SYS;
+
+	bg =3D 0;
+	retry =3D 10000;		/* 10000 minutes ~ 1 week */
+
+	memset(mnt_pmap, 0, sizeof(*mnt_pmap));
+	mnt_pmap->pm_prog =3D MOUNTPROG;
+	memset(nfs_pmap, 0, sizeof(*nfs_pmap));
+	nfs_pmap->pm_prog =3D NFS_PROGRAM;
+
+	/* parse options */
+	new_opts[0] =3D 0;
+	if (!parse_options(old_opts, &data, &bg, &retry, &mnt_server, &nfs_serv=
er,
+			   new_opts, sizeof(new_opts)))
+		goto fail;
+	if (!nfsmnt_check_compat(nfs_pmap, mnt_pmap))
+		goto fail;
+=09
+	if (retry =3D=3D 10000 && !bg)
+		retry =3D 2; /* reset for fg mounts */
+=09
+
+#ifdef NFS_MOUNT_DEBUG
+	printf("rsize =3D %d, wsize =3D %d, timeo =3D %d, retrans =3D %d\n",
+	       data.rsize, data.wsize, data.timeo, data.retrans);
+	printf("acreg (min, max) =3D (%d, %d), acdir (min, max) =3D (%d, %d)\n"=
,
+	       data.acregmin, data.acregmax, data.acdirmin, data.acdirmax);
+	printf("port =3D %d, bg =3D %d, retry =3D %d, flags =3D %.8x\n",
+	       nfs_pmap->pm_port, bg, retry, data.flags);
+	printf("mountprog =3D %d, mountvers =3D %d, nfsprog =3D %d, nfsvers =3D=
 %d\n",
+	       mnt_pmap->pm_prog, mnt_pmap->pm_vers,
+	       nfs_pmap->pm_prog, nfs_pmap->pm_vers);
+	printf("soft =3D %d, intr =3D %d, posix =3D %d, nocto =3D %d, noac =3D =
%d ",
+	       (data.flags & NFS_MOUNT_SOFT) !=3D 0,
+	       (data.flags & NFS_MOUNT_INTR) !=3D 0,
+	       (data.flags & NFS_MOUNT_POSIX) !=3D 0,
+	       (data.flags & NFS_MOUNT_NOCTO) !=3D 0,
+	       (data.flags & NFS_MOUNT_NOAC) !=3D 0);
+#if NFS_MOUNT_VERSION >=3D 2
+	printf("tcp =3D %d ",
+	       (data.flags & NFS_MOUNT_TCP) !=3D 0);
+#endif
+#if NFS_MOUNT_VERSION >=3D 4
+	printf("noacl =3D %d ", (data.flags & NFS_MOUNT_NOACL) !=3D 0);
+#endif
+#if NFS_MOUNT_VERSION >=3D 5
+	printf("sec =3D %u ", data.pseudoflavor);
+#endif
+	printf("\n");
+#endif
+
+	data.version =3D nfs_mount_version;
+	*mount_opts =3D (char *) &data;
+
+	if (*flags & MS_REMOUNT)
+		goto out_ok;
+
+	/*
+	 * If the previous mount operation on the same host was
+	 * backgrounded, and the "bg" for this mount is also set,
+	 * give up immediately, to avoid the initial timeout.
+	 */
+	if (bg && !running_bg &&
+	    prev_bg_host && strcmp(hostname, prev_bg_host) =3D=3D 0) {
+		if (retry > 0)
+			retval =3D EX_BG;
+		return retval;
+	}
+
+	/* create mount deamon client */
+
+	/*
+	 * The following loop implements the mount retries. On the first
+	 * call, "running_bg" is 0. When the mount times out, and the
+	 * "bg" option is set, the exit status EX_BG will be returned.
+	 * For a backgrounded mount, there will be a second call by the
+	 * child process with "running_bg" set to 1.
+	 *
+	 * The case where the mount point is not present and the "bg"
+	 * option is set, is treated as a timeout. This is done to
+	 * support nested mounts.
+	 *
+	 * The "retry" count specified by the user is the number of
+	 * minutes to retry before giving up.
+	 *
+	 * Only the first error message will be displayed.
+	 */
+	timeout =3D time(NULL) + 60 * retry;
+	prevt =3D 0;
+	t =3D 30;
+	val =3D 1;
+
+	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
+	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
+	for (;;) {
+		if (bg && stat(node, &statbuf) =3D=3D -1) {
+			/* no mount point yet - sleep */
+			if (running_bg) {
+				sleep(val);	/* 1, 2, 4, 8, 16, 30, ... */
+				val *=3D 2;
+				if (val > 30)
+					val =3D 30;
+			}
+		} else {
+			int stat;
+			/* be careful not to use too many CPU cycles */
+			if (t - prevt < 30)
+				sleep(30);
+
+			stat =3D nfs_call_mount(&mnt_server, &nfs_server,
+					      &dirname, &mntres);
+			if (stat)
+				break;
+			memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
+			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
+			prevt =3D t;
+		}
+		if (!bg) {
+			switch(rpc_createerr.cf_stat){
+			case RPC_TIMEDOUT:
+				break;
+			case RPC_SYSTEMERROR:
+				if (errno =3D=3D ETIMEDOUT)
+					break;
+			default:
+				mount_errors(*nfs_server.hostname, 0, bg);
+		        goto fail;
+			}
+			t =3D time(NULL);
+			if (t >=3D timeout) {
+				mount_errors(*nfs_server.hostname, 0, bg);
+				goto fail;
+			}
+			mount_errors(*nfs_server.hostname, 1, bg);
+			continue;
+		}
+		if (!running_bg) {
+			prev_bg_host =3D xstrdup(hostname);
+			if (retry > 0)
+				retval =3D EX_BG;
+			goto fail;
+		}
+		t =3D time(NULL);
+		if (t >=3D timeout) {
+			mount_errors(*nfs_server.hostname, 0, bg);
+			goto fail;
+		}
+		if (doonce++ < 1)
+			mount_errors(*nfs_server.hostname, 1, bg);
+	}
+
+	if (nfs_pmap->pm_vers =3D=3D 2) {
+		if (mntres.nfsv2.fhs_status !=3D 0) {
+			fprintf(stderr,
+				_("mount: %s:%s failed, reason given by server: %s\n"),
+				hostname, dirname,
+				nfs_strerror(mntres.nfsv2.fhs_status));
+			goto fail;
+		}
+		memcpy(data.root.data,
+		       (char *) mntres.nfsv2.fhstatus_u.fhs_fhandle,
+		       NFS_FHSIZE);
+#if NFS_MOUNT_VERSION >=3D 4
+		data.root.size =3D NFS_FHSIZE;
+		memcpy(data.old_root.data,
+		       (char *) mntres.nfsv2.fhstatus_u.fhs_fhandle,
+		       NFS_FHSIZE);
+#endif
+	} else {
+#if NFS_MOUNT_VERSION >=3D 4
+		mountres3_ok *mountres;
+		fhandle3 *fhandle;
+		int i, *flavor, yum =3D 0;
+		if (mntres.nfsv3.fhs_status !=3D 0) {
+			fprintf(stderr,
+				_("mount: %s:%s failed, reason given by server: %s\n"),
+				hostname, dirname,
+				nfs_strerror(mntres.nfsv3.fhs_status));
+			goto fail;
+		}
+#if NFS_MOUNT_VERSION >=3D 5
+		mountres =3D &mntres.nfsv3.mountres3_u.mountinfo;
+		i =3D mountres->auth_flavours.auth_flavours_len;
+		if (i <=3D 0)=20
+			goto noauth_flavours;
+
+		flavor =3D mountres->auth_flavours.auth_flavours_val;
+		while (--i >=3D 0) {
+			if (flavor[i] =3D=3D data.pseudoflavor)
+				yum =3D 1;
+#ifdef NFS_MOUNT_DEBUG
+			printf("auth flavor %d: %d\n",
+				i, flavor[i]);
+#endif
+		}
+		if (!yum) {
+			fprintf(stderr,
+				"mount: %s:%s failed, "
+				"security flavor not supported\n",
+				hostname, dirname);
+			/* server has registered us in mtab, send umount */
+			nfs_call_umount(&mnt_server, &dirname);
+			goto fail;
+		}
+noauth_flavours:
+#endif
+		fhandle =3D &mntres.nfsv3.mountres3_u.mountinfo.fhandle;
+		memset(data.old_root.data, 0, NFS_FHSIZE);
+		memset(&data.root, 0, sizeof(data.root));
+		data.root.size =3D fhandle->fhandle3_len;
+		memcpy(data.root.data,
+		       (char *) fhandle->fhandle3_val,
+		       fhandle->fhandle3_len);
+
+		data.flags |=3D NFS_MOUNT_VER3;
+#endif
+	}
+
+	/* create nfs socket for kernel */
+
+	if (nfs_pmap->pm_prot =3D=3D IPPROTO_TCP)
+		fsock =3D socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
+	else
+		fsock =3D socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
+	if (fsock < 0) {
+		perror(_("nfs socket"));
+		goto fail;
+	}
+	if (bindresvport(fsock, 0) < 0) {
+		perror(_("nfs bindresvport"));
+		goto fail;
+	}
+#ifdef NFS_MOUNT_DEBUG
+	printf(_("using port %d for nfs deamon\n"), nfs_pmap->pm_port);
+#endif
+	nfs_saddr->sin_port =3D htons(nfs_pmap->pm_port);
+	/*
+	 * connect() the socket for kernels 1.3.10 and below only,
+	 * to avoid problems with multihomed hosts.
+	 * --Swen
+	 */
+	if (linux_version_code() <=3D 66314
+	    && connect(fsock, (struct sockaddr *) nfs_saddr,
+		       sizeof (*nfs_saddr)) < 0) {
+		perror(_("nfs connect"));
+		goto fail;
+	}
+
+#if NFS_MOUNT_VERSION >=3D 2
+	if (nfs_pmap->pm_prot =3D=3D IPPROTO_TCP)
+		data.flags |=3D NFS_MOUNT_TCP;
+	else
+		data.flags &=3D ~NFS_MOUNT_TCP;
+#endif
+
+	/* prepare data structure for kernel */
+
+	data.fd =3D fsock;
+	memcpy((char *) &data.addr, (char *) nfs_saddr, sizeof(data.addr));
+	strncpy(data.hostname, hostname, sizeof(data.hostname));
+
+ out_ok:
+	/* Ensure we have enough padding for the following strcat()s */
+	if (strlen(new_opts) + strlen(s) + 30 >=3D sizeof(new_opts)) {
+		fprintf(stderr, _("mount: "
+				  "excessively long option argument\n"));
+		goto fail;
+	}
+
+	snprintf(cbuf, sizeof(cbuf)-1, "addr=3D%s", s);
+	strcat(new_opts, cbuf);
+
+	*extra_opts =3D xstrdup(new_opts);
+	return 0;
+
+	/* abort */
+ fail:
+	if (fsock !=3D -1)
+		close(fsock);
+	return retval;
+}
+
+/*
+ * We need to translate between nfs status return values and
+ * the local errno values which may not be the same.
+ *
+ * Andreas Schwab <schwab@LS5.informatik.uni-dortmund.de>: change errno:
+ * "after #include <errno.h> the symbol errno is reserved for any use,
+ *  it cannot even be used as a struct tag or field name".
+ */
+
+#ifndef EDQUOT
+#define EDQUOT	ENOSPC
+#endif
+
+static struct {
+	enum nfsstat stat;
+	int errnum;
+} nfs_errtbl[] =3D {
+	{ NFS_OK,		0		},
+	{ NFSERR_PERM,		EPERM		},
+	{ NFSERR_NOENT,		ENOENT		},
+	{ NFSERR_IO,		EIO		},
+	{ NFSERR_NXIO,		ENXIO		},
+	{ NFSERR_ACCES,		EACCES		},
+	{ NFSERR_EXIST,		EEXIST		},
+	{ NFSERR_NODEV,		ENODEV		},
+	{ NFSERR_NOTDIR,	ENOTDIR		},
+	{ NFSERR_ISDIR,		EISDIR		},
+#ifdef NFSERR_INVAL
+	{ NFSERR_INVAL,		EINVAL		},	/* that Sun forgot */
+#endif
+	{ NFSERR_FBIG,		EFBIG		},
+	{ NFSERR_NOSPC,		ENOSPC		},
+	{ NFSERR_ROFS,		EROFS		},
+	{ NFSERR_NAMETOOLONG,	ENAMETOOLONG	},
+	{ NFSERR_NOTEMPTY,	ENOTEMPTY	},
+	{ NFSERR_DQUOT,		EDQUOT		},
+	{ NFSERR_STALE,		ESTALE		},
+#ifdef EWFLUSH
+	{ NFSERR_WFLUSH,	EWFLUSH		},
+#endif
+	/* Throw in some NFSv3 values for even more fun (HP returns these) */
+	{ 71,			EREMOTE		},
+
+	{ -1,			EIO		}
+};
+
+static char *nfs_strerror(int stat)
+{
+	int i;
+	static char buf[256];
+
+	for (i =3D 0; nfs_errtbl[i].stat !=3D -1; i++) {
+		if (nfs_errtbl[i].stat =3D=3D stat)
+			return strerror(nfs_errtbl[i].errnum);
+	}
+	sprintf(buf, _("unknown nfs status return value: %d"), stat);
+	return buf;
+}
diff -uprN nfs-utils-1.0.8/utils/mount/nfs_mount.h nfs-utils-1.0.8-ag/uti=
ls/mount/nfs_mount.h
--- nfs-utils-1.0.8/utils/mount/nfs_mount.h	1969-12-31 19:00:00.000000000=
 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfs_mount.h	2006-06-08 11:22:22.146815=
000 -0400
@@ -0,0 +1,82 @@
+/*
+ * We want to be able to compile mount on old kernels in such a way
+ * that the binary will work well on more recent kernels.
+ * Thus, if necessary we teach nfsmount.c the structure of new fields
+ * that will come later.
+ *
+ * Moreover, the new kernel includes conflict with glibc includes
+ * so it is easiest to ignore the kernel altogether (at compile time).
+ */
+
+#ifndef _NFS_MOUNT_H
+#define _NFS_MOUNT_H
+
+#define NFS_MOUNT_VERSION 6
+#define NFS_MAX_CONTEXT_LEN   256
+
+
+struct nfs2_fh {
+        char                    data[32];
+};
+struct nfs3_fh {
+        unsigned short          size;
+        unsigned char           data[64];
+};
+
+struct nfs_mount_data {
+	int		version;		/* 1 */
+	int		fd;			/* 1 */
+	struct nfs2_fh	old_root;		/* 1 */
+	int		flags;			/* 1 */
+	int		rsize;			/* 1 */
+	int		wsize;			/* 1 */
+	int		timeo;			/* 1 */
+	int		retrans;		/* 1 */
+	int		acregmin;		/* 1 */
+	int		acregmax;		/* 1 */
+	int		acdirmin;		/* 1 */
+	int		acdirmax;		/* 1 */
+	struct sockaddr_in addr;		/* 1 */
+	char		hostname[256];		/* 1 */
+	int		namlen;			/* 2 */
+	unsigned int	bsize;			/* 3 */
+	struct nfs3_fh	root;			/* 4 */
+	int		pseudoflavor;		/* 5 */
+	char    context[NFS_MAX_CONTEXT_LEN + 1]; /* 6 */
+
+};
+
+/* bits in the flags field */
+
+#define NFS_MOUNT_SOFT		0x0001	/* 1 */
+#define NFS_MOUNT_INTR		0x0002	/* 1 */
+#define NFS_MOUNT_SECURE	0x0004	/* 1 */
+#define NFS_MOUNT_POSIX		0x0008	/* 1 */
+#define NFS_MOUNT_NOCTO		0x0010	/* 1 */
+#define NFS_MOUNT_NOAC		0x0020	/* 1 */
+#define NFS_MOUNT_TCP		0x0040	/* 2 */
+#define NFS_MOUNT_VER3		0x0080	/* 3 */
+#define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
+#define NFS_MOUNT_NONLM		0x0200	/* 3 */
+#define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
+#define NFS_MOUNT_NOACL     0x0800  /* 4 */
+#define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
+
+/* security pseudoflavors */
+
+#ifndef AUTH_GSS_KRB5
+#define AUTH_GSS_KRB5		390003
+#define AUTH_GSS_KRB5I		390004
+#define AUTH_GSS_KRB5P		390005
+#define AUTH_GSS_LKEY		390006
+#define AUTH_GSS_LKEYI		390007
+#define AUTH_GSS_LKEYP		390008
+#define AUTH_GSS_SPKM		390009
+#define AUTH_GSS_SPKMI		390010
+#define AUTH_GSS_SPKMP		390011
+#endif
+
+int nfsmount(const char *, const char *, int *, char **,
+		char **, int *, int);
+
+#endif /* _NFS_MOUNT_NFS */
diff -uprN nfs-utils-1.0.8/utils/mount/nfsmount.h nfs-utils-1.0.8-ag/util=
s/mount/nfsmount.h
--- nfs-utils-1.0.8/utils/mount/nfsmount.h	1969-12-31 19:00:00.000000000 =
-0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfsmount.h	2006-06-08 11:22:22.1528160=
00 -0400
@@ -0,0 +1,328 @@
+/*
+ * Please do not edit this file.
+ * It was generated using rpcgen.
+ */
+
+#ifndef _NFSMOUNT_H_RPCGEN
+#define _NFSMOUNT_H_RPCGEN
+
+#include <rpc/rpc.h>
+
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+/*
+ * Sun RPC is a product of Sun Microsystems, Inc. and is provided for
+ * unrestricted use provided that this legend is included on all tape
+ * media and as a part of the software program in whole or part.  Users
+ * may copy or modify Sun RPC without charge, but are not authorized
+ * to license or distribute it to anyone else except as part of a produc=
t or
+ * program developed by the user or with the express written consent of
+ * Sun Microsystems, Inc.
+ *
+ * SUN RPC IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING TH=
E
+ * WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
+ *
+ * Sun RPC is provided with no support and without any obligation on the
+ * part of Sun Microsystems, Inc. to assist in its use, correction,
+ * modification or enhancement.
+ *
+ * SUN MICROSYSTEMS, INC. SHALL HAVE NO LIABILITY WITH RESPECT TO THE
+ * INFRINGEMENT OF COPYRIGHTS, TRADE SECRETS OR ANY PATENTS BY SUN RPC
+ * OR ANY PART THEREOF.
+ *
+ * In no event will Sun Microsystems, Inc. be liable for any lost revenu=
e
+ * or profits or other special, indirect and consequential damages, even=
 if
+ * Sun has been advised of the possibility of such damages.
+ *
+ * Sun Microsystems, Inc.
+ * 2550 Garcia Avenue
+ * Mountain View, California  94043
+ */
+/*
+ * Copyright (c) 1985, 1990 by Sun Microsystems, Inc.
+ */
+
+/* from @(#)mount.x	1.3 91/03/11 TIRPC 1.0 */
+#ifndef _rpcsvc_mount_h
+#define _rpcsvc_mount_h
+#include <asm/types.h>
+#define MNTPATHLEN 1024
+#define MNTNAMLEN 255
+#define FHSIZE 32
+#define FHSIZE3 64
+
+typedef char fhandle[FHSIZE];
+
+typedef struct {
+	u_int fhandle3_len;
+	char *fhandle3_val;
+} fhandle3;
+
+enum mountstat3 {
+	MNT_OK =3D 0,
+	MNT3ERR_PERM =3D 1,
+	MNT3ERR_NOENT =3D 2,
+	MNT3ERR_IO =3D 5,
+	MNT3ERR_ACCES =3D 13,
+	MNT3ERR_NOTDIR =3D 20,
+	MNT3ERR_INVAL =3D 22,
+	MNT3ERR_NAMETOOLONG =3D 63,
+	MNT3ERR_NOTSUPP =3D 10004,
+	MNT3ERR_SERVERFAULT =3D 10006,
+};
+typedef enum mountstat3 mountstat3;
+
+struct fhstatus {
+	u_int fhs_status;
+	union {
+		fhandle fhs_fhandle;
+	} fhstatus_u;
+};
+typedef struct fhstatus fhstatus;
+
+struct mountres3_ok {
+	fhandle3 fhandle;
+	struct {
+		u_int auth_flavours_len;
+		int *auth_flavours_val;
+	} auth_flavours;
+};
+typedef struct mountres3_ok mountres3_ok;
+
+struct mountres3 {
+	mountstat3 fhs_status;
+	union {
+		mountres3_ok mountinfo;
+	} mountres3_u;
+};
+typedef struct mountres3 mountres3;
+
+typedef char *dirpath;
+
+typedef char *name;
+
+typedef struct mountbody *mountlist;
+
+struct mountbody {
+	name ml_hostname;
+	dirpath ml_directory;
+	mountlist ml_next;
+};
+typedef struct mountbody mountbody;
+
+typedef struct groupnode *groups;
+
+struct groupnode {
+	name gr_name;
+	groups gr_next;
+};
+typedef struct groupnode groupnode;
+
+typedef struct exportnode *exports;
+
+struct exportnode {
+	dirpath ex_dir;
+	groups ex_groups;
+	exports ex_next;
+};
+typedef struct exportnode exportnode;
+
+struct ppathcnf {
+	int pc_link_max;
+	short pc_max_canon;
+	short pc_max_input;
+	short pc_name_max;
+	short pc_path_max;
+	short pc_pipe_buf;
+	u_char pc_vdisable;
+	char pc_xxx;
+	short pc_mask[2];
+};
+typedef struct ppathcnf ppathcnf;
+#endif /*!_rpcsvc_mount_h*/
+
+#define MOUNTPROG 100005
+#define MOUNTVERS 1
+
+#if defined(__STDC__) || defined(__cplusplus)
+#define MOUNTPROC_NULL 0
+extern  void * mountproc_null_1(void *, CLIENT *);
+extern  void * mountproc_null_1_svc(void *, struct svc_req *);
+#define MOUNTPROC_MNT 1
+extern  fhstatus * mountproc_mnt_1(dirpath *, CLIENT *);
+extern  fhstatus * mountproc_mnt_1_svc(dirpath *, struct svc_req *);
+#define MOUNTPROC_DUMP 2
+extern  mountlist * mountproc_dump_1(void *, CLIENT *);
+extern  mountlist * mountproc_dump_1_svc(void *, struct svc_req *);
+#define MOUNTPROC_UMNT 3
+extern  void * mountproc_umnt_1(dirpath *, CLIENT *);
+extern  void * mountproc_umnt_1_svc(dirpath *, struct svc_req *);
+#define MOUNTPROC_UMNTALL 4
+extern  void * mountproc_umntall_1(void *, CLIENT *);
+extern  void * mountproc_umntall_1_svc(void *, struct svc_req *);
+#define MOUNTPROC_EXPORT 5
+extern  exports * mountproc_export_1(void *, CLIENT *);
+extern  exports * mountproc_export_1_svc(void *, struct svc_req *);
+#define MOUNTPROC_EXPORTALL 6
+extern  exports * mountproc_exportall_1(void *, CLIENT *);
+extern  exports * mountproc_exportall_1_svc(void *, struct svc_req *);
+extern int mountprog_1_freeresult (SVCXPRT *, xdrproc_t, caddr_t);
+
+#else /* K&R C */
+#define MOUNTPROC_NULL 0
+extern  void * mountproc_null_1();
+extern  void * mountproc_null_1_svc();
+#define MOUNTPROC_MNT 1
+extern  fhstatus * mountproc_mnt_1();
+extern  fhstatus * mountproc_mnt_1_svc();
+#define MOUNTPROC_DUMP 2
+extern  mountlist * mountproc_dump_1();
+extern  mountlist * mountproc_dump_1_svc();
+#define MOUNTPROC_UMNT 3
+extern  void * mountproc_umnt_1();
+extern  void * mountproc_umnt_1_svc();
+#define MOUNTPROC_UMNTALL 4
+extern  void * mountproc_umntall_1();
+extern  void * mountproc_umntall_1_svc();
+#define MOUNTPROC_EXPORT 5
+extern  exports * mountproc_export_1();
+extern  exports * mountproc_export_1_svc();
+#define MOUNTPROC_EXPORTALL 6
+extern  exports * mountproc_exportall_1();
+extern  exports * mountproc_exportall_1_svc();
+extern int mountprog_1_freeresult ();
+#endif /* K&R C */
+#define MOUNTVERS_POSIX 2
+
+#if defined(__STDC__) || defined(__cplusplus)
+extern  void * mountproc_null_2(void *, CLIENT *);
+extern  void * mountproc_null_2_svc(void *, struct svc_req *);
+extern  fhstatus * mountproc_mnt_2(dirpath *, CLIENT *);
+extern  fhstatus * mountproc_mnt_2_svc(dirpath *, struct svc_req *);
+extern  mountlist * mountproc_dump_2(void *, CLIENT *);
+extern  mountlist * mountproc_dump_2_svc(void *, struct svc_req *);
+extern  void * mountproc_umnt_2(dirpath *, CLIENT *);
+extern  void * mountproc_umnt_2_svc(dirpath *, struct svc_req *);
+extern  void * mountproc_umntall_2(void *, CLIENT *);
+extern  void * mountproc_umntall_2_svc(void *, struct svc_req *);
+extern  exports * mountproc_export_2(void *, CLIENT *);
+extern  exports * mountproc_export_2_svc(void *, struct svc_req *);
+extern  exports * mountproc_exportall_2(void *, CLIENT *);
+extern  exports * mountproc_exportall_2_svc(void *, struct svc_req *);
+#define MOUNTPROC_PATHCONF 7
+extern  ppathcnf * mountproc_pathconf_2(dirpath *, CLIENT *);
+extern  ppathcnf * mountproc_pathconf_2_svc(dirpath *, struct svc_req *)=
;
+extern int mountprog_2_freeresult (SVCXPRT *, xdrproc_t, caddr_t);
+
+#else /* K&R C */
+extern  void * mountproc_null_2();
+extern  void * mountproc_null_2_svc();
+extern  fhstatus * mountproc_mnt_2();
+extern  fhstatus * mountproc_mnt_2_svc();
+extern  mountlist * mountproc_dump_2();
+extern  mountlist * mountproc_dump_2_svc();
+extern  void * mountproc_umnt_2();
+extern  void * mountproc_umnt_2_svc();
+extern  void * mountproc_umntall_2();
+extern  void * mountproc_umntall_2_svc();
+extern  exports * mountproc_export_2();
+extern  exports * mountproc_export_2_svc();
+extern  exports * mountproc_exportall_2();
+extern  exports * mountproc_exportall_2_svc();
+#define MOUNTPROC_PATHCONF 7
+extern  ppathcnf * mountproc_pathconf_2();
+extern  ppathcnf * mountproc_pathconf_2_svc();
+extern int mountprog_2_freeresult ();
+#endif /* K&R C */
+#define MOUNT_V3 3
+
+#if defined(__STDC__) || defined(__cplusplus)
+#define MOUNTPROC3_NULL 0
+extern  void * mountproc3_null_3(void *, CLIENT *);
+extern  void * mountproc3_null_3_svc(void *, struct svc_req *);
+#define MOUNTPROC3_MNT 1
+extern  mountres3 * mountproc3_mnt_3(dirpath *, CLIENT *);
+extern  mountres3 * mountproc3_mnt_3_svc(dirpath *, struct svc_req *);
+#define MOUNTPROC3_DUMP 2
+extern  mountlist * mountproc3_dump_3(void *, CLIENT *);
+extern  mountlist * mountproc3_dump_3_svc(void *, struct svc_req *);
+#define MOUNTPROC3_UMNT 3
+extern  void * mountproc3_umnt_3(dirpath *, CLIENT *);
+extern  void * mountproc3_umnt_3_svc(dirpath *, struct svc_req *);
+#define MOUNTPROC3_UMNTALL 4
+extern  void * mountproc3_umntall_3(void *, CLIENT *);
+extern  void * mountproc3_umntall_3_svc(void *, struct svc_req *);
+#define MOUNTPROC3_EXPORT 5
+extern  exports * mountproc3_export_3(void *, CLIENT *);
+extern  exports * mountproc3_export_3_svc(void *, struct svc_req *);
+extern int mountprog_3_freeresult (SVCXPRT *, xdrproc_t, caddr_t);
+
+#else /* K&R C */
+#define MOUNTPROC3_NULL 0
+extern  void * mountproc3_null_3();
+extern  void * mountproc3_null_3_svc();
+#define MOUNTPROC3_MNT 1
+extern  mountres3 * mountproc3_mnt_3();
+extern  mountres3 * mountproc3_mnt_3_svc();
+#define MOUNTPROC3_DUMP 2
+extern  mountlist * mountproc3_dump_3();
+extern  mountlist * mountproc3_dump_3_svc();
+#define MOUNTPROC3_UMNT 3
+extern  void * mountproc3_umnt_3();
+extern  void * mountproc3_umnt_3_svc();
+#define MOUNTPROC3_UMNTALL 4
+extern  void * mountproc3_umntall_3();
+extern  void * mountproc3_umntall_3_svc();
+#define MOUNTPROC3_EXPORT 5
+extern  exports * mountproc3_export_3();
+extern  exports * mountproc3_export_3_svc();
+extern int mountprog_3_freeresult ();
+#endif /* K&R C */
+
+/* the xdr functions */
+
+#if defined(__STDC__) || defined(__cplusplus)
+extern  bool_t xdr_fhandle (XDR *, fhandle);
+extern  bool_t xdr_fhandle3 (XDR *, fhandle3*);
+extern  bool_t xdr_mountstat3 (XDR *, mountstat3*);
+extern  bool_t xdr_fhstatus (XDR *, fhstatus*);
+extern  bool_t xdr_mountres3_ok (XDR *, mountres3_ok*);
+extern  bool_t xdr_mountres3 (XDR *, mountres3*);
+extern  bool_t xdr_dirpath (XDR *, dirpath*);
+extern  bool_t xdr_name (XDR *, name*);
+extern  bool_t xdr_mountlist (XDR *, mountlist*);
+extern  bool_t xdr_mountbody (XDR *, mountbody*);
+extern  bool_t xdr_groups (XDR *, groups*);
+extern  bool_t xdr_groupnode (XDR *, groupnode*);
+extern  bool_t xdr_exports (XDR *, exports*);
+extern  bool_t xdr_exportnode (XDR *, exportnode*);
+extern  bool_t xdr_ppathcnf (XDR *, ppathcnf*);
+
+#else /* K&R C */
+extern bool_t xdr_fhandle ();
+extern bool_t xdr_fhandle3 ();
+extern bool_t xdr_mountstat3 ();
+extern bool_t xdr_fhstatus ();
+extern bool_t xdr_mountres3_ok ();
+extern bool_t xdr_mountres3 ();
+extern bool_t xdr_dirpath ();
+extern bool_t xdr_name ();
+extern bool_t xdr_mountlist ();
+extern bool_t xdr_mountbody ();
+extern bool_t xdr_groups ();
+extern bool_t xdr_groupnode ();
+extern bool_t xdr_exports ();
+extern bool_t xdr_exportnode ();
+extern bool_t xdr_ppathcnf ();
+
+#endif /* K&R C */
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* !_NFSMOUNT_H_RPCGEN */
diff -uprN nfs-utils-1.0.8/utils/mount/nfsmount.x nfs-utils-1.0.8-ag/util=
s/mount/nfsmount.x
--- nfs-utils-1.0.8/utils/mount/nfsmount.x	1969-12-31 19:00:00.000000000 =
-0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfsmount.x	2006-06-08 11:22:22.1588160=
00 -0400
@@ -0,0 +1,336 @@
+%/*
+% * Sun RPC is a product of Sun Microsystems, Inc. and is provided for
+% * unrestricted use provided that this legend is included on all tape
+% * media and as a part of the software program in whole or part.  Users
+% * may copy or modify Sun RPC without charge, but are not authorized
+% * to license or distribute it to anyone else except as part of a produ=
ct or
+% * program developed by the user or with the express written consent of
+% * Sun Microsystems, Inc.
+% *
+% * SUN RPC IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING T=
HE
+% * WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
+% * PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTIC=
E.
+% *
+% * Sun RPC is provided with no support and without any obligation on th=
e
+% * part of Sun Microsystems, Inc. to assist in its use, correction,
+% * modification or enhancement.
+% *
+% * SUN MICROSYSTEMS, INC. SHALL HAVE NO LIABILITY WITH RESPECT TO THE
+% * INFRINGEMENT OF COPYRIGHTS, TRADE SECRETS OR ANY PATENTS BY SUN RPC
+% * OR ANY PART THEREOF.
+% *
+% * In no event will Sun Microsystems, Inc. be liable for any lost reven=
ue
+% * or profits or other special, indirect and consequential damages, eve=
n if
+% * Sun has been advised of the possibility of such damages.
+% *
+% * Sun Microsystems, Inc.
+% * 2550 Garcia Avenue
+% * Mountain View, California  94043
+% */
+
+%/*
+% * Copyright (c) 1985, 1990 by Sun Microsystems, Inc.
+% */
+%
+%/* from @(#)mount.x	1.3 91/03/11 TIRPC 1.0 */
+
+/*
+ * Protocol description for the mount program
+ */
+
+#ifdef RPC_HDR
+%#ifndef _rpcsvc_mount_h
+%#define _rpcsvc_mount_h
+#endif
+
+#ifdef RPC_CLNT
+%#include <string.h>		/* for memset() */
+#endif
+%#include <asm/types.h>
+
+const MNTPATHLEN =3D 1024;	/* maximum bytes in a pathname argument */
+const MNTNAMLEN =3D 255;		/* maximum bytes in a name argument */
+const FHSIZE =3D 32;		/* size in bytes of a file handle */
+const FHSIZE3 =3D 64;		/* size in bytes of a file handle */
+
+/*
+ * The fhandle is the file handle that the server passes to the client.
+ * All file operations are done using the file handles to refer to a fil=
e
+ * or a directory. The file handle can contain whatever information the
+ * server needs to distinguish an individual file.
+ */
+typedef opaque fhandle[FHSIZE];=09
+typedef opaque fhandle3<FHSIZE3>;
+
+enum mountstat3 {
+	MNT_OK			=3D 0,		/* no error */
+	MNT3ERR_PERM		=3D 1,		/* not owner */
+	MNT3ERR_NOENT		=3D 2,		/* No such file or directory */
+	MNT3ERR_IO		=3D 5,		/* I/O error */
+	MNT3ERR_ACCES		=3D 13,		/* Permission denied */
+	MNT3ERR_NOTDIR		=3D 20,		/* Not a directory */
+	MNT3ERR_INVAL		=3D 22,		/* Invalid argument */
+	MNT3ERR_NAMETOOLONG	=3D 63,		/* File name too long */
+	MNT3ERR_NOTSUPP		=3D 10004,	/* Operation not supported */
+	MNT3ERR_SERVERFAULT	=3D 10006		/* A failure on the server */
+};
+
+/*
+ * If a status of zero is returned, the call completed successfully, and=
=20
+ * a file handle for the directory follows. A non-zero status indicates
+ * some sort of error. The status corresponds with UNIX error numbers.
+ */
+union fhstatus switch (unsigned fhs_status) {
+case 0:
+	fhandle fhs_fhandle;
+default:
+	void;
+};
+
+struct mountres3_ok {
+	fhandle3 fhandle;
+	int auth_flavours<>;
+};
+
+union mountres3 switch (mountstat3 fhs_status) {
+case MNT_OK:
+	mountres3_ok mountinfo;
+default:
+	void;
+};
+
+/*
+ * The type dirpath is the pathname of a directory
+ */
+typedef string dirpath<MNTPATHLEN>;
+
+/*
+ * The type name is used for arbitrary names (hostnames, groupnames)
+ */
+typedef string name<MNTNAMLEN>;
+
+/*
+ * A list of who has what mounted
+ */
+typedef struct mountbody *mountlist;
+struct mountbody {
+	name ml_hostname;
+	dirpath ml_directory;
+	mountlist ml_next;
+};
+
+/*
+ * A list of netgroups
+ */
+typedef struct groupnode *groups;
+struct groupnode {
+	name gr_name;
+	groups gr_next;
+};
+
+/*
+ * A list of what is exported and to whom
+ */
+typedef struct exportnode *exports;
+struct exportnode {
+	dirpath ex_dir;
+	groups ex_groups;
+	exports ex_next;
+};
+
+/*
+ * POSIX pathconf information
+ */
+struct ppathcnf {
+	int	pc_link_max;	/* max links allowed */
+	short	pc_max_canon;	/* max line len for a tty */
+	short	pc_max_input;	/* input a tty can eat all at once */
+	short	pc_name_max;	/* max file name length (dir entry) */
+	short	pc_path_max;	/* max path name length (/x/y/x/.. ) */
+	short	pc_pipe_buf;	/* size of a pipe (bytes) */
+	u_char	pc_vdisable;	/* safe char to turn off c_cc[i] */
+	char	pc_xxx;		/* alignment padding; cc_t =3D=3D char */
+	short	pc_mask[2];	/* validity and boolean bits */
+};
+
+program MOUNTPROG {
+	/*
+	 * Version one of the mount protocol communicates with version two
+	 * of the NFS protocol. The only connecting point is the fhandle=20
+	 * structure, which is the same for both protocols.
+	 */
+	version MOUNTVERS {
+		/*
+		 * Does no work. It is made available in all RPC services
+		 * to allow server reponse testing and timing
+		 */
+		void
+		MOUNTPROC_NULL(void) =3D 0;
+
+		/*=09
+		 * If fhs_status is 0, then fhs_fhandle contains the
+	 	 * file handle for the directory. This file handle may
+		 * be used in the NFS protocol. This procedure also adds
+		 * a new entry to the mount list for this client mounting
+		 * the directory.
+		 * Unix authentication required.
+		 */
+		fhstatus=20
+		MOUNTPROC_MNT(dirpath) =3D 1;
+
+		/*
+		 * Returns the list of remotely mounted filesystems. The=20
+		 * mountlist contains one entry for each hostname and=20
+		 * directory pair.
+		 */
+		mountlist
+		MOUNTPROC_DUMP(void) =3D 2;
+
+		/*
+		 * Removes the mount list entry for the directory
+		 * Unix authentication required.
+		 */
+		void
+		MOUNTPROC_UMNT(dirpath) =3D 3;
+
+		/*
+		 * Removes all of the mount list entries for this client
+		 * Unix authentication required.
+		 */
+		void
+		MOUNTPROC_UMNTALL(void) =3D 4;
+
+		/*
+		 * Returns a list of all the exported filesystems, and which
+		 * machines are allowed to import it.
+		 */
+		exports
+		MOUNTPROC_EXPORT(void)  =3D 5;
+
+		/*
+		 * Identical to MOUNTPROC_EXPORT above
+		 */
+		exports
+		MOUNTPROC_EXPORTALL(void) =3D 6;
+	} =3D 1;
+
+	/*
+	 * Version two of the mount protocol communicates with version two
+	 * of the NFS protocol.
+	 * The only difference from version one is the addition of a POSIX
+	 * pathconf call.
+	 */
+	version MOUNTVERS_POSIX {
+		/*
+		 * Does no work. It is made available in all RPC services
+		 * to allow server reponse testing and timing
+		 */
+		void
+		MOUNTPROC_NULL(void) =3D 0;
+
+		/*=09
+		 * If fhs_status is 0, then fhs_fhandle contains the
+	 	 * file handle for the directory. This file handle may
+		 * be used in the NFS protocol. This procedure also adds
+		 * a new entry to the mount list for this client mounting
+		 * the directory.
+		 * Unix authentication required.
+		 */
+		fhstatus=20
+		MOUNTPROC_MNT(dirpath) =3D 1;
+
+		/*
+		 * Returns the list of remotely mounted filesystems. The=20
+		 * mountlist contains one entry for each hostname and=20
+		 * directory pair.
+		 */
+		mountlist
+		MOUNTPROC_DUMP(void) =3D 2;
+
+		/*
+		 * Removes the mount list entry for the directory
+		 * Unix authentication required.
+		 */
+		void
+		MOUNTPROC_UMNT(dirpath) =3D 3;
+
+		/*
+		 * Removes all of the mount list entries for this client
+		 * Unix authentication required.
+		 */
+		void
+		MOUNTPROC_UMNTALL(void) =3D 4;
+
+		/*
+		 * Returns a list of all the exported filesystems, and which
+		 * machines are allowed to import it.
+		 */
+		exports
+		MOUNTPROC_EXPORT(void)  =3D 5;
+
+		/*
+		 * Identical to MOUNTPROC_EXPORT above
+		 */
+		exports
+		MOUNTPROC_EXPORTALL(void) =3D 6;
+
+		/*
+		 * POSIX pathconf info (Sun hack)
+		 */
+		ppathcnf
+		MOUNTPROC_PATHCONF(dirpath) =3D 7;
+	} =3D 2;
+	version MOUNT_V3 {
+		/*
+		 * Does no work. It is made available in all RPC services
+		 * to allow server reponse testing and timing
+		 */
+		void
+		MOUNTPROC3_NULL(void) =3D 0;
+
+		/*=09
+		 * If fhs_status is 0, then fhs_fhandle contains the
+	 	 * file handle for the directory. This file handle may
+		 * be used in the NFS protocol. This procedure also adds
+		 * a new entry to the mount list for this client mounting
+		 * the directory.
+		 * Unix authentication required.
+		 */
+		mountres3
+		MOUNTPROC3_MNT(dirpath) =3D 1;
+
+		/*
+		 * Returns the list of remotely mounted filesystems. The=20
+		 * mountlist contains one entry for each hostname and=20
+		 * directory pair.
+		 */
+		mountlist
+		MOUNTPROC3_DUMP(void) =3D 2;
+
+		/*
+		 * Removes the mount list entry for the directory
+		 * Unix authentication required.
+		 */
+		void
+		MOUNTPROC3_UMNT(dirpath) =3D 3;
+
+		/*
+		 * Removes all of the mount list entries for this client
+		 * Unix authentication required.
+		 */
+		void
+		MOUNTPROC3_UMNTALL(void) =3D 4;
+
+		/*
+		 * Returns a list of all the exported filesystems, and which
+		 * machines are allowed to import it.
+		 */
+		exports
+		MOUNTPROC3_EXPORT(void)  =3D 5;
+
+	} =3D 3;
+} =3D 100005;
+
+#ifdef RPC_HDR
+%#endif /*!_rpcsvc_mount_h*/
+#endif
diff -uprN nfs-utils-1.0.8/utils/mount/nfsmount_xdr.c nfs-utils-1.0.8-ag/=
utils/mount/nfsmount_xdr.c
--- nfs-utils-1.0.8/utils/mount/nfsmount_xdr.c	1969-12-31 19:00:00.000000=
000 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfsmount_xdr.c	2006-06-08 11:22:22.165=
815000 -0400
@@ -0,0 +1,329 @@
+/*
+ * Please do not edit this file.
+ * It was generated using rpcgen.
+ */
+
+#include "nfsmount.h"
+/*
+ * Sun RPC is a product of Sun Microsystems, Inc. and is provided for
+ * unrestricted use provided that this legend is included on all tape
+ * media and as a part of the software program in whole or part.  Users
+ * may copy or modify Sun RPC without charge, but are not authorized
+ * to license or distribute it to anyone else except as part of a produc=
t or
+ * program developed by the user or with the express written consent of
+ * Sun Microsystems, Inc.
+ *
+ * SUN RPC IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING TH=
E
+ * WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
+ *
+ * Sun RPC is provided with no support and without any obligation on the
+ * part of Sun Microsystems, Inc. to assist in its use, correction,
+ * modification or enhancement.
+ *
+ * SUN MICROSYSTEMS, INC. SHALL HAVE NO LIABILITY WITH RESPECT TO THE
+ * INFRINGEMENT OF COPYRIGHTS, TRADE SECRETS OR ANY PATENTS BY SUN RPC
+ * OR ANY PART THEREOF.
+ *
+ * In no event will Sun Microsystems, Inc. be liable for any lost revenu=
e
+ * or profits or other special, indirect and consequential damages, even=
 if
+ * Sun has been advised of the possibility of such damages.
+ *
+ * Sun Microsystems, Inc.
+ * 2550 Garcia Avenue
+ * Mountain View, California  94043
+ */
+/*
+ * Copyright (c) 1985, 1990 by Sun Microsystems, Inc.
+ */
+
+/* from @(#)mount.x	1.3 91/03/11 TIRPC 1.0 */
+#include <asm/types.h>
+
+bool_t
+xdr_fhandle (XDR *xdrs, fhandle objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_opaque (xdrs, objp, FHSIZE))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_fhandle3 (XDR *xdrs, fhandle3 *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_bytes (xdrs, (char **)&objp->fhandle3_val, (u_int *) &objp->f=
handle3_len, FHSIZE3))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_mountstat3 (XDR *xdrs, mountstat3 *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_enum (xdrs, (enum_t *) objp))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_fhstatus (XDR *xdrs, fhstatus *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_u_int (xdrs, &objp->fhs_status))
+		 return FALSE;
+	switch (objp->fhs_status) {
+	case 0:
+		 if (!xdr_fhandle (xdrs, objp->fhstatus_u.fhs_fhandle))
+			 return FALSE;
+		break;
+	default:
+		break;
+	}
+	return TRUE;
+}
+
+bool_t
+xdr_mountres3_ok (XDR *xdrs, mountres3_ok *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_fhandle3 (xdrs, &objp->fhandle))
+		 return FALSE;
+	 if (!xdr_array (xdrs, (char **)&objp->auth_flavours.auth_flavours_val,=
 (u_int *) &objp->auth_flavours.auth_flavours_len, ~0,
+		sizeof (int), (xdrproc_t) xdr_int))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_mountres3 (XDR *xdrs, mountres3 *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_mountstat3 (xdrs, &objp->fhs_status))
+		 return FALSE;
+	switch (objp->fhs_status) {
+	case MNT_OK:
+		 if (!xdr_mountres3_ok (xdrs, &objp->mountres3_u.mountinfo))
+			 return FALSE;
+		break;
+	default:
+		break;
+	}
+	return TRUE;
+}
+
+bool_t
+xdr_dirpath (XDR *xdrs, dirpath *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_string (xdrs, objp, MNTPATHLEN))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_name (XDR *xdrs, name *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_string (xdrs, objp, MNTNAMLEN))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_mountlist (XDR *xdrs, mountlist *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_pointer (xdrs, (char **)objp, sizeof (struct mountbody), (xdr=
proc_t) xdr_mountbody))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_mountbody (XDR *xdrs, mountbody *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_name (xdrs, &objp->ml_hostname))
+		 return FALSE;
+	 if (!xdr_dirpath (xdrs, &objp->ml_directory))
+		 return FALSE;
+	 if (!xdr_mountlist (xdrs, &objp->ml_next))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_groups (XDR *xdrs, groups *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_pointer (xdrs, (char **)objp, sizeof (struct groupnode), (xdr=
proc_t) xdr_groupnode))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_groupnode (XDR *xdrs, groupnode *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_name (xdrs, &objp->gr_name))
+		 return FALSE;
+	 if (!xdr_groups (xdrs, &objp->gr_next))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_exports (XDR *xdrs, exports *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_pointer (xdrs, (char **)objp, sizeof (struct exportnode), (xd=
rproc_t) xdr_exportnode))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_exportnode (XDR *xdrs, exportnode *objp)
+{
+	register int32_t *buf;
+
+	 if (!xdr_dirpath (xdrs, &objp->ex_dir))
+		 return FALSE;
+	 if (!xdr_groups (xdrs, &objp->ex_groups))
+		 return FALSE;
+	 if (!xdr_exports (xdrs, &objp->ex_next))
+		 return FALSE;
+	return TRUE;
+}
+
+bool_t
+xdr_ppathcnf (XDR *xdrs, ppathcnf *objp)
+{
+	register int32_t *buf;
+
+	int i;
+
+	if (xdrs->x_op =3D=3D XDR_ENCODE) {
+		buf =3D XDR_INLINE (xdrs, 6 * BYTES_PER_XDR_UNIT);
+		if (buf =3D=3D NULL) {
+			 if (!xdr_int (xdrs, &objp->pc_link_max))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_max_canon))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_max_input))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_name_max))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_path_max))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_pipe_buf))
+				 return FALSE;
+
+		} else {
+		IXDR_PUT_LONG(buf, objp->pc_link_max);
+		IXDR_PUT_SHORT(buf, objp->pc_max_canon);
+		IXDR_PUT_SHORT(buf, objp->pc_max_input);
+		IXDR_PUT_SHORT(buf, objp->pc_name_max);
+		IXDR_PUT_SHORT(buf, objp->pc_path_max);
+		IXDR_PUT_SHORT(buf, objp->pc_pipe_buf);
+		}
+		 if (!xdr_u_char (xdrs, &objp->pc_vdisable))
+			 return FALSE;
+		 if (!xdr_char (xdrs, &objp->pc_xxx))
+			 return FALSE;
+		buf =3D XDR_INLINE (xdrs, ( 2 ) * BYTES_PER_XDR_UNIT);
+		if (buf =3D=3D NULL) {
+			 if (!xdr_vector (xdrs, (char *)objp->pc_mask, 2,
+				sizeof (short), (xdrproc_t) xdr_short))
+				 return FALSE;
+		} else {
+			{
+				register short *genp;
+
+				for (i =3D 0, genp =3D objp->pc_mask;
+					i < 2; ++i) {
+					IXDR_PUT_SHORT(buf, *genp++);
+				}
+			}
+		}
+		return TRUE;
+	} else if (xdrs->x_op =3D=3D XDR_DECODE) {
+		buf =3D XDR_INLINE (xdrs, 6 * BYTES_PER_XDR_UNIT);
+		if (buf =3D=3D NULL) {
+			 if (!xdr_int (xdrs, &objp->pc_link_max))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_max_canon))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_max_input))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_name_max))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_path_max))
+				 return FALSE;
+			 if (!xdr_short (xdrs, &objp->pc_pipe_buf))
+				 return FALSE;
+
+		} else {
+		objp->pc_link_max =3D IXDR_GET_LONG(buf);
+		objp->pc_max_canon =3D IXDR_GET_SHORT(buf);
+		objp->pc_max_input =3D IXDR_GET_SHORT(buf);
+		objp->pc_name_max =3D IXDR_GET_SHORT(buf);
+		objp->pc_path_max =3D IXDR_GET_SHORT(buf);
+		objp->pc_pipe_buf =3D IXDR_GET_SHORT(buf);
+		}
+		 if (!xdr_u_char (xdrs, &objp->pc_vdisable))
+			 return FALSE;
+		 if (!xdr_char (xdrs, &objp->pc_xxx))
+			 return FALSE;
+		buf =3D XDR_INLINE (xdrs, ( 2 ) * BYTES_PER_XDR_UNIT);
+		if (buf =3D=3D NULL) {
+			 if (!xdr_vector (xdrs, (char *)objp->pc_mask, 2,
+				sizeof (short), (xdrproc_t) xdr_short))
+				 return FALSE;
+		} else {
+			{
+				register short *genp;
+
+				for (i =3D 0, genp =3D objp->pc_mask;
+					i < 2; ++i) {
+					*genp++ =3D IXDR_GET_SHORT(buf);
+				}
+			}
+		}
+	 return TRUE;
+	}
+
+	 if (!xdr_int (xdrs, &objp->pc_link_max))
+		 return FALSE;
+	 if (!xdr_short (xdrs, &objp->pc_max_canon))
+		 return FALSE;
+	 if (!xdr_short (xdrs, &objp->pc_max_input))
+		 return FALSE;
+	 if (!xdr_short (xdrs, &objp->pc_name_max))
+		 return FALSE;
+	 if (!xdr_short (xdrs, &objp->pc_path_max))
+		 return FALSE;
+	 if (!xdr_short (xdrs, &objp->pc_pipe_buf))
+		 return FALSE;
+	 if (!xdr_u_char (xdrs, &objp->pc_vdisable))
+		 return FALSE;
+	 if (!xdr_char (xdrs, &objp->pc_xxx))
+		 return FALSE;
+	 if (!xdr_vector (xdrs, (char *)objp->pc_mask, 2,
+		sizeof (short), (xdrproc_t) xdr_short))
+		 return FALSE;
+	return TRUE;
+}
diff -uprN nfs-utils-1.0.8/utils/mount/nfsumount.c nfs-utils-1.0.8-ag/uti=
ls/mount/nfsumount.c
--- nfs-utils-1.0.8/utils/mount/nfsumount.c	1969-12-31 19:00:00.000000000=
 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/nfsumount.c	2006-06-08 11:22:22.171816=
000 -0400
@@ -0,0 +1,386 @@
+/*
+ * nfsumount.c -- Linux NFS umount
+ * Copyright (C) 2006 Amit Gud <gud@eth.net>
+ *
+ * - Basic code and wrapper around NFS umount code originally
+ *   in util-linux/mount/nfsmount.c
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#include <stdio.h>
+#include <errno.h>
+#include <getopt.h>
+#include <mntent.h>
+#include <ctype.h>
+#include <sys/mount.h>
+
+#include "xcommon.h"
+#include "nfsmount.h"
+#include "mount_constants.h"
+#include "fstab.h"
+#include "nls.h"
+#include "conn.h"
+
+#if !defined(MNT_FORCE)
+/* dare not try to include <linux/mount.h> -- lots of errors */
+#define MNT_FORCE 1
+#endif
+
+#if !defined(MNT_DETACH)
+#define MNT_DETACH 2
+#endif
+
+extern char *progname;
+extern int nfs_mount_version;
+extern int nomtab;
+extern int verbose;
+int force;
+int lazy;
+int remount;
+
+extern int find_kernel_nfs_mount_version(void);
+extern int probe_mntport(clnt_addr_t *);
+extern int nfs_gethostbyname(const char *, struct sockaddr_in *);
+
+static inline enum clnt_stat
+nfs3_umount(dirpath *argp, CLIENT *clnt)
+{
+	static char clnt_res;
+	memset (&clnt_res, 0, sizeof(clnt_res));
+	return clnt_call(clnt, MOUNTPROC_UMNT,
+			 (xdrproc_t) xdr_dirpath, (caddr_t)argp,
+			 (xdrproc_t) xdr_void, (caddr_t) &clnt_res,
+			 TIMEOUT);
+}
+
+static inline enum clnt_stat
+nfs2_umount(dirpath *argp, CLIENT *clnt)
+{
+	static char clnt_res;
+	memset (&clnt_res, 0, sizeof(clnt_res));
+	return clnt_call(clnt, MOUNTPROC_UMNT,
+			 (xdrproc_t) xdr_dirpath, (caddr_t)argp,
+			 (xdrproc_t) xdr_void, (caddr_t) &clnt_res,
+			 TIMEOUT);
+}
+
+int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
+{
+	CLIENT *clnt;
+	enum clnt_stat res =3D 0;
+	int msock;
+
+	clnt =3D mnt_openclnt(mnt_server, &msock);
+	if (!clnt)
+		goto out_bad;
+	switch (mnt_server->pmap.pm_vers) {
+	case 3:
+		res =3D nfs3_umount(argp, clnt);
+		break;
+	case 2:
+	case 1:
+		res =3D nfs2_umount(argp, clnt);
+		break;
+	default:
+		break;
+	}
+	mnt_closeclnt(clnt, msock);
+	if (res =3D=3D RPC_SUCCESS)
+		return 1;
+ out_bad:
+	return 0;
+}
+
+u_int get_mntproto(const char *);
+u_int
+get_mntproto(const char *dirname)
+{
+	FILE *mtab;
+	struct mntent mntbuf;
+	char tmpbuf[BUFSIZ];
+	u_int proto =3D IPPROTO_TCP; /* assume tcp */
+
+	 mtab =3D setmntent ("/proc/mounts", "r");
+	 if (mtab =3D=3D NULL)
+	 	mtab =3D setmntent (_PATH_MOUNTED, "r");
+	if (mtab =3D=3D NULL)
+		return proto;
+
+	while(getmntent_r(mtab, &mntbuf, tmpbuf, sizeof (tmpbuf))) {
+		if (strcmp(mntbuf.mnt_type, "nfs"))
+			continue;
+		if (strcmp(dirname,  mntbuf.mnt_fsname))
+			continue;
+		if (hasmntopt(&mntbuf, "udp"))
+			proto =3D IPPROTO_UDP;
+		break;
+	}
+	endmntent (mtab);
+
+	return proto;
+}
+
+/* complain about a failed umount */
+static void complain(int err, const char *dev) {
+  switch (err) {
+    case ENXIO:
+      nfs_error (_("umount: %s: invalid block device"), dev); break;
+    case EINVAL:
+      nfs_error (_("umount: %s: not mounted"), dev); break;
+    case EIO:
+      nfs_error (_("umount: %s: can't write superblock"), dev); break;
+    case EBUSY:
+     /* Let us hope fstab has a line "proc /proc ..."
+        and not "none /proc ..."*/
+      nfs_error (_("umount: %s: device is busy"), dev); break;
+    case ENOENT:
+      nfs_error (_("umount: %s: not found"), dev); break;
+    case EPERM:
+      nfs_error (_("umount: %s: must be superuser to umount"), dev); bre=
ak;
+    case EACCES:
+      nfs_error (_("umount: %s: block devices not permitted on fs"), dev=
); break;
+    default:
+      nfs_error (_("umount: %s: %s"), dev, strerror (err)); break;
+  }
+}
+
+int add_mtab2(const char *spec, const char *node, const char *type,
+		const char *opts, struct mntentchn *mc)
+{
+	int umnt_err, umnt_err2, res;
+
+        umnt_err =3D umnt_err2 =3D 0;
+        if (lazy) {
+                res =3D umount2 (node, MNT_DETACH);
+                if (res < 0)
+                        umnt_err =3D errno;
+                goto writemtab;
+        }
+
+        if (force) {
+                res =3D umount2 (node, MNT_FORCE);
+                if (res =3D=3D -1) {
+                        int errsv =3D errno;
+                        perror("umount2");
+                        errno =3D errsv;
+                        if (errno =3D=3D ENOSYS) {
+                                if (verbose)
+                                        printf(_("no umount2, trying umo=
unt...\n"));
+                                res =3D umount (node);
+                        }
+                }
+        } else
+                res =3D umount (node);
+
+        if (res < 0) {
+                umnt_err =3D errno;
+                /* A device might have been mounted on a node that has s=
ince
+                   been deleted or renamed, so if node fails, also try s=
pec. */
+                /* Note that this is incorrect in case spec was mounted
+                   several times. */
+                /* if (umnt_err =3D=3D ENOENT || umnt_err =3D=3D EINVAL)=
 */
+                if (umnt_err !=3D EBUSY && strcmp(node, spec)) {
+                        if (verbose)
+                                printf (_("could not umount %s - trying =
%s instead\n"),
+                                        node, spec);
+                        res =3D umount (spec);
+                        if (res < 0)
+                                umnt_err2 =3D errno;
+                       /* Do not complain about remote NFS mount points =
*/
+                        if (errno =3D=3D ENOENT && index(spec, ':'))
+                                umnt_err2 =3D 0;
+                }
+        }
+
+        if (res < 0 && remount && (umnt_err =3D=3D EBUSY || umnt_err2 =3D=
=3D EBUSY)) {
+                /* Umount failed - let us try a remount */
+                res =3D mount(spec, node, NULL,
+                            MS_MGC_VAL | MS_REMOUNT | MS_RDONLY, NULL);
+                if (res =3D=3D 0) {
+                        nfs_mntent_t remnt;
+                        fprintf(stderr,
+                                _("umount: %s busy - remounted read-only=
\n"),
+                                spec);
+                        remnt.mnt_type =3D remnt.mnt_fsname =3D NULL;
+                        remnt.mnt_dir =3D xstrdup(node);
+                        remnt.mnt_opts =3D xstrdup("ro");
+                        if (!nomtab)
+                                update_mtab(node, &remnt);
+                        return 0;
+                } else if (errno !=3D EBUSY) {    /* hmm ... */
+                        perror("remount");
+                        fprintf(stderr,
+                                _("umount: could not remount %s read-onl=
y\n"),
+                                spec);
+                }
+        }
+
+        if (res >=3D 0) {
+                /* Umount succeeded */
+                if (verbose)
+                        printf (_("%s umounted\n"), spec);
+        }
+
+ writemtab:
+        if (!nomtab &&
+            (umnt_err =3D=3D 0 || umnt_err =3D=3D EINVAL || umnt_err =3D=
=3D ENOENT)) {
+               update_mtab (node, NULL);
+        }
+
+        if (res >=3D 0)
+                return 0;
+
+        if (umnt_err2)
+                complain(umnt_err2, spec);
+        if (umnt_err && umnt_err !=3D umnt_err2)
+                complain(umnt_err, node);
+        return 1;
+}
+
+int _nfsumount(const char *spec, const char *opts)
+{
+	char *hostname;
+	char *dirname;
+	clnt_addr_t mnt_server =3D { &hostname, };
+	struct pmap *pmap =3D &mnt_server.pmap;
+	char *p;
+
+	nfs_mount_version =3D find_kernel_nfs_mount_version();
+	if (spec =3D=3D NULL || (p =3D strchr(spec,':')) =3D=3D NULL)
+		goto out_bad;
+	hostname =3D xstrndup(spec, p-spec);
+	dirname =3D xstrdup(p+1);
+#ifdef NFS_MOUNT_DEBUG
+	printf(_("host: %s, directory: %s\n"), hostname, dirname);
+#endif
+
+	if (opts && (p =3D strstr(opts, "addr=3D"))) {
+		char *q;
+
+		free(hostname);
+		p +=3D 5;
+		q =3D p;
+		while (*q && *q !=3D ',') q++;
+		hostname =3D xstrndup(p,q-p);
+	}
+
+	if (opts && (p =3D strstr(opts, "mounthost=3D"))) {
+		char *q;
+
+		free(hostname);
+		p +=3D 10;
+		q =3D p;
+		while (*q && *q !=3D ',') q++;
+		hostname =3D xstrndup(p,q-p);
+	}
+
+	pmap->pm_prog =3D MOUNTPROG;
+	pmap->pm_vers =3D MOUNTVERS;
+	pmap->pm_prot =3D get_mntproto(spec);
+	if (opts && (p =3D strstr(opts, "mountprog=3D")) && isdigit(*(p+10)))
+		pmap->pm_prog =3D atoi(p+10);
+	if (opts && (p =3D strstr(opts, "mountport=3D")) && isdigit(*(p+10)))
+		pmap->pm_port =3D atoi(p+10);
+	if (opts && (p =3D strstr(opts, "nfsvers=3D")) && isdigit(*(p+8)))
+		pmap->pm_vers =3D nfsvers_to_mnt(atoi(p+8));
+	if (opts && (p =3D strstr(opts, "mountvers=3D")) && isdigit(*(p+10)))
+		pmap->pm_vers =3D atoi(p+10);
+
+	if (!nfs_gethostbyname(hostname, &mnt_server.saddr))
+		goto out_bad;
+	if (!probe_mntport(&mnt_server))
+		goto out_bad;
+	return nfs_call_umount(&mnt_server, &dirname);
+ out_bad:
+	return 0;
+}
+
+static struct option umount_longopts[] =3D
+{
+  { "force", 0, 0, 'f' },
+  { "help", 0, 0, 'h' },
+  { "no-mtab", 0, 0, 'n' },
+  { "verbose", 0, 0, 'v' },
+  { "read-only", 0, 0, 'r' },
+  { NULL, 0, 0, 0 }
+};
+
+void umount_usage()
+{
+	printf("usage: %s dir [-fvnrlh]\n", progname);
+	printf("options:\n\t-f\t\tforce unmount\n");
+	printf("\t-v\t\tverbose\n");
+	printf("\t-n\t\tno mtab updation\n");
+	printf("\t-r\t\tremount\n");
+	printf("\t-l\t\tlazy unmount\n");
+	printf("\t-h\t\tprint this help\n\n");
+}
+
+int nfsumount(int argc, char *argv[])
+{
+	int c, ret;
+	char *spec;
+	struct mntentchn *mc;
+
+	spec =3D canonicalize(argv[1]);
+
+	argv +=3D 1;
+	argc -=3D 1;
+
+	while ((c =3D getopt_long (argc, argv, "fvnrlh",
+				umount_longopts, NULL)) !=3D -1) {
+
+		switch (c) {
+		case 'f':
+			++force;
+			break;
+		case 'v':
+			++verbose;
+			break;
+		case 'n':
+			++nomtab;
+			break;
+		case 'r':
+			++remount;
+			break;
+		case 'l':
+			++lazy;
+			break;
+		case 'h':
+		default:
+			umount_usage();
+			break;
+		}
+	}
+
+	mc =3D getmntdirbackward(spec, NULL);
+	if (!mc)
+		mc =3D getmntdevbackward(spec, NULL);
+	if (!mc && verbose)
+	printf(_("Could not find %s in mtab\n"), spec);
+
+	if(mc) {
+		ret =3D _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
+		if(ret)
+			ret =3D add_mtab2(mc->m.mnt_fsname, mc->m.mnt_dir,
+				mc->m.mnt_type, mc->m.mnt_opts, mc);
+	}
+	else {
+		ret =3D _nfsumount(spec, NULL);
+		if(ret)
+			ret =3D add_mtab2(spec, spec, spec, spec, NULL);
+	}
+
+	return(ret);
+}
+
diff -uprN nfs-utils-1.0.8/utils/mount/umount.nfs.man nfs-utils-1.0.8-ag/=
utils/mount/umount.nfs.man
--- nfs-utils-1.0.8/utils/mount/umount.nfs.man	1969-12-31 19:00:00.000000=
000 -0500
+++ nfs-utils-1.0.8-ag/utils/mount/umount.nfs.man	2006-06-08 11:22:22.177=
815000 -0400
@@ -0,0 +1,76 @@
+.\"@(#)mount.nfs.8"
+.TH UMOUNT.NFS 8 "6 Jun 2006"
+.SH NAME
+umount.nfs, umount.nfs4 \- unmount a Network File System
+.SH SYNOPSIS
+.BI "umount.nfs" " dir" " [\-fvnrlh ]"
+.SH DESCRIPTION
+.BR umount.nfs
+and
+.BR umount.nfs4
+are a part of=20
+.BR nfs (5)
+utilities package, which provides NFS client functionality.
+
+.BR umount.nfs4=20
+and
+.BR umount.nfs
+are meant to be used by the
+.BR umount (8)
+command for unmounting NFS shares. This subcommand, however, can also be=
 used as a standalone command with limited functionality.
+
+.BR umount.nfs4=20
+is used for mounting NFSv4 file system, while=20
+.BR umount.nfs=20
+is used to mount NFS file systems with older versions.
+.I dir=20
+is the directory on which the file system is mounted.
+
+.SH OPTIONS
+.TP
+.BI "\-f"
+Force unmount the file system in case of unreachable NFS system.
+.TP
+.BI "\-v"
+Be verbose.
+.TP
+.BI "\-n"
+Make no updation to mtab. By default, an entry is created in=20
+.I /etc/mtab=20
+for every mounted file system. Use this option to skip deleting an entry.
+.TP
+.BI "\-r"
+In case unmounting fails, try to mount read-only.
+.TP
+.BI "\-l"
+Lazy unmount. Detach the file system from the file system hierarchy now,=
 and cleanup all references to the file system as soon as it is not busy =
anymore.
+.TP
+.BI "\-h"
+Print help message.
+
+.SH NOTE
+For further information please refer=20
+.BR nfs (5)
+and
+.BR umount (8)
+manual pages.
+
+.SH FILES
+.TP 18n
+.I /etc/fstab
+file system table
+.TP
+.I /etc/mtab
+table of mounted file systems
+
+.PD
+.SH "SEE ALSO"
+.BR nfs (5),
+.BR umount (8),
+
+.SH BUGS
+Please notify current developers of NFS of any bugs in the current softw=
are or mail nfs@lists.sourceforge.net
+
+.SH "AUTHOR"
+Amit Gud <agud@redhat.com>
+
--- nfs-utils-1.0.8/configure.in	2006-04-11 22:55:51.000000000 -0400
+++ nfs-utils-1.0.8-ag/configure.in	2006-06-08 11:22:22.181815000 -0400
@@ -313,6 +313,7 @@ AC_CONFIG_FILES([
 	utils/gssd/Makefile
 	utils/idmapd/Makefile
 	utils/lockd/Makefile
+	utils/mount/Makefile
 	utils/mountd/Makefile
 	utils/nfsd/Makefile
 	utils/nfsstat/Makefile

--------------010301040808030501080808
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--------------010301040808030501080808
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010301040808030501080808--
