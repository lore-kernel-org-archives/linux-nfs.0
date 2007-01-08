From: Jeffrey Law <law@redhat.com>
Subject: Moving mtab's lock file from /etc to /var/lock
Date: Mon, 08 Jan 2007 10:44:27 -0700
Message-ID: <1168278267.28081.466.camel@sweet.slc.redhat.com>
Reply-To: law@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lPlhU2DyNwzYv2XdhzM2"
Cc: fenlason@redhat.com, kzak@redhat.com, cfeist@redhat.com,
	steved@redhat.com, mitr@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H3yXv-0002ue-Hk
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 09:44:31 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H3yXw-0008RE-GH
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 09:44:33 -0800
To: ezk@cs.sunysb.com, miklos@szeredi.hu, vandrove@vc.cvut.cz,
	nfs@lists.sourceforge.net
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


--=-lPlhU2DyNwzYv2XdhzM2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Red Hat has been investing developer resources into improving support
for read only root filesystems.  For some files/directories we can use
bind mounts to make some specific files within a readonly filesystem
appear writable (/etc/mtab for example).

However, this approach does not work well in some cases, for example,
the mechanisms used to manipulate the mtab lock file.

mtab locking works (simplified) as follows:

  1. Create /etc/mtab~XXXXX  (where XXXXX is replaced by a pid)

  2. Attempt to link /etc/mtab~XXXXX to /etc/mtab~
     2a. flock /etc/mtab~

  3. If link/flock unsuccessful, goto 2.


This can not work in a read only root environment as step #1 and
step #2 require writing into /etc (unless we were to make /etc as
a whole writable, which would largely defeat the purpose of read
only root).

Luckily with a small amount of work we can simply relocate the
lock files to /var/lock.  That's really where they belong anyway.

Attached are the trivial changes to each package I could find that
cares about the location of the mtab lock file.  Obviously these
changes need to be installed and released in lock-step.  If there
are packages you think I might have missed, please let me know
and I'll investigate appropriately.





--=-lPlhU2DyNwzYv2XdhzM2
Content-Disposition: attachment; filename=am-utils-mtablock.patch
Content-Type: text/x-patch; name=am-utils-mtablock.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

*** am-utils-6.1.5/conf/mtab/mtab_linux.c.ORIG	2006-12-14 13:28:27.000000000 -0700
--- am-utils-6.1.5/conf/mtab/mtab_linux.c	2006-12-14 13:28:28.000000000 -0700
*************** setlkw_timeout(int sig)
*** 151,157 ****
   * HJLu points out that the latter leads to races.  Right now we use
   * mtab~.<pid> instead.
   */
! #define MOUNTED_LOCK "/etc/mtab~"
  #define MOUNTLOCK_LINKTARGET           MOUNTED_LOCK "%d"
  
  int
--- 151,157 ----
   * HJLu points out that the latter leads to races.  Right now we use
   * mtab~.<pid> instead.
   */
! #define MOUNTED_LOCK "/var/lock/mtab~"
  #define MOUNTLOCK_LINKTARGET           MOUNTED_LOCK "%d"
  
  int

--=-lPlhU2DyNwzYv2XdhzM2
Content-Disposition: attachment; filename=fuse-mtablock.patch
Content-Type: text/x-patch; name=fuse-mtablock.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

Only in fuse-2.6.0-new: README.fedora
diff -rcp fuse-2.6.0/util/fusermount.c fuse-2.6.0-new/util/fusermount.c
*** fuse-2.6.0/util/fusermount.c	Wed Oct 18 02:09:46 2006
--- fuse-2.6.0-new/util/fusermount.c	Mon Dec 18 12:09:36 2006
*************** static int do_unmount(const char *mnt, i
*** 105,111 ****
     modify the mtab file at once! */
  static int lock_mtab(void)
  {
!     const char *mtab_lock = _PATH_MOUNTED ".fuselock";
      int mtablock;
      int res;
      struct stat mtab_stat;
--- 105,111 ----
     modify the mtab file at once! */
  static int lock_mtab(void)
  {
!     const char *mtab_lock = "/var/lock/.fuselock";
      int mtablock;
      int res;
      struct stat mtab_stat;

--=-lPlhU2DyNwzYv2XdhzM2
Content-Disposition: attachment; filename=gfs2-mtablock.patch
Content-Type: text/x-patch; name=gfs2-mtablock.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

*** gfs2-0.1.7/mount/mtab.c.ORIG	2006-12-14 14:15:00.000000000 -0700
--- gfs2-0.1.7/mount/mtab.c	2006-12-14 14:15:04.000000000 -0700
*************** static int ignore_mtab(void)
*** 44,63 ****
  	return 1;
  }
  
! /* Whichever process successfully links their own /etc/mtab~pid file to
!    /etc/mtab~ gets the lock.  We just sleep/retry until we get the lock.
     This is the locking method used by util-linux/mount/fstab.c which we
     need to keep in sync with. */
  
  static void lock_mtab(void)
  {
! 	char fname[32];
  	int rv, fd, e, retries = 0;
  
  	if (ignore_mtab())
  		return;
  
! 	sprintf(fname, "/etc/mtab~%d", getpid());
   retry:
  	fd = open(fname, O_WRONLY|O_CREAT, 0);
  	e = errno;
--- 44,63 ----
  	return 1;
  }
  
! /* Whichever process successfully links their own /var/lock/mtab~pid file to
!    /var/lock/mtab~ gets the lock.  We just sleep/retry until we get the lock.
     This is the locking method used by util-linux/mount/fstab.c which we
     need to keep in sync with. */
  
  static void lock_mtab(void)
  {
! 	char fname[37];
  	int rv, fd, e, retries = 0;
  
  	if (ignore_mtab())
  		return;
  
! 	sprintf(fname, "/var/lock/mtab~%d", getpid());
   retry:
  	fd = open(fname, O_WRONLY|O_CREAT, 0);
  	e = errno;
*************** static void lock_mtab(void)
*** 65,82 ****
  		die("can't create mtab lock file %s: %s\n", fname, strerror(e));
  	close(fd);
  
! 	rv = link(fname, "/etc/mtab~");
  	e = errno;
  
  	unlink(fname);
  
  	if (rv < 0 && e != EEXIST)
! 		die("can't link %s to /etc/mtab~: %s\n", fname, strerror(e));
  
  	if (rv < 0) {
  		if (++retries > 5)
! 			warn("waiting to lock /etc/mtab~: try unlinking "
! 			     "stale /etc/mtab~ file\n");
  		sleep(1);
  		goto retry;
  	}
--- 65,82 ----
  		die("can't create mtab lock file %s: %s\n", fname, strerror(e));
  	close(fd);
  
! 	rv = link(fname, "/var/lock/mtab~");
  	e = errno;
  
  	unlink(fname);
  
  	if (rv < 0 && e != EEXIST)
! 		die("can't link %s to /var/lock/mtab~: %s\n", fname, strerror(e));
  
  	if (rv < 0) {
  		if (++retries > 5)
! 			warn("waiting to lock /var/lock/mtab~: try unlinking "
! 			     "stale /var/lock/mtab~ file\n");
  		sleep(1);
  		goto retry;
  	}
*************** static void unlock_mtab(void)
*** 86,92 ****
  {
  	if (ignore_mtab())
  		return;
! 	unlink("/etc/mtab~");
  }
  
  void add_mtab_entry(struct mount_options *mo)
--- 86,92 ----
  {
  	if (ignore_mtab())
  		return;
! 	unlink("/var/lock/mtab~");
  }
  
  void add_mtab_entry(struct mount_options *mo)

--=-lPlhU2DyNwzYv2XdhzM2
Content-Disposition: attachment; filename=ncpfs-mtablock.patch
Content-Type: text/x-patch; name=ncpfs-mtablock.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

*** ncpfs-2.2.6/sutil/ncpm_common.c.ORIG	2005-01-27 10:35:59.000000000 -0700
--- ncpfs-2.2.6/sutil/ncpm_common.c	2006-12-14 15:06:35.000000000 -0700
*************** process_connection (const struct ncp_mou
*** 1395,1400 ****
--- 1395,1402 ----
  }
  #endif /* MOUNT3 */
  
+ #define MOUNTED_LOCK "/var/lock/mtab~"
+ 
  static const struct smntflags {
  	unsigned int	flag;
  	const char*	name;
*************** void add_mnt_entry(char* mount_name, cha
*** 1438,1446 ****
  	if (ncpm_suser()) {
  		errexit(91, _("Cannot switch to superuser: %s\n"), strerror(errno));
  	}
! 	if ((fd = open(MOUNTED "~", O_RDWR | O_CREAT | O_EXCL, 0600)) == -1)
  	{
! 		errexit(58, _("Can't get %s~ lock file\n"), MOUNTED);
  	}
  	close(fd);
  
--- 1440,1448 ----
  	if (ncpm_suser()) {
  		errexit(91, _("Cannot switch to superuser: %s\n"), strerror(errno));
  	}
! 	if ((fd = open(MOUNTED_LOCK, O_RDWR | O_CREAT | O_EXCL, 0600)) == -1)
  	{
! 		errexit(58, _("Can't get %s lock file\n"), MOUNTED_LOCK);
  	}
  	close(fd);
  
*************** void add_mnt_entry(char* mount_name, cha
*** 1458,1466 ****
  	}
  	endmntent(mtab);
  
! 	if (unlink(MOUNTED "~") == -1)
  	{
! 		errexit(62, _("Can't remove %s~\n"), MOUNTED);
  	}
  	if (ncpm_normal()) {
  		errexit(90, _("Cannot relinquish superuser rights: %s\n"), strerror(EPERM));
--- 1460,1468 ----
  	}
  	endmntent(mtab);
  
! 	if (unlink(MOUNTED_LOCK) == -1)
  	{
! 		errexit(62, _("Can't remove %s\n"), MOUNTED_LOCK);
  	}
  	if (ncpm_normal()) {
  		errexit(90, _("Cannot relinquish superuser rights: %s\n"), strerror(EPERM));
*** ncpfs-2.2.6/sutil/ncpumount.c.ORIG	2005-01-27 10:35:59.000000000 -0700
--- ncpfs-2.2.6/sutil/ncpumount.c	2006-12-14 15:06:30.000000000 -0700
*************** static int __clearMtab (const char* moun
*** 141,146 ****
--- 141,147 ----
  	FILE *new_mtab;
  
  #define MOUNTED_TMP MOUNTED".tmp"
+ #define MOUNTED_LOCK "/var/lock/mtab~"
  
  	if ((mtab = setmntent(MOUNTED, "r")) == NULL){
  		eprintf(_("Can't open %s: %s\n"), MOUNTED,
*************** static int clearMtab (const char* mount_
*** 192,212 ****
  	if (!numEntries)
  		return 0; /* don't waste time ! */
  
! 	while ((fd = open(MOUNTED "~", O_RDWR | O_CREAT | O_EXCL, 0600)) == -1) {
  		struct timespec tm;
  
  		if (errno != EEXIST || retries == 0) {
! 			eprintf(_("Can't get %s~ lock file: %s\n"), MOUNTED, strerror(errno));
  			return 1;
  		}
! 		fd = open(MOUNTED "~", O_RDWR);
  		if (fd != -1) {
  			alarm(10);
  			err = lockf(fd, F_LOCK, 0);
  			alarm(0);
  			close(fd);
  			if (err) {
! 				eprintf(_("Can't lock lock file %s~: %s\n"), MOUNTED, _("Lock timed out"));
  				return 1;
  			}
  			tm.tv_sec = 0;
--- 193,213 ----
  	if (!numEntries)
  		return 0; /* don't waste time ! */
  
! 	while ((fd = open(MOUNTED_LOCK, O_RDWR | O_CREAT | O_EXCL, 0600)) == -1) {
  		struct timespec tm;
  
  		if (errno != EEXIST || retries == 0) {
! 			eprintf(_("Can't get %s lock file: %s\n"), MOUNTED_LOCK, strerror(errno));
  			return 1;
  		}
! 		fd = open(MOUNTED_LOCK, O_RDWR);
  		if (fd != -1) {
  			alarm(10);
  			err = lockf(fd, F_LOCK, 0);
  			alarm(0);
  			close(fd);
  			if (err) {
! 				eprintf(_("Can't lock lock file %s: %s\n"), MOUNTED_LOCK, _("Lock timed out"));
  				return 1;
  			}
  			tm.tv_sec = 0;
*************** static int clearMtab (const char* mount_
*** 222,229 ****
  
  	err = __clearMtab(mount_points, numEntries);
  
! 	if ((unlink(MOUNTED "~") == -1) && (err == 0)){
! 		eprintf(_("Can't remove %s~"), MOUNTED);
  		return 1;
  	}
  	return err;
--- 223,230 ----
  
  	err = __clearMtab(mount_points, numEntries);
  
! 	if ((unlink(MOUNTED_LOCK) == -1) && (err == 0)){
! 		eprintf(_("Can't remove %s"), MOUNTED_LOCK);
  		return 1;
  	}
  	return err;
*** ncpfs-2.2.6/sutil/ncpm_common.c.ORIG	Thu Dec 14 15:52:37 2006
--- ncpfs-2.2.6/sutil/ncpm_common.c	Thu Dec 14 15:53:12 2006
*************** process_connection (const struct ncp_mou
*** 1226,1232 ****
  	}
  	unix_fd = -1;
  	if (!stat(mnt->mount_point, &stb)) {
! 		unix_len = offsetof(struct sockaddr_un, sun_path) + sprintf(unix_addr.sun_path, "%cncpfs.permanent.mount.%lu", 0, (unsigned long)stb.st_dev) + 1;
  		unix_addr.sun_family = AF_UNIX;
  		unix_fd = prepare_unixfd(&unix_addr, unix_len);
  	}
--- 1226,1232 ----
  	}
  	unix_fd = -1;
  	if (!stat(mnt->mount_point, &stb)) {
! 		unix_len = __builtin_offsetof(struct sockaddr_un, sun_path) + sprintf(unix_addr.sun_path, "%cncpfs.permanent.mount.%lu", 0, (unsigned long)stb.st_dev) + 1;
  		unix_addr.sun_family = AF_UNIX;
  		unix_fd = prepare_unixfd(&unix_addr, unix_len);
  	}

--=-lPlhU2DyNwzYv2XdhzM2
Content-Disposition: attachment; filename=nfs-utils-mtablock.patch
Content-Type: text/x-patch; name=nfs-utils-mtablock.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

*** nfs-utils-1.0.9/support/include/nfs_paths.h.ORIG	2006-07-07 18:04:32.000000000 -0600
--- nfs-utils-1.0.9/support/include/nfs_paths.h	2006-12-14 14:38:19.000000000 -0700
***************
*** 4,10 ****
  #ifndef _PATH_MOUNTED
  #define _PATH_MOUNTED "/etc/fstab"
  #endif
! #define MOUNTED_LOCK	_PATH_MOUNTED "~"
  #define MOUNTED_TEMP	_PATH_MOUNTED ".tmp"
  
  #endif /* _NFS_PATHS_H */
--- 4,10 ----
  #ifndef _PATH_MOUNTED
  #define _PATH_MOUNTED "/etc/fstab"
  #endif
! #define MOUNTED_LOCK	"/var/lock/mtab~"
  #define MOUNTED_TEMP	_PATH_MOUNTED ".tmp"
  
  #endif /* _NFS_PATHS_H */

--=-lPlhU2DyNwzYv2XdhzM2
Content-Disposition: attachment; filename=samba-mtablock.patch
Content-Type: text/x-patch; name=samba-mtablock.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

Only in samba-3.0.23c-new/source/client: .smbumount.c.swp
diff -rcp samba-3.0.23c/source/client/smbmnt.c samba-3.0.23c-new/source/client/smbmnt.c
*** samba-3.0.23c/source/client/smbmnt.c	Thu Jul 28 07:19:53 2005
--- samba-3.0.23c-new/source/client/smbmnt.c	Mon Dec 18 10:22:44 2006
*************** do_mount(char *share_name, unsigned int 
*** 288,296 ****
  		return -1;
  	}
  	
!         if ((fd = open(MOUNTED"~", O_RDWR|O_CREAT|O_EXCL, 0600)) == -1)
          {
!                 fprintf(stderr, "Can't get "MOUNTED"~ lock file");
                  return 1;
          }
          close(fd);
--- 288,296 ----
  		return -1;
  	}
  	
!         if ((fd = open(MOUNTED_LOCK, O_RDWR|O_CREAT|O_EXCL, 0600)) == -1)
          {
!                 fprintf(stderr, "Can't get "MOUNTED_LOCK" lock file");
                  return 1;
          }
          close(fd);
*************** do_mount(char *share_name, unsigned int 
*** 315,321 ****
  
          if (unlink(MOUNTED"~") == -1)
          {
!                 fprintf(stderr, "Can't remove "MOUNTED"~");
                  return 1;
          }
  
--- 315,321 ----
  
          if (unlink(MOUNTED"~") == -1)
          {
!                 fprintf(stderr, "Can't remove "MOUNTED_LOCK);
                  return 1;
          }
  
diff -rcp samba-3.0.23c/source/client/smbmount.c samba-3.0.23c-new/source/client/smbmount.c
*** samba-3.0.23c/source/client/smbmount.c	Wed Apr 19 20:29:46 2006
--- samba-3.0.23c-new/source/client/smbmount.c	Mon Dec 18 10:23:20 2006
*************** static void smb_umount(char *mount_point
*** 271,278 ****
                  return;
          }
  
!         if ((fd = open(MOUNTED"~", O_RDWR|O_CREAT|O_EXCL, 0600)) == -1) {
!                 DEBUG(0,("%d: Can't get "MOUNTED"~ lock file", sys_getpid()));
                  return;
          }
  
--- 271,278 ----
                  return;
          }
  
!         if ((fd = open(MOUNTED_LOCK, O_RDWR|O_CREAT|O_EXCL, 0600)) == -1) {
!                 DEBUG(0,("%d: Can't get "MOUNTED_LOCK" lock file", sys_getpid()));
                  return;
          }
  
*************** static void smb_umount(char *mount_point
*** 315,322 ****
                  return;
          }
  
!         if (unlink(MOUNTED"~") == -1) {
!                 DEBUG(0,("%d: Can't remove "MOUNTED"~", sys_getpid()));
                  return;
          }
  }
--- 315,322 ----
                  return;
          }
  
!         if (unlink(MOUNTED_LOCK) == -1) {
!                 DEBUG(0,("%d: Can't remove "MOUNTED_LOCK, sys_getpid()));
                  return;
          }
  }
diff -rcp samba-3.0.23c/source/client/smbumount.c samba-3.0.23c-new/source/client/smbumount.c
*** samba-3.0.23c/source/client/smbumount.c	Thu Jul 28 07:19:53 2005
--- samba-3.0.23c-new/source/client/smbumount.c	Mon Dec 18 10:22:24 2006
*************** main(int argc, char *argv[])
*** 138,146 ****
                  exit(1);
          }
  
!         if ((fd = open(MOUNTED"~", O_RDWR|O_CREAT|O_EXCL, 0600)) == -1)
          {
!                 fprintf(stderr, "Can't get "MOUNTED"~ lock file");
                  return 1;
          }
          close(fd);
--- 138,146 ----
                  exit(1);
          }
  
!         if ((fd = open(MOUNTED_LOCK, O_RDWR|O_CREAT|O_EXCL, 0600)) == -1)
          {
!                 fprintf(stderr, "Can't get "MOUNTED_LOCK" lock file");
                  return 1;
          }
          close(fd);
*************** main(int argc, char *argv[])
*** 182,190 ****
                  exit(1);
          }
  
!         if (unlink(MOUNTED"~") == -1)
          {
!                 fprintf(stderr, "Can't remove "MOUNTED"~");
                  return 1;
          }
  
--- 182,190 ----
                  exit(1);
          }
  
!         if (unlink(MOUNTED_LOCK) == -1)
          {
!                 fprintf(stderr, "Can't remove "MOUNTED_LOCK);
                  return 1;
          }
  
diff -rcp samba-3.0.23c/source/client/umount.cifs.c samba-3.0.23c-new/source/client/umount.cifs.c
*** samba-3.0.23c/source/client/umount.cifs.c	Wed Apr 19 20:29:46 2006
--- samba-3.0.23c-new/source/client/umount.cifs.c	Tue Dec 19 10:14:03 2006
***************
*** 60,66 ****
  #endif
  
  #ifndef MOUNTED_LOCK
! #define MOUNTED_LOCK    "/etc/mtab~"
  #endif
  #ifndef MOUNTED_TEMP
  #define MOUNTED_TEMP    "/etc/mtab.tmp"
--- 60,66 ----
  #endif
  
  #ifndef MOUNTED_LOCK
! #define MOUNTED_LOCK "/var/lock/mtab~"
  #endif
  #ifndef MOUNTED_TEMP
  #define MOUNTED_TEMP    "/etc/mtab.tmp"
diff -rcp samba-3.0.23c/source/include/includes.h samba-3.0.23c-new/source/include/includes.h
*** samba-3.0.23c/source/include/includes.h	Wed Aug 23 10:16:38 2006
--- samba-3.0.23c-new/source/include/includes.h	Mon Dec 18 10:20:48 2006
*************** void exit_server(const char *const reaso
*** 1600,1603 ****
--- 1600,1607 ----
  void exit_server_cleanly(const char *const reason) NORETURN_ATTRIBUTE ;
  void exit_server_fault(void) NORETURN_ATTRIBUTE ;
  
+ #ifndef MOUNTED_LOCK
+ #define MOUNTED_LOCK "/var/lock/mtab~"
+ #endif
+ 
  #endif /* _INCLUDES_H */

--=-lPlhU2DyNwzYv2XdhzM2
Content-Disposition: attachment; filename=util-linux-mtablock.patch
Content-Type: text/x-patch; name=util-linux-mtablock.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

*** util-linux-2.13-pre6/mount/paths.h.ORIG	2006-12-14 11:57:11.000000000 -0700
--- util-linux-2.13-pre6/mount/paths.h	2006-12-14 11:58:18.000000000 -0700
***************
*** 1,10 ****
  #include <mntent.h>
  #define _PATH_FSTAB	"/etc/fstab"
  #ifdef _PATH_MOUNTED
- #define MOUNTED_LOCK	_PATH_MOUNTED "~"
  #define MOUNTED_TEMP	_PATH_MOUNTED ".tmp"
  #else
- #define MOUNTED_LOCK	"/etc/mtab~"
  #define MOUNTED_TEMP	"/etc/mtab.tmp"
  #endif
  #define LOCK_TIMEOUT	10
--- 1,9 ----
  #include <mntent.h>
  #define _PATH_FSTAB	"/etc/fstab"
+ #define MOUNTED_LOCK	"/var/lock/mtab~"
  #ifdef _PATH_MOUNTED
  #define MOUNTED_TEMP	_PATH_MOUNTED ".tmp"
  #else
  #define MOUNTED_TEMP	"/etc/mtab.tmp"
  #endif
  #define LOCK_TIMEOUT	10

--=-lPlhU2DyNwzYv2XdhzM2
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-lPlhU2DyNwzYv2XdhzM2
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-lPlhU2DyNwzYv2XdhzM2--
