Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rrzmta1.uni-regensburg.de ([194.94.155.51]:59958 "EHLO
	rrzmta1.uni-regensburg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759026Ab3BMNKd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2013 08:10:33 -0500
Received: from rrzmta1.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 5B759B42
	for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2013 14:03:21 +0100 (CET)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta1.uni-regensburg.de (Postfix) with ESMTP id 8CD81A293
	for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2013 14:03:20 +0100 (CET)
Message-Id: <511B9D24020000A10000F0FC@gwsmtp1.uni-regensburg.de>
Date: Wed, 13 Feb 2013 14:03:16 +0100
From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
To: <linux-ha@lists.linux-ha.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: Antw: Re: [Linux-HA] Problem with exportfs
References: <510B7BCE020000A10000ECB5@gwsmtp1.uni-regensburg.de>
 <20130201075338.GA29620@walrus.homenet>
In-Reply-To: 
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__PartA999EE04.1__="
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__PartA999EE04.1__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi!

I've made a patch to let exportfs propagate the errors it reported to the =
exit code of the process (see attachments, the compressed tar is there in =
case the mailer corrupts the patche files):

The exportfs seems to have been written with a "hot needle", not having =
error processing in mind. So I have to change the prototypes of several =
routines. Also one routine returns 1 on success, and 0 of failure, which =
is against all C conventions. Anyway, I've tested my code a littel bit, =
and it looks promising:

# non-root calling exportfs
./exportfs; echo $?
exportfs: could not open /var/lib/nfs/.etab.lock for locking: errno 13 =
(Permission denied)
1
# Empty export list
# ./exportfs; echo $?
0
# ./exportfs no-such-host:/tmp; echo $?
exportfs: Failed to resolve no-such-host
1
# existing host and filesystem
rksapv04:/tmp # ./exportfs localhost:/tmp; echo $?
0
# non-existing filesystem or directory
# ./exportfs localhost:/no-such-file; echo $?
exportfs: Failed to stat /no-such-file: No such file or directory
exportfs: localhost:/no-such-file: No such file or directory
1
# both incorrect
# ./exportfs no-host:/no-file; echo $?
exportfs: Failed to resolve no-host
exportfs: localhost:/no-such-file: No such file or directory
1
# unfortunately the non-existing filesystem is still exported:
# ./exportfs ; echo $?
/tmp            localhost
/no-such-file   localhost
0
# At least it can be unexported
# ./exportfs -u localhost:/no-such-file; echo $?
0

So the patch is not perfect, but probably a good staring point. Please =
send feedback!

Regards,
Ulrich

>>> Ulrich Windl schrieb am 01.02.2013 um 09:47 in Nachricht <510B8119.CA2 =
: 161 :
60728>:
> >>> Dejan Muhamedagic <dejanmm@fastmail.fm> schrieb am 01.02.2013 um =
08:53 in
> Nachricht <20130201075338.GA29620@walrus.homenet>:
> > Hi,
> >=20
> > On Fri, Feb 01, 2013 at 08:24:46AM +0100, Ulrich Windl wrote:
> > > Hi!
> > >=20
> > > While trying to develop an improved exportfs RA that can export =
one=20
> > filesystem to a list of names (instead of just one name), I found an =
error:
> > >=20
> > > exportfs is returning exit code 0 even if the filesystem could not =
be=20
> > exported, like in
> > >=20
> > > > h02:~ # exportfs h012:/mnt; echo $? # h012 does not exist
> > > > exportfs: Failed to resolve h012=20
> > > > 0=20
> > >=20
> > > Accordingly the start operation for the exportfs alway reports =
success,=20
> > even if the operation failed! That's due to
> > >=20
> > > [...]
> > > >         ocf_run exportfs -v ${OPTIONS}=20
> > ${OCF_RESKEY_clientspec}:${OCF_RESKEY_directory} || exit $OCF_ERR_GENER=
IC =20
> >  =20
> > > >    =20
> > > >         # Restore the rmtab to ensure smooth NFS-over-TCP failover =
  =20
> > > >         restore_rmtab   =20
> > > >    =20
> > > >         ocf_log info "File system exported"   =20
> > > >         return $OCF_SUCCESS   =20
> > > [...]
> > >=20
> > > However the monitor operation does the correct thing, thus reporting =
an=20
> > error (rc=3D=3D7).
> >=20
> > We could insert the monitor operation after the call to exportfs.
> > Would there be any timing issues? I guess not.
> >=20
> > Thanks,
> >=20
> > Dejan
>=20
> Hi!
>=20
> I'd fix the root of the problem: exportfs is unreliable!
>=20
> Regards,
> Ulrich
>=20
>=20
>=20
> >=20
> > > This combination leads to the message of ocf-tester:
> > > * rc=3D1: Monitoring an active resource should return 0     =20
> > >=20
> > > (The tester thinks the resource was started when it was not)
> > >=20
> > > I had reported this for SLES10 SP2 to support in November, but after =
a long=20
> > time of waiting and repeating the same facts over and over, support =
told me=20
> > it's "working as designed"; lvscan and lvcreate would be similar.
> > >=20
> > > A quick test showed that this is actually not true vor lvcreate:
> > > # lvcreate -n bar -L40G foobar; echo $?
> > >   Volume group "foobar" not found
> > > 5
> > > # lvcreate -n foo -L1T sys; echo $?
> > >   Volume group "sys" has insufficient free space (1855 extents): =
32768=20
> > required.
> > > 5
> > >=20
> > > I got the impression that my support is just unwilling to fix the =
rather=20
> > trivial problem. My exportfs comes from nfs-kernel-server-1.2.3-18.23.1=
.
> > >=20
> > > Getting the exportfs sources, it took me two minutes to find out =
that=20
> > exportfs uses variable export_errno to define the exit code, and =
that=20
> > variable is nowhere set. The worker routine exportfs() does return =
nothing=20
> at=20
> > all. What a design!
> > >=20
> > > Here's an example from an old HP-UX system that didn't get any =
updates for=20
> > three years:
> > >=20
> > > # exportfs nohost:/mnt; echo $?
> > > exportfs: no entry for nohost:/mnt in /etc/dfs/dfstab
> > > 1
> > >=20
> > > Here it works!
> > >=20
> > > I wonder why some Linux people are so ignorant occasionally...
> > >=20
> > > Regards,
> > > Ulrich
> > >=20
> > >=20
> > > _______________________________________________
> > > Linux-HA mailing list
> > > Linux-HA@lists.linux-ha.org =20
> > > http://lists.linux-ha.org/mailman/listinfo/linux-ha =20
> > > See also: http://linux-ha.org/ReportingProblems =20
> > _______________________________________________
> > Linux-HA mailing list
> > Linux-HA@lists.linux-ha.org =20
> > http://lists.linux-ha.org/mailman/listinfo/linux-ha =20
> > See also: http://linux-ha.org/ReportingProblems =20
> >=20
>=20
> =20
> =20
>=20


=20

--=__PartA999EE04.1__=
Content-Type: application/x-gzip; name="nfs-utils-1.2.7-exit-patch.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="nfs-utils-1.2.7-exit-patch.tar.gz"

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
nABQAAA=

--=__PartA999EE04.1__=
Content-Type: text/plain; name="0001-Include-stdio.h-for-snprintf.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="0001-Include-stdio.h-for-snprintf.patch"

>From 11c4a0d45a06169f2de8bd220509f4569a5c37c2 Mon Sep 17 00:00:00 =
2001=0AFrom: Ulrich Windl <Ulrich.Windl@RZ.Uni-Regensburg.DE>=0ADate: Wed, =
13 Feb 2013 11:45:33 +0100=0ASubject: [PATCH 1/2] Include <stdio.h> for =
snprintf()=0A=0AInclude <stdio.h> to declare snprintf() in utils/nfsdcltrac=
k/sqlite.c.=0A---=0A utils/nfsdcltrack/sqlite.c | 1 +=0A 1 file changed, 1 =
insertion(+)=0A=0Adiff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltra=
ck/sqlite.c=0Aindex bac6789..f825873 100644=0A--- a/utils/nfsdcltrack/sqlit=
e.c=0A+++ b/utils/nfsdcltrack/sqlite.c=0A@@ -38,6 +38,7 @@=0A #include =
"config.h"=0A #endif /* HAVE_CONFIG_H */=0A =0A+#include <stdio.h>=0A =
#include <dirent.h>=0A #include <errno.h>=0A #include <event.h>=0A-- =
=0A1.7.12.4=0A=0A
--=__PartA999EE04.1__=
Content-Type: text/plain; name="0002-Let-exportfs-exit-with-error-on-errors.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="0002-Let-exportfs-exit-with-error-on-errors.patch"

>From eaaa966427e64b247f67a22df3ed87fe6dd61923 Mon Sep 17 00:00:00 =
2001=0AFrom: Ulrich Windl <Ulrich.Windl@RZ.Uni-Regensburg.DE>=0ADate: Wed, =
13 Feb 2013 13:24:54 +0100=0ASubject: [PATCH 2/2] Let exportfs exit with =
error on errors=0A=0Asupport/export/xtab.c:=0Axtab_read() and xtab_export_r=
ead() will return 0 on errors (strange logic,=0Abut according to existing =
code).=0A=0Asupport/include/nfslib.h, support/nfs/cacheio.c:=0Acache_flush(=
) will return 0 on success.=0A=0Autils/exportfs/exportfs.c:=0AChanged =
export_all(), exportfs(), unexportfs(), exports_update(),=0Avalidate_export=
(), grab_lockfile(), release_lockfile() to return 0 on=0Asuccess.  Added =
verbose_release_lockfile() to keep atexit() happy.=0AChanged main() to =
return 1 on failure of any of: cache_flush(),=0Axtab_export_read(), =
grab_lockfile(), export_all(), exportfs(),=0Aunexportfs(), exports_update()=
, xtab_export_write(), xtab_mount_write()=0AChanged exports_update_one() =
to return 0 on success, watching=0Aexport_export() and export_unexport() =
for errors.=0AChanged exports_update() to return 0 on success, watching=0Ae=
xports_update_one() for errors.=0AChanged export_all() to return 0 on =
success watching validate_export() for=0Aerrors.=0AChanged exportfs() to =
return 0 on success, watching updateexportent() and=0Avalidate_export() =
for errors.=0AChanged validate_export() to return 0 on success, watching =
test_export()=0Afor errors.=0A---=0A support/export/xtab.c     |   4 +-=0A =
support/include/nfslib.h  |   2 +-=0A support/nfs/cacheio.c     |   5 =
+-=0A utils/exportfs/exportfs.c | 173 ++++++++++++++++++++++++++++++-------=
---------=0A 4 files changed, 120 insertions(+), 64 deletions(-)=0A=0Adiff =
--git a/support/export/xtab.c b/support/export/xtab.c=0Aindex 2a43193..a87d=
453 100644=0A--- a/support/export/xtab.c=0A+++ b/support/export/xtab.c=0A@@=
 -24,6 +24,7 @@=0A int v4root_needed;=0A static void cond_rename(char =
*newfile, char *oldfile);=0A =0A+/* return 0 on failure! */=0A static =
int=0A xtab_read(char *xtab, char *lockfn, int is_export)=0A {=0A@@ -63,7 =
+64,7 @@ xtab_read(char *xtab, char *lockfn, int is_export)=0A 	endexporten=
t();=0A 	xfunlock(lockid);=0A =0A-	return 0;=0A+	return =
1;=0A }=0A =0A int=0A@@ -93,6 +94,7 @@ xtab_export_read(void)=0A  * inode =
number changes when the xtab_export_write is done. If you change the=0A  * =
routine below such that the files are edited in place, then you'll need =
to=0A  * fix the auth_reload logic as well...=0A+ * Return 0 on failure!=0A=
  */=0A static int=0A xtab_write(char *xtab, char *xtabtmp, char *lockfn, =
int is_export)=0Adiff --git a/support/include/nfslib.h b/support/include/nf=
slib.h=0Aindex f210a06..ee45f56 100644=0A--- a/support/include/nfslib.h=0A+=
++ b/support/include/nfslib.h=0A@@ -155,7 +155,7 @@ int qword_eol(FILE =
*f);=0A int readline(int fd, char **buf, int *lenp);=0A int qword_get(char =
**bpp, char *dest, int bufsize);=0A int qword_get_int(char **bpp, int =
*anint);=0A-void cache_flush(int force);=0A+int cache_flush(int force);=0A =
int check_new_cache(void);=0A void qword_add(char **bpp, int *lp, char =
*str);=0A void qword_addhex(char **bpp, int *lp, char *buf, int blen);=0Adi=
ff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c=0Aindex e641c45..7=
ffca97 100644=0A--- a/support/nfs/cacheio.c=0A+++ b/support/nfs/cacheio.c=
=0A@@ -321,7 +321,7 @@ check_new_cache(void)=0A  *  auth.unix.ip nfsd.expor=
t nfsd.fh=0A  */=0A =0A-void=0A+int=0A cache_flush(int force)=0A {=0A 	=
struct stat stb;=0A@@ -329,6 +329,7 @@ cache_flush(int force)=0A 	=
char stime[20];=0A 	char path[200];=0A 	time_t now;=0A+	int result =
=3D 0;=0A 	/* Note: the order of these caches is important.=0A 	 * =
They need to be flushed in dependancy order. So=0A 	 * a cache that =
references items in another cache,=0A@@ -357,8 +358,10 @@ cache_flush(int =
force)=0A 			if (write(fd, stime, strlen(stime)) !=3D =
(ssize_t)strlen(stime)) {=0A 				xlog_warn("Writing =
to '%s' failed: errno %d (%s)",=0A 				path, =
errno, strerror(errno));=0A+				result =3D 1;=0A 	=
		}=0A 			close(fd);=0A 		}=0A 	=
}=0A+	return result;=0A }=0Adiff --git a/utils/exportfs/exportfs.c =
b/utils/exportfs/exportfs.c=0Aindex 9f79541..27ac8c3 100644=0A--- =
a/utils/exportfs/exportfs.c=0A+++ b/utils/exportfs/exportfs.c=0A@@ -34,18 =
+34,19 @@=0A #include "exportfs.h"=0A #include "xlog.h"=0A =0A-static void	=
export_all(int verbose);=0A-static void	exportfs(char *arg, char *options, =
int verbose);=0A-static void	unexportfs(char *arg, int verbose);=0A-stat=
ic void	exports_update(int verbose);=0A+static int	export_all(int =
verbose);=0A+static int	exportfs(char *arg, char *options, int verbose);=0A=
+static int	unexportfs(char *arg, int verbose);=0A+static int	=
exports_update(int verbose);=0A static void	dump(int verbose);=0A =
static void	error(nfs_export *exp, int err);=0A static void	usage(const=
 char *progname, int n);=0A-static void	validate_export(nfs_export =
*exp);=0A+static int	validate_export(nfs_export *exp);=0A static int	=
matchhostname(const char *hostname1, const char *hostname2);=0A static =
void	export_d_read(const char *dname);=0A-static void grab_lockfile(void=
);=0A-static void release_lockfile(void);=0A+static int	grab_lockfile(void)=
;=0A+static int	release_lockfile(void);=0A+static void	verbose_release_loc=
kfile(void);=0A =0A static const char *lockfile =3D EXP_LOCKFILE;=0A =
static int _lockfd =3D -1;=0A@@ -66,18 +67,28 @@ static int _lockfd =3D =
-1;=0A  * corrupting etab, but to prevent problems like the above we=0A  * =
need these additional lockfile() routines.=0A  */=0A-static void =0A+static=
 int=0A grab_lockfile()=0A {=0A 	_lockfd =3D open(lockfile, =
O_CREAT|O_RDWR, 0666);=0A-	if (_lockfd !=3D -1) =0A-		=
lockf(_lockfd, F_LOCK, 0);=0A+	if (_lockfd !=3D -1 && lockf(_lockfd, =
F_LOCK, 0) =3D=3D 0)=0A+		return 0;=0A+	return 1;=0A =
}=0A-static void =0A+=0A+static int=0A release_lockfile()=0A {=0A-	if =
(_lockfd !=3D -1)=0A-		lockf(_lockfd, F_ULOCK, 0);=0A+	if =
(_lockfd !=3D -1 && lockf(_lockfd, F_ULOCK, 0) =3D=3D 0)=0A+		=
return 0;=0A+	return 1;=0A+}=0A+=0A+static void=0A+verbose_release_lockfi=
le()=0A+{=0A+	if (release_lockfile())=0A+		xlog(L_ERROR, =
"problem releasing lockfile %s: %m", lockfile);=0A }=0A =0A int=0A@@ =
-153,38 +164,44 @@ main(int argc, char **argv)=0A 	new_cache =3D =
check_new_cache();=0A 	if (optind =3D=3D argc && ! f_all) {=0A 		=
if (force_flush) {=0A-			if (new_cache)=0A-			=
	cache_flush(1);=0A-			else {=0A+			=
if (new_cache) {=0A+				if (cache_flush(1))=0A+		=
			export_errno =3D 1;=0A+			} else =
{=0A 				xlog(L_ERROR, "-f is available only "=0A 	=
				"with new cache controls. "=0A 			=
		"Mount /proc/fs/nfsd first");=0A 				=
return 1;=0A 			}=0A-			return 0;=0A+		=
	return export_errno;=0A 		} else {=0A-			=
xtab_export_read();=0A+			if (xtab_export_read() =3D=3D =
0)=0A+				export_errno =3D 1;=0A 			=
dump(f_verbose);=0A-			return 0;=0A+			=
return export_errno;=0A 		}=0A 	}=0A =0A 	/*=0A 	 * =
Serialize things as best we can=0A 	 */=0A-	grab_lockfile();=0A-	=
atexit(release_lockfile);=0A+	if (grab_lockfile())=0A+		=
export_errno =3D 1;=0A+	atexit(verbose_release_lockfile);=0A =0A 	if =
(f_export && ! f_ignore) {=0A 		export_read(_PATH_EXPORTS);=0A 		=
export_d_read(_PATH_EXPORTS_D);=0A 	}=0A 	if (f_export) {=0A-		=
if (f_all)=0A-			export_all(f_verbose);=0A-		=
else=0A-			for (i =3D optind; i < argc ; i++)=0A-		=
		exportfs(argv[i], options, f_verbose);=0A+		if =
(f_all) {=0A+			if (export_all(f_verbose))=0A+			=
	export_errno =3D 1;=0A+		} else=0A+			=
for (i =3D optind; i < argc ; i++) {=0A+				if =
(exportfs(argv[i], options, f_verbose))=0A+					=
export_errno =3D 1;=0A+			}=0A 	}=0A 	/* If we are =
unexporting everything, then=0A 	 * don't care about what should be =
exported, as that=0A@@ -194,30 +211,41 @@ main(int argc, char **argv)=0A 	=
	/* note: xtab_*_read does not update entries if they already =
exist,=0A 		 * so this will not lose new options=0A 		=
 */=0A-		if (!f_reexport)=0A-			xtab_export_read();=
=0A+		if (!f_reexport) {=0A+			if (xtab_export_rea=
d() =3D=3D 0)=0A+				export_errno =3D 1;=0A+		=
}=0A 		if (!f_export)=0A-			for (i =3D optind =
; i < argc ; i++)=0A-				unexportfs(argv[i], =
f_verbose);=0A+			for (i =3D optind ; i < argc ; i++) {=0A+	=
			if (unexportfs(argv[i], f_verbose))=0A+			=
		export_errno =3D 1;=0A+			}=0A 		if =
(!new_cache)=0A 			rmtab_read();=0A 	}=0A 	if =
(!new_cache) {=0A 		xtab_mount_read();=0A-		exports_upd=
ate(f_verbose);=0A+		if (exports_update(f_verbose))=0A+		=
	export_errno =3D 1;=0A+	}=0A+	if (!xtab_export_write())=0A+		=
export_errno =3D 1;=0A+	if (new_cache) {=0A+		if (cache_flush(for=
ce_flush))=0A+			export_errno =3D 1;=0A 	}=0A-	xtab_export=
_write();=0A-	if (new_cache)=0A-		cache_flush(force_flush);=
=0A 	if (!new_cache)=0A-		xtab_mount_write();=0A+		if =
(!xtab_mount_write())=0A+			export_errno =3D 1;=0A =0A =
	return export_errno;=0A }=0A =0A-static void=0A+static int=0A =
exports_update_one(nfs_export *exp, int verbose)=0A {=0A+	int	=
result =3D 0;=0A+=0A 		/* check mountpoint option */=0A 	if =
(exp->m_mayexport &&=0A 	    exp->m_export.e_mountpoint &&=0A@@ =
-227,6 +255,7 @@ exports_update_one(nfs_export *exp, int verbose)=0A 		=
printf("%s not exported as %s not a mountpoint.\n",=0A 		       =
exp->m_export.e_path, exp->m_export.e_mountpoint);=0A 		exp->m_maye=
xport =3D 0;=0A+		result =3D 1;=0A 	}=0A 	if =
(exp->m_mayexport && ((exp->m_exported<1) || exp->m_changed)) {=0A 		=
if (verbose)=0A@@ -234,17 +263,22 @@ exports_update_one(nfs_export *exp, =
int verbose)=0A 			       exp->m_exported ?"re":"",=0A=
 			       exp->m_client->m_hostname,=0A 			=
       exp->m_export.e_path);=0A-		if (!export_export(exp))=0A=
+		if (!export_export(exp)) {=0A 			error(exp, =
errno);=0A+			result =3D 1;=0A+		}=0A 	=
}=0A 	if (exp->m_exported && ! exp->m_mayexport) {=0A 		if =
(verbose)=0A 			printf("unexporting %s:%s from kernel\n",=
=0A 			       exp->m_client->m_hostname,=0A 			=
       exp->m_export.e_path);=0A-		if (!export_unexport(exp))=
=0A+		if (!export_unexport(exp)) {=0A 			=
error(exp, errno);=0A+			result =3D 1;=0A+		=
}=0A 	}=0A+	return result;=0A }=0A =0A =0A@@ -253,28 +287,33 @@ =
exports_update_one(nfs_export *exp, int verbose)=0A  * entries with =
m_exported but not m_mayexport get unexported=0A  * looking at m_client->m_=
type =3D=3D MCL_FQDN and m_client->m_type =3D=3D MCL_GSS only=0A  =
*/=0A-static void=0A+static int=0A exports_update(int verbose)=0A {=0A 	=
nfs_export 	*exp;=0A+	int		result =3D 0;=0A =0A 	=
for (exp =3D exportlist[MCL_FQDN].p_head; exp; exp=3Dexp->m_next) {=0A-		=
exports_update_one(exp, verbose);=0A+		if (exports_update_one(exp,=
 verbose))=0A+			result =3D 1;=0A 	}=0A 	for (exp =
=3D exportlist[MCL_GSS].p_head; exp; exp=3Dexp->m_next) {=0A-		=
exports_update_one(exp, verbose);=0A+		if (exports_update_one(exp,=
 verbose))=0A+			result =3D 1;=0A 	}=0A+	return =
result;=0A }=0A 			=0A /*=0A- * export_all finds all =
entries and=0A- *    marks them xtabent and mayexport so that they get =
exported=0A+ * export_all finds all entries and marks them xtabent and =
mayexport so that=0A+ * they get exported. Return 0 if thewre were no =
errors.=0A  */=0A-static void=0A+static int=0A export_all(int verbose)=0A =
{=0A 	nfs_export	*exp;=0A 	int		i;=0A+	int		=
result =3D 0;=0A =0A 	for (i =3D 0; i < MCL_MAXTYPES; i++) {=0A 		=
for (exp =3D exportlist[i].p_head; exp; exp =3D exp->m_next) {=0A@@ =
-286,13 +325,15 @@ export_all(int verbose)=0A 			exp->m_maye=
xport =3D 1;=0A 			exp->m_changed =3D 1;=0A 		=
	exp->m_warned =3D 0;=0A-			validate_export(exp=
);=0A+			if (validate_export(exp))=0A+				=
result =3D 1;=0A 		}=0A 	}=0A+	return result;=0A }=0A =
=0A-=0A-static void=0A+/* return 0 on success */=0A+static int=0A =
exportfs(char *arg, char *options, int verbose)=0A {=0A 	struct =
exportent *eep;=0A@@ -301,13 +342,14 @@ exportfs(char *arg, char *options, =
int verbose)=0A 	char		*path;=0A 	char		=
*hname =3D arg;=0A 	int		htype;=0A+	int		=
result =3D 0;=0A =0A 	if ((path =3D strchr(arg, ':')) !=3D NULL)=0A 		=
*path++ =3D '\0';=0A =0A 	if (!path || *path !=3D '/') {=0A 		=
xlog(L_ERROR, "Invalid exporting option: %s", arg);=0A-		return;=0A+=
		return 1;=0A 	}=0A =0A 	if ((htype =3D client_getty=
pe(hname)) =3D=3D MCL_FQDN) {=0A@@ -321,10 +363,14 @@ exportfs(char *arg, =
char *options, int verbose)=0A =0A 	if (!exp) {=0A 		if (!(eep =
=3D mkexportent(hname, path, options)) ||=0A-		    !(exp =3D =
export_create(eep, 0)))=0A+		    !(exp =3D export_create(eep, =
0))) {=0A+			result =3D 1;=0A 			=
goto out;=0A-	} else if (!updateexportent(&exp->m_export, options))=0A+	=
	}=0A+	} else if (!updateexportent(&exp->m_export, options)) =
{=0A+		result =3D 1;=0A 		goto out;=0A+	}=0A =0A 	=
if (verbose)=0A 		printf("exporting %s:%s\n", exp->m_client->=
m_hostname, =0A@@ -333,13 +379,15 @@ exportfs(char *arg, char *options, =
int verbose)=0A 	exp->m_mayexport =3D 1;=0A 	exp->m_changed =3D =
1;=0A 	exp->m_warned =3D 0;=0A-	validate_export(exp);=0A+	=
result =3D validate_export(exp);=0A =0A out:=0A 	freeaddrinfo(ai);=
=0A+	return result;=0A }=0A =0A-static void=0A+/* return 0 on success =
*/=0A+static int=0A unexportfs(char *arg, int verbose)=0A {=0A 	nfs_export	=
*exp;=0A@@ -347,13 +395,14 @@ unexportfs(char *arg, int verbose)=0A 	=
char		*path;=0A 	char		*hname =3D arg;=0A 	=
int		htype;=0A+	int		result =3D 0;=0A =0A 	if =
((path =3D strchr(arg, ':')) !=3D NULL)=0A 		*path++ =3D =
'\0';=0A =0A 	if (!path || *path !=3D '/') {=0A 		xlog(L_ERRO=
R, "Invalid unexporting option: %s", arg);=0A-		return;=0A+		=
return 1;=0A 	}=0A =0A 	if ((htype =3D client_gettype(hname)) =
=3D=3D MCL_FQDN) {=0A@@ -396,6 +445,7 @@ unexportfs(char *arg, int =
verbose)=0A 	}=0A =0A 	freeaddrinfo(ai);=0A+	return result;=0A =
}=0A =0A static int can_test(void)=0A@@ -433,10 +483,11 @@ static int =
test_export(char *path, int with_fsid)=0A 	return 1;=0A }=0A =
=0A-static void=0A+static int=0A validate_export(nfs_export *exp)=0A {=0A-	=
/* Check that the given export point is potentially exportable.=0A+	/* =
Check that the given export point is potentially exportable,=0A+	 * =
returning 0 on success.=0A 	 * We just give warnings here, don't cause =
anything to fail.=0A 	 * If a path doesn't exist, or is not a dir or =
file, give an warning=0A 	 * otherwise trial-export to '-test-client-=
' and check for failure.=0A@@ -448,15 +499,15 @@ validate_export(nfs_export=
 *exp)=0A =0A 	if (stat(path, &stb) < 0) {=0A 		xlog(L_ERROR, =
"Failed to stat %s: %m", path);=0A-		return;=0A+		=
return 1;=0A 	}=0A 	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode))=
 {=0A 		xlog(L_ERROR, "%s is neither a directory nor a file. "=0A 	=
		"Remote access will fail", path);=0A-		return;=0A+=
		return 1;=0A 	}=0A 	if (!can_test())=0A-		=
return;=0A+		return 1;=0A =0A 	if (!statfs64(path, &stf) =
&&=0A 	    (stf.f_fsid.__val[0] || stf.f_fsid.__val[1]))=0A@@ -466,16 =
+517,16 @@ validate_export(nfs_export *exp)=0A 	    fs_has_fsid) {=0A 		=
if ( !test_export(path, 1)) {=0A 			xlog(L_ERROR, "%s =
does not support NFS export", path);=0A-			return;=0A+=
			return 1;=0A 		}=0A 	} else if ( ! =
test_export(path, 0)) {=0A 		if (test_export(path, 1))=0A 		=
	xlog(L_ERROR, "%s requires fsid=3D for NFS export", path);=0A 		=
else=0A 			xlog(L_ERROR, "%s does not support NFS =
export", path);=0A-		return;=0A-=0A+		return 1;=0A 	=
}=0A+	return 0;=0A }=0A =0A static _Bool=0A-- =0A1.7.12.4=0A=0A
--=__PartA999EE04.1__=--
