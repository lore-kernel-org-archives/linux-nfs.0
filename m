From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/23] libnfs.a: eliminate another dependency on a
	global	variable
Date: Sat, 28 Jul 2007 17:51:00 -0400
Message-ID: <20070728215100.21871.86204.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0534123890=="
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOv-0003k8-7U
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:10 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOw-0005ie-0W
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:11 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0534123890==
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

The file support/nfs/fstab.c, which is linked into libnfs.a, depends on t=
he
global variable "verbose."  This variable is defined and used only in the
mount command, and the functions in fstab.c are used only by the mount
command.

Move fstab.c and support/include/fstab.h to utils/mount.  This file
placement is also consistent with at least one other mount helper,
mount.ocfs2.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/Makefile.am |    1=20
 support/include/fstab.h     |   30 --
 support/nfs/Makefile.am     |    2=20
 support/nfs/fstab.c         |  554 -------------------------------------=
------
 utils/mount/Makefile.am     |    4=20
 utils/mount/fstab.c         |  554 +++++++++++++++++++++++++++++++++++++=
++++++
 utils/mount/fstab.h         |   30 ++
 7 files changed, 587 insertions(+), 588 deletions(-)

diff --git a/support/include/Makefile.am b/support/include/Makefile.am
index 69c4503..718abda 100644
--- a/support/include/Makefile.am
+++ b/support/include/Makefile.am
@@ -4,7 +4,6 @@ SUBDIRS =3D nfs rpcsvc sys
=20
 noinst_HEADERS =3D \
 	exportfs.h \
-	fstab.h \
 	ha-callout.h \
 	misc.h \
 	nfs_mntent.h \
diff --git a/support/include/fstab.h b/support/include/fstab.h
deleted file mode 100644
index 64c8355..0000000
--- a/support/include/fstab.h
+++ /dev/null
@@ -1,30 +0,0 @@
-#ifndef _NFS_FSTAB_H
-#define _NFS_FSTAB_H
-
-#include "nfs_mntent.h"
-
-#ifndef _PATH_FSTAB
-#define _PATH_FSTAB "/etc/fstab"
-#endif
-
-int mtab_is_writable(void);
-int mtab_does_not_exist(void);
-
-struct mntentchn {
-	struct mntentchn *nxt, *prev;
-	struct mntent m;
-};
-
-struct mntentchn *getmntoptfile (const char *file);
-struct mntentchn *getmntdirbackward (const char *dir, struct mntentchn *=
mc);
-struct mntentchn *getmntdevbackward (const char *dev, struct mntentchn *=
mc);
-
-struct mntentchn *getfsfile (const char *file);
-struct mntentchn *getfsspec (const char *spec);
-
-void lock_mtab (void);
-void unlock_mtab (void);
-void update_mtab (const char *special, struct mntent *with);
-
-#endif /* _NFS_FSTAB_H */
-
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index 82353a9..87f3949 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -4,7 +4,7 @@ noinst_LIBRARIES =3D libnfs.a
 libnfs_a_SOURCES =3D exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xlog.c xcommon.c wildmat.c nfssvc.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c \
-		   svc_socket.c cacheio.c closeall.c fstab.c nfs_mntent.c
+		   svc_socket.c cacheio.c closeall.c nfs_mntent.c
=20
 MAINTAINERCLEANFILES =3D Makefile.in
=20
diff --git a/support/nfs/fstab.c b/support/nfs/fstab.c
deleted file mode 100644
index aee8e53..0000000
--- a/support/nfs/fstab.c
+++ /dev/null
@@ -1,554 +0,0 @@
-/* 1999-02-22 Arkadiusz Mi=B6kiewicz <misiek@pld.ORG.PL>
- * - added Native Language Support
- * Sun Mar 21 1999 - Arnaldo Carvalho de Melo <acme@conectiva.com.br>
- * - fixed strerr(errno) in gettext calls
- *
- * 2006-06-08 Amit Gud <agud@redhat.com>
- * - Moved code to nfs-utils/support/nfs from util-linux/mount.
- */
-
-#include <errno.h>
-#include <stdio.h>
-#include <fcntl.h>
-#include <unistd.h>
-#include <string.h>
-#include <sys/stat.h>
-#include <mntent.h>
-
-#include "fstab.h"
-#include "xcommon.h"
-#include "nfs_mntent.h"
-#include "nfs_paths.h"
-#include "nls.h"
-
-#define LOCK_TIMEOUT	10
-#define streq(s, t)	(strcmp ((s), (t)) =3D=3D 0)
-#define PROC_MOUNTS		"/proc/mounts"
-
-extern int verbose;
-
-/* Information about mtab. ------------------------------------*/
-static int have_mtab_info =3D 0;
-static int var_mtab_does_not_exist =3D 0;
-static int var_mtab_is_a_symlink =3D 0;
-
-static void
-get_mtab_info(void) {
-	struct stat mtab_stat;
-
-	if (!have_mtab_info) {
-		if (lstat(MOUNTED, &mtab_stat))
-			var_mtab_does_not_exist =3D 1;
-		else if (S_ISLNK(mtab_stat.st_mode))
-			var_mtab_is_a_symlink =3D 1;
-		have_mtab_info =3D 1;
-	}
-}
-
-int
-mtab_does_not_exist(void) {
-	get_mtab_info();
-	return var_mtab_does_not_exist;
-}
-
-static int
-mtab_is_a_symlink(void) {
-        get_mtab_info();
-        return var_mtab_is_a_symlink;
-}
-
-int
-mtab_is_writable() {
-	int fd;
-
-	/* Should we write to /etc/mtab upon an update?
-	   Probably not if it is a symlink to /proc/mounts, since that
-	   would create a file /proc/mounts in case the proc filesystem
-	   is not mounted. */
-	if (mtab_is_a_symlink())
-		return 0;
-
-	fd =3D open(MOUNTED, O_RDWR | O_CREAT, 0644);
-	if (fd >=3D 0) {
-		close(fd);
-		return 1;
-	} else
-		return 0;
-}
-
-/* Contents of mtab and fstab ---------------------------------*/
-
-struct mntentchn mounttable;
-static int got_mtab =3D 0;
-struct mntentchn fstab;
-static int got_fstab =3D 0;
-
-static void read_mounttable(void);
-static void read_fstab(void);
-
-static struct mntentchn *
-mtab_head() {
-	if (!got_mtab)
-		read_mounttable();
-	return &mounttable;
-}
-
-static struct mntentchn *
-fstab_head()
-{
-	if (!got_fstab)
-		read_fstab();
-	return &fstab;
-}
-
-#if 0
-static void
-my_free(const void *s) {
-	if (s)
-		free((void *) s);
-}
-
-static void
-discard_mntentchn(struct mntentchn *mc0) {
-	struct mntentchn *mc, *mc1;
-
-	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc1) {
-		mc1 =3D mc->nxt;
-		my_free(mc->m.mnt_fsname);
-		my_free(mc->m.mnt_dir);
-		my_free(mc->m.mnt_type);
-		my_free(mc->m.mnt_opts);
-		free(mc);
-	}
-}
-#endif
-
-static void
-read_mntentchn(mntFILE *mfp, const char *fnam, struct mntentchn *mc0) {
-	struct mntentchn *mc =3D mc0;
-	struct mntent *mnt;
-
-	while ((mnt =3D nfs_getmntent(mfp)) !=3D NULL) {
-		if (!streq(mnt->mnt_type, MNTTYPE_IGNORE)) {
-			mc->nxt =3D (struct mntentchn *) xmalloc(sizeof(*mc));
-			mc->nxt->prev =3D mc;
-			mc =3D mc->nxt;
-			mc->m =3D *mnt;
-			mc->nxt =3D mc0;
-		}
-	}
-	mc0->prev =3D mc;
-	if (ferror(mfp->mntent_fp)) {
-		int errsv =3D errno;
-		nfs_error(_("warning: error reading %s: %s"),
-		      fnam, strerror (errsv));
-		mc0->nxt =3D mc0->prev =3D NULL;
-	}
-	nfs_endmntent(mfp);
-}
-
-/*
- * Read /etc/mtab.  If that fails, try /proc/mounts.
- * This produces a linked list. The list head mounttable is a dummy.
- * Return 0 on success.
- */
-static void
-read_mounttable() {
-        mntFILE *mfp;
-        const char *fnam;
-        struct mntentchn *mc =3D &mounttable;
-
-        got_mtab =3D 1;
-        mc->nxt =3D mc->prev =3D NULL;
-
-        fnam =3D MOUNTED;
-        mfp =3D nfs_setmntent (fnam, "r");
-        if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
-                int errsv =3D errno;
-                fnam =3D PROC_MOUNTS;
-                mfp =3D nfs_setmntent (fnam, "r");
-                if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
-                        nfs_error(_("warning: can't open %s: %s"),
-                              MOUNTED, strerror (errsv));
-                        return;
-                }
-                if (verbose)
-                        printf (_("mount: could not open %s - "
-                                  "using %s instead\n"),
-                                MOUNTED, PROC_MOUNTS);
-        }
-        read_mntentchn(mfp, fnam, mc);
-}
-
-static void
-read_fstab()
-{
-	mntFILE *mfp =3D NULL;
-	const char *fnam;
-	struct mntentchn *mc =3D &fstab;
-
-	got_fstab =3D 1;
-	mc->nxt =3D mc->prev =3D NULL;
-
-	fnam =3D _PATH_FSTAB;
-	mfp =3D nfs_setmntent (fnam, "r");
-	if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
-		int errsv =3D errno;
-		nfs_error(_("warning: can't open %s: %s"),
-			  _PATH_FSTAB, strerror (errsv));
-		return;
-	}
-	read_mntentchn(mfp, fnam, mc);
-}
-
-/*
- * Given the directory name NAME, and the place MCPREV we found it last =
time,
- * try to find more occurrences.
- */=20
-struct mntentchn *
-getmntdirbackward (const char *name, struct mntentchn *mcprev) {
-	struct mntentchn *mc, *mc0;
-
-	mc0 =3D mtab_head();
-	if (!mcprev)
-		mcprev =3D mc0;
-	for (mc =3D mcprev->prev; mc && mc !=3D mc0; mc =3D mc->prev)
-		if (streq(mc->m.mnt_dir, name))
-			return mc;
-	return NULL;
-}
-
-/*
- * Given the device name NAME, and the place MCPREV we found it last tim=
e,
- * try to find more occurrences.
- */=20
-struct mntentchn *
-getmntdevbackward (const char *name, struct mntentchn *mcprev) {
-	struct mntentchn *mc, *mc0;
-
-	mc0 =3D mtab_head();
-	if (!mcprev)
-		mcprev =3D mc0;
-	for (mc =3D mcprev->prev; mc && mc !=3D mc0; mc =3D mc->prev)
-		if (streq(mc->m.mnt_fsname, name))
-			return mc;
-	return NULL;
-}
-
-/* Find the dir FILE in fstab.  */
-struct mntentchn *
-getfsfile (const char *file)
-{
-	struct mntentchn *mc, *mc0;
-
-	mc0 =3D fstab_head();
-	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc->nxt)
-		if (streq(mc->m.mnt_dir, file))
-			return mc;
-	return NULL;
-}
-
-/* Find the device SPEC in fstab.  */
-struct mntentchn *
-getfsspec (const char *spec)
-{
-	struct mntentchn *mc, *mc0;
-
-	mc0 =3D fstab_head();
-	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc->nxt)
-		if (streq(mc->m.mnt_fsname, spec))
-			return mc;
-	return NULL;
-}
-
-/* Updating mtab ----------------------------------------------*/
-
-/* Flag for already existing lock file. */
-static int we_created_lockfile =3D 0;
-static int lockfile_fd =3D -1;
-
-/* Flag to indicate that signals have been set up. */
-static int signals_have_been_setup =3D 0;
-
-/* Ensure that the lock is released if we are interrupted.  */
-extern char *strsignal(int sig);	/* not always in <string.h> */
-
-static void
-handler (int sig) {
-     die(EX_USER, "%s", strsignal(sig));
-}
-
-static void
-setlkw_timeout (int sig) {
-     /* nothing, fcntl will fail anyway */
-}
-
-/* Remove lock file.  */
-void
-unlock_mtab (void) {
-	if (we_created_lockfile) {
-		close(lockfile_fd);
-		lockfile_fd =3D -1;
-		unlink (MOUNTED_LOCK);
-		we_created_lockfile =3D 0;
-	}
-}
-
-/* Create the lock file.
-   The lock file will be removed if we catch a signal or when we exit. *=
/
-/* The old code here used flock on a lock file /etc/mtab~ and deleted
-   this lock file afterwards. However, as rgooch remarks, that has a
-   race: a second mount may be waiting on the lock and proceed as
-   soon as the lock file is deleted by the first mount, and immediately
-   afterwards a third mount comes, creates a new /etc/mtab~, applies
-   flock to that, and also proceeds, so that the second and third mount
-   now both are scribbling in /etc/mtab.
-   The new code uses a link() instead of a creat(), where we proceed
-   only if it was us that created the lock, and hence we always have
-   to delete the lock afterwards. Now the use of flock() is in principle
-   superfluous, but avoids an arbitrary sleep(). */
-
-/* Where does the link point to? Obvious choices are mtab and mtab~~.
-   HJLu points out that the latter leads to races. Right now we use
-   mtab~.<pid> instead. Use 20 as upper bound for the length of %d. */
-#define MOUNTLOCK_LINKTARGET		MOUNTED_LOCK "%d"
-#define MOUNTLOCK_LINKTARGET_LTH	(sizeof(MOUNTED_LOCK)+20)
-
-void
-lock_mtab (void) {
-	int tries =3D 100000, i;
-	char linktargetfile[MOUNTLOCK_LINKTARGET_LTH];
-
-	at_die =3D unlock_mtab;
-
-	if (!signals_have_been_setup) {
-		int sig =3D 0;
-		struct sigaction sa;
-
-		sa.sa_handler =3D handler;
-		sa.sa_flags =3D 0;
-		sigfillset (&sa.sa_mask);
- =20
-		while (sigismember (&sa.sa_mask, ++sig) !=3D -1
-		       && sig !=3D SIGCHLD) {
-			if (sig =3D=3D SIGALRM)
-				sa.sa_handler =3D setlkw_timeout;
-			else
-				sa.sa_handler =3D handler;
-			sigaction (sig, &sa, (struct sigaction *) 0);
-		}
-		signals_have_been_setup =3D 1;
-	}
-
-	sprintf(linktargetfile, MOUNTLOCK_LINKTARGET, getpid ());
-
-	i =3D open (linktargetfile, O_WRONLY|O_CREAT, 0);
-	if (i < 0) {
-		int errsv =3D errno;
-		/* linktargetfile does not exist (as a file)
-		   and we cannot create it. Read-only filesystem?
-		   Too many files open in the system?
-		   Filesystem full? */
-		die (EX_FILEIO, _("can't create lock file %s: %s "
-						  "(use -n flag to override)"),
-			 linktargetfile, strerror (errsv));
-	}
-	close(i);
-=09
-	/* Repeat until it was us who made the link */
-	while (!we_created_lockfile) {
-		struct flock flock;
-		int errsv, j;
-
-		j =3D link(linktargetfile, MOUNTED_LOCK);
-		errsv =3D errno;
-
-		if (j =3D=3D 0)
-			we_created_lockfile =3D 1;
-
-		if (j < 0 && errsv !=3D EEXIST) {
-			(void) unlink(linktargetfile);
-			die (EX_FILEIO, _("can't link lock file %s: %s "
-			     "(use -n flag to override)"),
-			     MOUNTED_LOCK, strerror (errsv));
-		}
-
-		lockfile_fd =3D open (MOUNTED_LOCK, O_WRONLY);
-
-		if (lockfile_fd < 0) {
-			int errsv =3D errno;
-			/* Strange... Maybe the file was just deleted? */
-			if (errno =3D=3D ENOENT && tries-- > 0) {
-				if (tries % 200 =3D=3D 0)
-					usleep(30);
-				continue;
-			}
-			(void) unlink(linktargetfile);
-			die (EX_FILEIO, _("can't open lock file %s: %s "
-			     "(use -n flag to override)"),
-			     MOUNTED_LOCK, strerror (errsv));
-		}
-
-		flock.l_type =3D F_WRLCK;
-		flock.l_whence =3D SEEK_SET;
-		flock.l_start =3D 0;
-		flock.l_len =3D 0;
-
-		if (j =3D=3D 0) {
-			/* We made the link. Now claim the lock. */
-			if (fcntl (lockfile_fd, F_SETLK, &flock) =3D=3D -1) {
-				if (verbose) {
-				    int errsv =3D errno;
-				    printf(_("Can't lock lock file %s: %s\n"),
-					   MOUNTED_LOCK, strerror (errsv));
-				}
-				/* proceed anyway */
-			}
-			(void) unlink(linktargetfile);
-		} else {
-			static int tries =3D 0;
-
-			/* Someone else made the link. Wait. */
-			alarm(LOCK_TIMEOUT);
-			if (fcntl (lockfile_fd, F_SETLKW, &flock) =3D=3D -1) {
-				int errsv =3D errno;
-				(void) unlink(linktargetfile);
-				die (EX_FILEIO, _("can't lock lock file %s: %s"),
-				     MOUNTED_LOCK, (errno =3D=3D EINTR) ?
-				     _("timed out") : strerror (errsv));
-			}
-			alarm(0);
-			/* Limit the number of iterations - maybe there
-			   still is some old /etc/mtab~ */
-			++tries;
-			if (tries % 200 =3D=3D 0)
-			   usleep(30);
-			if (tries > 100000) {
-				(void) unlink(linktargetfile);
-				close(lockfile_fd);
-				die (EX_FILEIO, _("Cannot create link %s\n"
-						  "Perhaps there is a stale lock file?\n"),
-					 MOUNTED_LOCK);
- 			}
-			close(lockfile_fd);
-		}
-	}
-}
-
-/*
- * Update the mtab.
- *  Used by umount with null INSTEAD: remove the last DIR entry.
- *  Used by mount upon a remount: update option part,
- *   and complain if a wrong device or type was given.
- *   [Note that often a remount will be a rw remount of /
- *    where there was no entry before, and we'll have to believe
- *    the values given in INSTEAD.]
- */
-
-void
-update_mtab (const char *dir, struct mntent *instead)
-{
-	mntFILE *mfp, *mftmp;
-	const char *fnam =3D MOUNTED;
-	struct mntentchn mtabhead;	/* dummy */
-	struct mntentchn *mc, *mc0, *absent =3D NULL;
-
-	if (mtab_does_not_exist() || !mtab_is_writable())
-		return;
-
-	lock_mtab();
-
-	/* having locked mtab, read it again */
-	mc0 =3D mc =3D &mtabhead;
-	mc->nxt =3D mc->prev =3D NULL;
-
-	mfp =3D nfs_setmntent(fnam, "r");
-	if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
-		int errsv =3D errno;
-		nfs_error (_("cannot open %s (%s) - mtab not updated"),
-		       fnam, strerror (errsv));
-		goto leave;
-	}
-
-	read_mntentchn(mfp, fnam, mc);
-
-	/* find last occurrence of dir */
-	for (mc =3D mc0->prev; mc && mc !=3D mc0; mc =3D mc->prev)
-		if (streq(mc->m.mnt_dir, dir))
-			break;
-	if (mc && mc !=3D mc0) {
-		if (instead =3D=3D NULL) {
-			/* An umount - remove entry */
-			if (mc && mc !=3D mc0) {
-				mc->prev->nxt =3D mc->nxt;
-				mc->nxt->prev =3D mc->prev;
-				free(mc);
-			}
-		} else {
-			/* A remount */
-			mc->m.mnt_opts =3D instead->mnt_opts;
-		}
-	} else if (instead) {
-		/* not found, add a new entry */
-		absent =3D xmalloc(sizeof(*absent));
-		absent->m =3D *instead;
-		absent->nxt =3D mc0;
-		absent->prev =3D mc0->prev;
-		mc0->prev =3D absent;
-		if (mc0->nxt =3D=3D NULL)
-			mc0->nxt =3D absent;
-	}
-
-	/* write chain to mtemp */
-	mftmp =3D nfs_setmntent (MOUNTED_TEMP, "w");
-	if (mftmp =3D=3D NULL || mftmp->mntent_fp =3D=3D NULL) {
-		int errsv =3D errno;
-		nfs_error (_("cannot open %s (%s) - mtab not updated"),
-		       MOUNTED_TEMP, strerror (errsv));
-		goto leave;
-	}
-
-	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc->nxt) {
-		if (nfs_addmntent(mftmp, &(mc->m)) =3D=3D 1) {
-			int errsv =3D errno;
-			die (EX_FILEIO, _("error writing %s: %s"),
-			     MOUNTED_TEMP, strerror (errsv));
-		}
-	}
-
-#if 0
-	/* the chain might have strings copied from 'instead',
-	 * so we cannot safely free it.
-	 * And there is no need anyway because we are going to exit
-	 * shortly.  So just don't call discard_mntentchn....
-	 */
-	discard_mntentchn(mc0);
-#endif
-	if (fchmod (fileno (mftmp->mntent_fp),
-		    S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH) < 0) {
-		int errsv =3D errno;
-		fprintf(stderr, _("error changing mode of %s: %s\n"),
-			MOUNTED_TEMP, strerror (errsv));
-	}
-	nfs_endmntent (mftmp);
-
-	{ /*
-	   * If mount is setuid and some non-root user mounts sth,
-	   * then mtab.tmp might get the group of this user. Copy uid/gid
-	   * from the present mtab before renaming.
-	   */
-	    struct stat sbuf;
-	    if (stat (MOUNTED, &sbuf) =3D=3D 0)
-		chown (MOUNTED_TEMP, sbuf.st_uid, sbuf.st_gid);
-	}
-
-	/* rename mtemp to mtab */
-	if (rename (MOUNTED_TEMP, MOUNTED) < 0) {
-		int errsv =3D errno;
-		fprintf(stderr, _("can't rename %s to %s: %s\n"),
-			MOUNTED_TEMP, MOUNTED, strerror(errsv));
-	}
-
- leave:
-	unlock_mtab();
-}
diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index be83e2c..a5d7292 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -9,10 +9,10 @@ man5_MANS	=3D nfs.man
=20
 sbin_PROGRAMS	=3D mount.nfs
 EXTRA_DIST =3D nfsmount.x $(man8_MANS) $(man5_MANS)
-mount_nfs_SOURCES =3D mount.c error.c network.c \
+mount_nfs_SOURCES =3D mount.c error.c network.c fstab.c \
 		    nfsmount.c nfs4mount.c \
 		    nfsumount.c \
-		    mount_constants.h error.h network.h \
+		    mount_constants.h error.h network.h fstab.h \
 		    nfs4_mount.h nfs_mount4.h
=20
 mount_nfs_LDADD =3D ../../support/nfs/libnfs.a \
diff --git a/utils/mount/fstab.c b/utils/mount/fstab.c
new file mode 100644
index 0000000..aee8e53
--- /dev/null
+++ b/utils/mount/fstab.c
@@ -0,0 +1,554 @@
+/* 1999-02-22 Arkadiusz Mi=B6kiewicz <misiek@pld.ORG.PL>
+ * - added Native Language Support
+ * Sun Mar 21 1999 - Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ * - fixed strerr(errno) in gettext calls
+ *
+ * 2006-06-08 Amit Gud <agud@redhat.com>
+ * - Moved code to nfs-utils/support/nfs from util-linux/mount.
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <mntent.h>
+
+#include "fstab.h"
+#include "xcommon.h"
+#include "nfs_mntent.h"
+#include "nfs_paths.h"
+#include "nls.h"
+
+#define LOCK_TIMEOUT	10
+#define streq(s, t)	(strcmp ((s), (t)) =3D=3D 0)
+#define PROC_MOUNTS		"/proc/mounts"
+
+extern int verbose;
+
+/* Information about mtab. ------------------------------------*/
+static int have_mtab_info =3D 0;
+static int var_mtab_does_not_exist =3D 0;
+static int var_mtab_is_a_symlink =3D 0;
+
+static void
+get_mtab_info(void) {
+	struct stat mtab_stat;
+
+	if (!have_mtab_info) {
+		if (lstat(MOUNTED, &mtab_stat))
+			var_mtab_does_not_exist =3D 1;
+		else if (S_ISLNK(mtab_stat.st_mode))
+			var_mtab_is_a_symlink =3D 1;
+		have_mtab_info =3D 1;
+	}
+}
+
+int
+mtab_does_not_exist(void) {
+	get_mtab_info();
+	return var_mtab_does_not_exist;
+}
+
+static int
+mtab_is_a_symlink(void) {
+        get_mtab_info();
+        return var_mtab_is_a_symlink;
+}
+
+int
+mtab_is_writable() {
+	int fd;
+
+	/* Should we write to /etc/mtab upon an update?
+	   Probably not if it is a symlink to /proc/mounts, since that
+	   would create a file /proc/mounts in case the proc filesystem
+	   is not mounted. */
+	if (mtab_is_a_symlink())
+		return 0;
+
+	fd =3D open(MOUNTED, O_RDWR | O_CREAT, 0644);
+	if (fd >=3D 0) {
+		close(fd);
+		return 1;
+	} else
+		return 0;
+}
+
+/* Contents of mtab and fstab ---------------------------------*/
+
+struct mntentchn mounttable;
+static int got_mtab =3D 0;
+struct mntentchn fstab;
+static int got_fstab =3D 0;
+
+static void read_mounttable(void);
+static void read_fstab(void);
+
+static struct mntentchn *
+mtab_head() {
+	if (!got_mtab)
+		read_mounttable();
+	return &mounttable;
+}
+
+static struct mntentchn *
+fstab_head()
+{
+	if (!got_fstab)
+		read_fstab();
+	return &fstab;
+}
+
+#if 0
+static void
+my_free(const void *s) {
+	if (s)
+		free((void *) s);
+}
+
+static void
+discard_mntentchn(struct mntentchn *mc0) {
+	struct mntentchn *mc, *mc1;
+
+	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc1) {
+		mc1 =3D mc->nxt;
+		my_free(mc->m.mnt_fsname);
+		my_free(mc->m.mnt_dir);
+		my_free(mc->m.mnt_type);
+		my_free(mc->m.mnt_opts);
+		free(mc);
+	}
+}
+#endif
+
+static void
+read_mntentchn(mntFILE *mfp, const char *fnam, struct mntentchn *mc0) {
+	struct mntentchn *mc =3D mc0;
+	struct mntent *mnt;
+
+	while ((mnt =3D nfs_getmntent(mfp)) !=3D NULL) {
+		if (!streq(mnt->mnt_type, MNTTYPE_IGNORE)) {
+			mc->nxt =3D (struct mntentchn *) xmalloc(sizeof(*mc));
+			mc->nxt->prev =3D mc;
+			mc =3D mc->nxt;
+			mc->m =3D *mnt;
+			mc->nxt =3D mc0;
+		}
+	}
+	mc0->prev =3D mc;
+	if (ferror(mfp->mntent_fp)) {
+		int errsv =3D errno;
+		nfs_error(_("warning: error reading %s: %s"),
+		      fnam, strerror (errsv));
+		mc0->nxt =3D mc0->prev =3D NULL;
+	}
+	nfs_endmntent(mfp);
+}
+
+/*
+ * Read /etc/mtab.  If that fails, try /proc/mounts.
+ * This produces a linked list. The list head mounttable is a dummy.
+ * Return 0 on success.
+ */
+static void
+read_mounttable() {
+        mntFILE *mfp;
+        const char *fnam;
+        struct mntentchn *mc =3D &mounttable;
+
+        got_mtab =3D 1;
+        mc->nxt =3D mc->prev =3D NULL;
+
+        fnam =3D MOUNTED;
+        mfp =3D nfs_setmntent (fnam, "r");
+        if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
+                int errsv =3D errno;
+                fnam =3D PROC_MOUNTS;
+                mfp =3D nfs_setmntent (fnam, "r");
+                if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
+                        nfs_error(_("warning: can't open %s: %s"),
+                              MOUNTED, strerror (errsv));
+                        return;
+                }
+                if (verbose)
+                        printf (_("mount: could not open %s - "
+                                  "using %s instead\n"),
+                                MOUNTED, PROC_MOUNTS);
+        }
+        read_mntentchn(mfp, fnam, mc);
+}
+
+static void
+read_fstab()
+{
+	mntFILE *mfp =3D NULL;
+	const char *fnam;
+	struct mntentchn *mc =3D &fstab;
+
+	got_fstab =3D 1;
+	mc->nxt =3D mc->prev =3D NULL;
+
+	fnam =3D _PATH_FSTAB;
+	mfp =3D nfs_setmntent (fnam, "r");
+	if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
+		int errsv =3D errno;
+		nfs_error(_("warning: can't open %s: %s"),
+			  _PATH_FSTAB, strerror (errsv));
+		return;
+	}
+	read_mntentchn(mfp, fnam, mc);
+}
+
+/*
+ * Given the directory name NAME, and the place MCPREV we found it last =
time,
+ * try to find more occurrences.
+ */=20
+struct mntentchn *
+getmntdirbackward (const char *name, struct mntentchn *mcprev) {
+	struct mntentchn *mc, *mc0;
+
+	mc0 =3D mtab_head();
+	if (!mcprev)
+		mcprev =3D mc0;
+	for (mc =3D mcprev->prev; mc && mc !=3D mc0; mc =3D mc->prev)
+		if (streq(mc->m.mnt_dir, name))
+			return mc;
+	return NULL;
+}
+
+/*
+ * Given the device name NAME, and the place MCPREV we found it last tim=
e,
+ * try to find more occurrences.
+ */=20
+struct mntentchn *
+getmntdevbackward (const char *name, struct mntentchn *mcprev) {
+	struct mntentchn *mc, *mc0;
+
+	mc0 =3D mtab_head();
+	if (!mcprev)
+		mcprev =3D mc0;
+	for (mc =3D mcprev->prev; mc && mc !=3D mc0; mc =3D mc->prev)
+		if (streq(mc->m.mnt_fsname, name))
+			return mc;
+	return NULL;
+}
+
+/* Find the dir FILE in fstab.  */
+struct mntentchn *
+getfsfile (const char *file)
+{
+	struct mntentchn *mc, *mc0;
+
+	mc0 =3D fstab_head();
+	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc->nxt)
+		if (streq(mc->m.mnt_dir, file))
+			return mc;
+	return NULL;
+}
+
+/* Find the device SPEC in fstab.  */
+struct mntentchn *
+getfsspec (const char *spec)
+{
+	struct mntentchn *mc, *mc0;
+
+	mc0 =3D fstab_head();
+	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc->nxt)
+		if (streq(mc->m.mnt_fsname, spec))
+			return mc;
+	return NULL;
+}
+
+/* Updating mtab ----------------------------------------------*/
+
+/* Flag for already existing lock file. */
+static int we_created_lockfile =3D 0;
+static int lockfile_fd =3D -1;
+
+/* Flag to indicate that signals have been set up. */
+static int signals_have_been_setup =3D 0;
+
+/* Ensure that the lock is released if we are interrupted.  */
+extern char *strsignal(int sig);	/* not always in <string.h> */
+
+static void
+handler (int sig) {
+     die(EX_USER, "%s", strsignal(sig));
+}
+
+static void
+setlkw_timeout (int sig) {
+     /* nothing, fcntl will fail anyway */
+}
+
+/* Remove lock file.  */
+void
+unlock_mtab (void) {
+	if (we_created_lockfile) {
+		close(lockfile_fd);
+		lockfile_fd =3D -1;
+		unlink (MOUNTED_LOCK);
+		we_created_lockfile =3D 0;
+	}
+}
+
+/* Create the lock file.
+   The lock file will be removed if we catch a signal or when we exit. *=
/
+/* The old code here used flock on a lock file /etc/mtab~ and deleted
+   this lock file afterwards. However, as rgooch remarks, that has a
+   race: a second mount may be waiting on the lock and proceed as
+   soon as the lock file is deleted by the first mount, and immediately
+   afterwards a third mount comes, creates a new /etc/mtab~, applies
+   flock to that, and also proceeds, so that the second and third mount
+   now both are scribbling in /etc/mtab.
+   The new code uses a link() instead of a creat(), where we proceed
+   only if it was us that created the lock, and hence we always have
+   to delete the lock afterwards. Now the use of flock() is in principle
+   superfluous, but avoids an arbitrary sleep(). */
+
+/* Where does the link point to? Obvious choices are mtab and mtab~~.
+   HJLu points out that the latter leads to races. Right now we use
+   mtab~.<pid> instead. Use 20 as upper bound for the length of %d. */
+#define MOUNTLOCK_LINKTARGET		MOUNTED_LOCK "%d"
+#define MOUNTLOCK_LINKTARGET_LTH	(sizeof(MOUNTED_LOCK)+20)
+
+void
+lock_mtab (void) {
+	int tries =3D 100000, i;
+	char linktargetfile[MOUNTLOCK_LINKTARGET_LTH];
+
+	at_die =3D unlock_mtab;
+
+	if (!signals_have_been_setup) {
+		int sig =3D 0;
+		struct sigaction sa;
+
+		sa.sa_handler =3D handler;
+		sa.sa_flags =3D 0;
+		sigfillset (&sa.sa_mask);
+ =20
+		while (sigismember (&sa.sa_mask, ++sig) !=3D -1
+		       && sig !=3D SIGCHLD) {
+			if (sig =3D=3D SIGALRM)
+				sa.sa_handler =3D setlkw_timeout;
+			else
+				sa.sa_handler =3D handler;
+			sigaction (sig, &sa, (struct sigaction *) 0);
+		}
+		signals_have_been_setup =3D 1;
+	}
+
+	sprintf(linktargetfile, MOUNTLOCK_LINKTARGET, getpid ());
+
+	i =3D open (linktargetfile, O_WRONLY|O_CREAT, 0);
+	if (i < 0) {
+		int errsv =3D errno;
+		/* linktargetfile does not exist (as a file)
+		   and we cannot create it. Read-only filesystem?
+		   Too many files open in the system?
+		   Filesystem full? */
+		die (EX_FILEIO, _("can't create lock file %s: %s "
+						  "(use -n flag to override)"),
+			 linktargetfile, strerror (errsv));
+	}
+	close(i);
+=09
+	/* Repeat until it was us who made the link */
+	while (!we_created_lockfile) {
+		struct flock flock;
+		int errsv, j;
+
+		j =3D link(linktargetfile, MOUNTED_LOCK);
+		errsv =3D errno;
+
+		if (j =3D=3D 0)
+			we_created_lockfile =3D 1;
+
+		if (j < 0 && errsv !=3D EEXIST) {
+			(void) unlink(linktargetfile);
+			die (EX_FILEIO, _("can't link lock file %s: %s "
+			     "(use -n flag to override)"),
+			     MOUNTED_LOCK, strerror (errsv));
+		}
+
+		lockfile_fd =3D open (MOUNTED_LOCK, O_WRONLY);
+
+		if (lockfile_fd < 0) {
+			int errsv =3D errno;
+			/* Strange... Maybe the file was just deleted? */
+			if (errno =3D=3D ENOENT && tries-- > 0) {
+				if (tries % 200 =3D=3D 0)
+					usleep(30);
+				continue;
+			}
+			(void) unlink(linktargetfile);
+			die (EX_FILEIO, _("can't open lock file %s: %s "
+			     "(use -n flag to override)"),
+			     MOUNTED_LOCK, strerror (errsv));
+		}
+
+		flock.l_type =3D F_WRLCK;
+		flock.l_whence =3D SEEK_SET;
+		flock.l_start =3D 0;
+		flock.l_len =3D 0;
+
+		if (j =3D=3D 0) {
+			/* We made the link. Now claim the lock. */
+			if (fcntl (lockfile_fd, F_SETLK, &flock) =3D=3D -1) {
+				if (verbose) {
+				    int errsv =3D errno;
+				    printf(_("Can't lock lock file %s: %s\n"),
+					   MOUNTED_LOCK, strerror (errsv));
+				}
+				/* proceed anyway */
+			}
+			(void) unlink(linktargetfile);
+		} else {
+			static int tries =3D 0;
+
+			/* Someone else made the link. Wait. */
+			alarm(LOCK_TIMEOUT);
+			if (fcntl (lockfile_fd, F_SETLKW, &flock) =3D=3D -1) {
+				int errsv =3D errno;
+				(void) unlink(linktargetfile);
+				die (EX_FILEIO, _("can't lock lock file %s: %s"),
+				     MOUNTED_LOCK, (errno =3D=3D EINTR) ?
+				     _("timed out") : strerror (errsv));
+			}
+			alarm(0);
+			/* Limit the number of iterations - maybe there
+			   still is some old /etc/mtab~ */
+			++tries;
+			if (tries % 200 =3D=3D 0)
+			   usleep(30);
+			if (tries > 100000) {
+				(void) unlink(linktargetfile);
+				close(lockfile_fd);
+				die (EX_FILEIO, _("Cannot create link %s\n"
+						  "Perhaps there is a stale lock file?\n"),
+					 MOUNTED_LOCK);
+ 			}
+			close(lockfile_fd);
+		}
+	}
+}
+
+/*
+ * Update the mtab.
+ *  Used by umount with null INSTEAD: remove the last DIR entry.
+ *  Used by mount upon a remount: update option part,
+ *   and complain if a wrong device or type was given.
+ *   [Note that often a remount will be a rw remount of /
+ *    where there was no entry before, and we'll have to believe
+ *    the values given in INSTEAD.]
+ */
+
+void
+update_mtab (const char *dir, struct mntent *instead)
+{
+	mntFILE *mfp, *mftmp;
+	const char *fnam =3D MOUNTED;
+	struct mntentchn mtabhead;	/* dummy */
+	struct mntentchn *mc, *mc0, *absent =3D NULL;
+
+	if (mtab_does_not_exist() || !mtab_is_writable())
+		return;
+
+	lock_mtab();
+
+	/* having locked mtab, read it again */
+	mc0 =3D mc =3D &mtabhead;
+	mc->nxt =3D mc->prev =3D NULL;
+
+	mfp =3D nfs_setmntent(fnam, "r");
+	if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
+		int errsv =3D errno;
+		nfs_error (_("cannot open %s (%s) - mtab not updated"),
+		       fnam, strerror (errsv));
+		goto leave;
+	}
+
+	read_mntentchn(mfp, fnam, mc);
+
+	/* find last occurrence of dir */
+	for (mc =3D mc0->prev; mc && mc !=3D mc0; mc =3D mc->prev)
+		if (streq(mc->m.mnt_dir, dir))
+			break;
+	if (mc && mc !=3D mc0) {
+		if (instead =3D=3D NULL) {
+			/* An umount - remove entry */
+			if (mc && mc !=3D mc0) {
+				mc->prev->nxt =3D mc->nxt;
+				mc->nxt->prev =3D mc->prev;
+				free(mc);
+			}
+		} else {
+			/* A remount */
+			mc->m.mnt_opts =3D instead->mnt_opts;
+		}
+	} else if (instead) {
+		/* not found, add a new entry */
+		absent =3D xmalloc(sizeof(*absent));
+		absent->m =3D *instead;
+		absent->nxt =3D mc0;
+		absent->prev =3D mc0->prev;
+		mc0->prev =3D absent;
+		if (mc0->nxt =3D=3D NULL)
+			mc0->nxt =3D absent;
+	}
+
+	/* write chain to mtemp */
+	mftmp =3D nfs_setmntent (MOUNTED_TEMP, "w");
+	if (mftmp =3D=3D NULL || mftmp->mntent_fp =3D=3D NULL) {
+		int errsv =3D errno;
+		nfs_error (_("cannot open %s (%s) - mtab not updated"),
+		       MOUNTED_TEMP, strerror (errsv));
+		goto leave;
+	}
+
+	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc->nxt) {
+		if (nfs_addmntent(mftmp, &(mc->m)) =3D=3D 1) {
+			int errsv =3D errno;
+			die (EX_FILEIO, _("error writing %s: %s"),
+			     MOUNTED_TEMP, strerror (errsv));
+		}
+	}
+
+#if 0
+	/* the chain might have strings copied from 'instead',
+	 * so we cannot safely free it.
+	 * And there is no need anyway because we are going to exit
+	 * shortly.  So just don't call discard_mntentchn....
+	 */
+	discard_mntentchn(mc0);
+#endif
+	if (fchmod (fileno (mftmp->mntent_fp),
+		    S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH) < 0) {
+		int errsv =3D errno;
+		fprintf(stderr, _("error changing mode of %s: %s\n"),
+			MOUNTED_TEMP, strerror (errsv));
+	}
+	nfs_endmntent (mftmp);
+
+	{ /*
+	   * If mount is setuid and some non-root user mounts sth,
+	   * then mtab.tmp might get the group of this user. Copy uid/gid
+	   * from the present mtab before renaming.
+	   */
+	    struct stat sbuf;
+	    if (stat (MOUNTED, &sbuf) =3D=3D 0)
+		chown (MOUNTED_TEMP, sbuf.st_uid, sbuf.st_gid);
+	}
+
+	/* rename mtemp to mtab */
+	if (rename (MOUNTED_TEMP, MOUNTED) < 0) {
+		int errsv =3D errno;
+		fprintf(stderr, _("can't rename %s to %s: %s\n"),
+			MOUNTED_TEMP, MOUNTED, strerror(errsv));
+	}
+
+ leave:
+	unlock_mtab();
+}
diff --git a/utils/mount/fstab.h b/utils/mount/fstab.h
new file mode 100644
index 0000000..64c8355
--- /dev/null
+++ b/utils/mount/fstab.h
@@ -0,0 +1,30 @@
+#ifndef _NFS_FSTAB_H
+#define _NFS_FSTAB_H
+
+#include "nfs_mntent.h"
+
+#ifndef _PATH_FSTAB
+#define _PATH_FSTAB "/etc/fstab"
+#endif
+
+int mtab_is_writable(void);
+int mtab_does_not_exist(void);
+
+struct mntentchn {
+	struct mntentchn *nxt, *prev;
+	struct mntent m;
+};
+
+struct mntentchn *getmntoptfile (const char *file);
+struct mntentchn *getmntdirbackward (const char *dir, struct mntentchn *=
mc);
+struct mntentchn *getmntdevbackward (const char *dev, struct mntentchn *=
mc);
+
+struct mntentchn *getfsfile (const char *file);
+struct mntentchn *getfsspec (const char *spec);
+
+void lock_mtab (void);
+void unlock_mtab (void);
+void update_mtab (const char *special, struct mntent *with);
+
+#endif /* _NFS_FSTAB_H */
+



--===============0534123890==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0534123890==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0534123890==--
