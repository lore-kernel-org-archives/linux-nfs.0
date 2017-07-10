Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49287 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752317AbdGJHR5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 03:17:57 -0400
From: NeilBrown <neilb@suse.com>
To: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Date: Mon, 10 Jul 2017 17:17:27 +1000
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <595F1A3A.7070405@cs.uchicago.edu>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu> <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu>
Message-ID: <87efto69rs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 07 2017, Phil Kauffman wrote:

>> I can imagine /etc/mtab being read once for every line in /etc/exports,
>> but unless your /etc/exports is very big, I can't easily see why it
>> would be read 900 times.
>> Maybe lots of different mount points are being accessed by something and
>> each one triggers a few reads...
>>
>> Can you show your /etc/exports file?
>
> These get generated via puppet and dropped into /etc/exports.d/
...
>
> Here we can see that there are 960 files in /etc/exports.d
> root@storage1:~# find /etc/exports.d/ -type f | wc
> 960 960 88701

Ahhh.. 960 exports.  That could do it.

$ grep -c crossmnt all_etc_exports.d_in_one_file.txt
957

I get 957 - much the same number.

$ grep open redacted_strace.txt | uniq -c
      2 open("/var/lib/nfs/etab", O_RDONLY)     =3D 6
    942 open("/etc/mtab", O_RDONLY|O_CLOEXEC)   =3D 6
      1 open("/proc/net/rpc/nfsd.export/channel", O_WRONLY|O_CREAT|O_TRUNC,=
 0666) =3D 6

/etc/mtab was ready 942 for a single access.  I would have expected 957,
but maybe the system is dynamic and something changed between the two
samples.

This makes it fairly clear what is happening.  Now we just need to fix
it.
One option would be to cache some of the details extracted from
/etc/mtab, but that could get messy.

Another is to move the code around.  In your case there are really just
3 exports to each of 300+ clients (I assume "client.cs.uchicago.edu" in
the combined exports file is really different in different files).
So any one client only needs to consider 3 exports, not 300.

There is room to optimize this code further than the below, but let's
start simple.  Could you test with this patch applied and see what
difference it makes?

Thanks,
NeilBrown


diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ca6c84f4d93d..e712cc166157 100644
=2D-- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -727,6 +727,17 @@ static void nfsd_fh(int f)
 		for (exp =3D exportlist[i].p_head; exp; exp =3D next_exp) {
 			char *path;
=20
+			if (!is_ipaddr_client(dom)
+			    && !namelist_client_matches(exp, dom)) {
+				next_exp =3D exp->m_next;
+				continue;
+			}
+			if (is_ipaddr_client(dom)
+			    && !ipaddr_client_matches(exp, ai)) {
+				next_exp =3D exp->m_next;
+				continue;
+			}
+
 			if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT) {
 				static nfs_export *prev =3D NULL;
 				static void *mnt =3D NULL;
@@ -751,9 +762,6 @@ static void nfsd_fh(int f)
 				next_exp =3D exp->m_next;
 			}
=20
=2D			if (!is_ipaddr_client(dom)
=2D					&& !namelist_client_matches(exp, dom))
=2D				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
 					   exp->m_export.e_mountpoint:
@@ -762,9 +770,6 @@ static void nfsd_fh(int f)
=20
 			if (!match_fsid(&parsed, exp, path))
 				continue;
=2D			if (is_ipaddr_client(dom)
=2D					&& !ipaddr_client_matches(exp, ai))
=2D				continue;
 			if (!found || subexport(&exp->m_export, found)) {
 				found =3D &exp->m_export;
 				free(found_path);

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlljKgkACgkQOeye3VZi
gbmCHw//dsg6EJvXyQOYg4+uz2n+CB9NtAeLE3pnWAljhAnxcwAAmkDDXwWcliSi
8OfistmMEldu1rc5/98yIRQiBi1maE9+jpi0U+er3X7wgPImA4Yt6YOp4D2aG5Mr
FJdXjqagQqaNhgp/igAeafVrqOZVo29JUmwVi2uAHkqihl+UzS5LBIovvXrn9u5V
IPfd+lB0OPgsXhg1o0i6vzPIH247Jd6F/wD9tAlN78df5S2RFsSn4xcWUy2unE3S
xVhqbnqsFZ9kiMJMWhJu+I5zBgIvLiX1fKFcLuw9ojJMfcoHBst0CSmzmPp9lFYY
IevEL8XJKw0S5pZR04x/vSjm3YxIUMZGY6NAq+n1lzIp9CFiIWSKxfyu9m0dEJe1
rmsUxrKu/sQ7J971t4GqV/lq6JdyGZ96JtDD6CC6mSEDicenXuigM38CH/wslZyH
U6OscSq1mALOYJUZRbI1XXOoQEvpuZrvp+a0j1nO/oDy05hXGNcOiAj2FGG+/SUW
V0EFUIQ7mWPEztsc6qiKlmepbi4PAHxVPgLScBqoKhQP6ztkjWfp9N/XCDJzlIZc
nNrx0MyuZeH9gd0JVZlBDmREfKqbO6i8Dghrwc8z5O1ZTzrG3d9sVB2VYi6KXi88
dsxyDRBNvbuzqas6+yLBBSeH8kauy1s4vRQ6wv23BLR/qHUgvjo=
=Dl5W
-----END PGP SIGNATURE-----
--=-=-=--
