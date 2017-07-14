Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40512 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751166AbdGNGvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 02:51:47 -0400
From: NeilBrown <neilb@suse.com>
To: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Date: Fri, 14 Jul 2017 16:51:36 +1000
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <9e16d6c3-a675-b53e-c6f3-dfa9cdf1d5c9@cs.uchicago.edu>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu> <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu> <87efto69rs.fsf@notabene.neil.brown.name> <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu> <87y3rv4zrb.fsf@notabene.neil.brown.name> <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu> <87bmoq4h41.fsf@notabene.neil.brown.name> <9e16d6c3-a675-b53e-c6f3-dfa9cdf1d5c9@cs.uchicago.edu>
Message-ID: <871spj1pfr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 12 2017, Phil Kauffman wrote:

> On 07/11/2017 07:46 PM, NeilBrown wrote:
>> So the new data shows about 7 seconds for a login, which is probably
>> a little longer than you would like, but might be acceptable?
> Unfortunately, the delay is not acceptable.
>
> The ideal would be to achieve performance parity with when one is not=20
> forced to use the 'crossmnt' option.
>
> My current setup (home directory server) does not require 'crossmnt' and=
=20
> does not incur a delay. It is a standard nfs server using mdadm, lvm,=20
> and xfs.
>
> While my current setup is probably "normal" and using nested datasets=20
> with the 'crossmnt' option might be "weird" now; nested mounts will=20
> probably only become more common as BTRFS, ZFS, and other filesystems=20
> with similar features gain traction on linux.
>
>
>> That is more than a 2-line patch.  I might have a go later this week.
> That would be super! Thanks for taking a look.

Please try this (against a clean nfs-utils.  i.e. remove the previous
patch).
It is a hack and would need to be totally re-written, but hopely the
measurements you make and strace that you report could be useful.
Also, for the strace, please use "-ttt" rather than "-tt" like I asked
before.  It is easier to find the difference between two times with
=2Dttt.
And add -T as well.

Thanks,
NeilBrown


From=20f15571d747bb6272ec539e46b6b3aee3ccc53b30 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.com>
Date: Fri, 14 Jul 2017 16:43:37 +1000
Subject: [PATCH] testing

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/mountd/cache.c | 105 +++++++++++++++++++++++++++++++++++++++--------=
----
 1 file changed, 81 insertions(+), 24 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ca6c84f4d93d..db89a4feb7ae 100644
=2D-- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -18,6 +18,7 @@
 #include <time.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
+#include <sys/sysmacros.h>
 #include <unistd.h>
 #include <fcntl.h>
 #include <errno.h>
@@ -299,7 +300,7 @@ static const long int nonblkid_filesystems[] =3D {
     0        /* last */
 };
=20
=2Dstatic int uuid_by_path(char *path, int type, size_t uuidlen, char *uuid)
+static int uuid_by_path(char *path, struct statfs64 *stp, int type, size_t=
 uuidlen, char *uuid)
 {
 	/* get a uuid for the filesystem found at 'path'.
 	 * There are several possible ways of generating the
@@ -334,12 +335,17 @@ static int uuid_by_path(char *path, int type, size_t =
uuidlen, char *uuid)
 	const char *val;
 	int rc;
=20
=2D	rc =3D statfs64(path, &st);
+	if (stp)
+		rc =3D 0;
+	else {
+		stp =3D &st;
+		rc=3D statfs64(path, stp);
+	}
=20
 	if (type =3D=3D 0 && rc =3D=3D 0) {
 		const long int *bad;
 		for (bad =3D nonblkid_filesystems; *bad; bad++) {
=2D			if (*bad =3D=3D st.f_type)
+			if (*bad =3D=3D stp->f_type)
 				break;
 		}
 		if (*bad =3D=3D 0)
@@ -347,9 +353,9 @@ static int uuid_by_path(char *path, int type, size_t uu=
idlen, char *uuid)
 	}
=20
 	if (rc =3D=3D 0 &&
=2D	    (st.f_fsid.__val[0] || st.f_fsid.__val[1]))
+	    (stp->f_fsid.__val[0] || stp->f_fsid.__val[1]))
 		snprintf(fsid_val, 17, "%08x%08x",
=2D			 st.f_fsid.__val[0], st.f_fsid.__val[1]);
+			 stp->f_fsid.__val[0], stp->f_fsid.__val[1]);
 	else
 		fsid_val[0] =3D 0;
=20
@@ -603,25 +609,64 @@ static int parse_fsid(int fsidtype, int fsidlen, char=
 *fsid,
 	return 0;
 }
=20
+#define entry FOO
+#include <search.h>
+struct pinfo {
+	unsigned int stb:1, mntp:1, stfs:1;
+	unsigned int mountpoint:1;
+	time_t valid;
+	struct stat statbuf;
+	struct statfs64 statfsbuf;
+};
+static struct hsearch_data hdata;
+static int hdata_init =3D 0;
+
+
 static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *=
path)
 {
=2D	struct stat stb;
+	struct stat *stb;
 	int type;
 	char u[16];
+	struct pinfo *pi;
+	ENTRY ent, *ret;
=20
=2D	if (stat(path, &stb) !=3D 0)
=2D		return false;
=2D	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode))
+	if (!hdata_init) {
+		hcreate_r(1000, &hdata);
+		hdata_init =3D 1;
+	}
+	ent.key =3D path;
+	if (hsearch_r(ent, FIND, &ret, &hdata) =3D=3D 0) {
+		ent.key =3D strdup(path);
+		pi =3D xmalloc(sizeof(*pi));
+		pi->stb =3D pi->mntp =3D pi->stfs =3D 0;
+		pi->valid =3D 0;
+		ent.data =3D pi;
+		hsearch_r(ent, ENTER, &ret, &hdata);
+	} else
+		pi =3D ret->data;
+
+	if (pi->valid < time(NULL)+120) {
+		pi->stb =3D pi->mntp =3D pi->stfs =3D 0;
+		pi->valid =3D time(NULL);
+	}
+
+	stb =3D &pi->statbuf;
+	if (!pi->stb) {
+		if (stat(path, stb) !=3D 0)
+			return false;
+		pi->stb =3D 1;
+	}
+	if (!S_ISDIR(stb->st_mode) && !S_ISREG(stb->st_mode))
 		return false;
=20
 	switch (parsed->fsidtype) {
 	case FSID_DEV:
 	case FSID_MAJOR_MINOR:
 	case FSID_ENCODE_DEV:
=2D		if (stb.st_ino !=3D parsed->inode)
+		if (stb->st_ino !=3D parsed->inode)
 			return false;
=2D		if (parsed->major !=3D major(stb.st_dev) ||
=2D		    parsed->minor !=3D minor(stb.st_dev))
+		if (parsed->major !=3D major(stb->st_dev) ||
+		    parsed->minor !=3D minor(stb->st_dev))
 			return false;
 		return true;
 	case FSID_NUM:
@@ -631,12 +676,16 @@ static bool match_fsid(struct parsed_fsid *parsed, nf=
s_export *exp, char *path)
 		return true;
 	case FSID_UUID4_INUM:
 	case FSID_UUID16_INUM:
=2D		if (stb.st_ino !=3D parsed->inode)
+		if (stb->st_ino !=3D parsed->inode)
 			return false;
 		goto check_uuid;
 	case FSID_UUID8:
 	case FSID_UUID16:
=2D		if (!is_mountpoint(path))
+		if (!pi->mntp) {
+			pi->mountpoint =3D is_mountpoint(path);
+			pi->mntp =3D 1;
+		}
+		if (!pi->mountpoint)
 			return false;
 	check_uuid:
 		if (exp->m_export.e_uuid) {
@@ -644,12 +693,18 @@ static bool match_fsid(struct parsed_fsid *parsed, nf=
s_export *exp, char *path)
 			if (memcmp(u, parsed->fhuuid, parsed->uuidlen) =3D=3D 0)
 				return true;
 		}
=2D		else
+		else {
+			if (!pi->stfs) {
+				if (statfs64(path, &pi->statfsbuf) !=3D 0)
+					return false;
+				pi->stfs =3D 1;
+			}
 			for (type =3D 0;
=2D			     uuid_by_path(path, type, parsed->uuidlen, u);
+			     uuid_by_path(path, &pi->statfsbuf, type, parsed->uuidlen, u);
 			     type++)
 				if (memcmp(u, parsed->fhuuid, parsed->uuidlen) =3D=3D 0)
 					return true;
+		}
 	}
 	/* Well, unreachable, actually: */
 	return false;
@@ -727,10 +782,18 @@ static void nfsd_fh(int f)
 		for (exp =3D exportlist[i].p_head; exp; exp =3D next_exp) {
 			char *path;
=20
+			if (!is_ipaddr_client(dom)) {
+				if (!namelist_client_matches(exp, dom))
+					continue;
+			} else {
+				if (!ipaddr_client_matches(exp, ai))
+					continue;
+			}
+
 			if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT) {
 				static nfs_export *prev =3D NULL;
 				static void *mnt =3D NULL;
=2D=09=09=09=09
+
 				if (prev =3D=3D exp) {
 					/* try a submount */
 					path =3D next_mnt(&mnt, exp->m_export.e_path);
@@ -751,9 +814,6 @@ static void nfsd_fh(int f)
 				next_exp =3D exp->m_next;
 			}
=20
=2D			if (!is_ipaddr_client(dom)
=2D					&& !namelist_client_matches(exp, dom))
=2D				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
 					   exp->m_export.e_mountpoint:
@@ -762,9 +822,6 @@ static void nfsd_fh(int f)
=20
 			if (!match_fsid(&parsed, exp, path))
 				continue;
=2D			if (is_ipaddr_client(dom)
=2D					&& !ipaddr_client_matches(exp, ai))
=2D				continue;
 			if (!found || subexport(&exp->m_export, found)) {
 				found =3D &exp->m_export;
 				free(found_path);
@@ -906,7 +963,7 @@ static int dump_to_cache(int f, char *buf, int buflen, =
char *domain,
 		write_secinfo(&bp, &blen, exp, flag_mask);
 		if (exp->e_uuid =3D=3D NULL || different_fs) {
 			char u[16];
=2D			if (uuid_by_path(path, 0, 16, u)) {
+			if (uuid_by_path(path, NULL, 0, 16, u)) {
 				qword_add(&bp, &blen, "uuid");
 				qword_addhex(&bp, &blen, u, 16);
 			}
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlloafoACgkQOeye3VZi
gbnL9Q//fDCXmmPzAtrYs1nm8/Oegk1NzJi2xBRccWe/1JfRyhv7sE4LMkamOooI
qqz5mppFnYPZnXZCm08vzK9HYro6zAGsXr7YYJfKG+DoXebrNvMYQ+vThsRqYr2h
fmDprYy02YVcS92XdwjK46PQKLKY/WVm1UgbGzowk/uQR07WWKFgLAZoT/+sgvQO
yFnuTGRwfjAV4FCrZk5Tdpwwv5pAYsJvtAdiENc17Oe4oDilAI+iX1Nvy3+EY/Oo
22SRPw72JRYsnP62WZ08XgD+NjXBJv2DbW4Xg9bXj9Kme5muKB5hI8iBrXy4l7z8
EFWIYJhxRv6iRdrUhExBYVetDxaAd3yJteLjlyuNzAMheUA04RiQJmnlZ0V/LCsD
uo4UhWv6V7cg6/7csyOajMAbZghqgYO7BIG0Tk/5e7gSUB4gfzZdQMyz/MAynLtn
tCPSQE6tC9Mieadk0wJYyBzeHW6ZxyAizGkWXCOZuwoGQvEPLHTBYs8IlCZ2zi+w
c/tlm+giQfJ82sxGE0hqqeHvmA7FZDp2F6Q2UcQBjQ3FElbmODDWqwu1fvVrSfLu
WH/KkKiZTkHFV0Mq3VSlySAXYyfUnmAQ3l/gQydgOdP96rLHFFxNdEjw3IltA3LW
xvcEYhINV+RrRfSmkLGmIcRJfD17yjHSJAL1b9/ApFlJfxkWe9Q=
=gDj7
-----END PGP SIGNATURE-----
--=-=-=--
