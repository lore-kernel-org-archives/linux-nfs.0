Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48670 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725899AbeHQBvR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Aug 2018 21:51:17 -0400
From: NeilBrown <neilb@suse.com>
To: Bruce Fields <bfields@fieldses.org>
Date: Fri, 17 Aug 2018 08:50:10 +1000
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
In-Reply-To: <20180816175452.GA4649@fieldses.org>
References: <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com> <874lg3roua.fsf@notabene.neil.brown.name> <20180810170027.GF7906@fieldses.org> <20180810170312.GG7906@fieldses.org> <87d0uor11r.fsf@notabene.neil.brown.name> <20180812132100.GL7906@fieldses.org> <878t5bqgx0.fsf@notabene.neil.brown.name> <87ftzhb9rh.fsf@notabene.neil.brown.name> <20180814194334.GO7906@fieldses.org> <87r2iz9mbc.fsf@notabene.neil.brown.name> <20180816175452.GA4649@fieldses.org>
Message-ID: <87lg96rknx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 16 2018, Bruce Fields wrote:

> On Thu, Aug 16, 2018 at 10:39:35AM +1000, NeilBrown wrote:
>> On Tue, Aug 14 2018, Bruce Fields wrote:
>> > Honestly I'm not completely sure I understand the proposal.
>>=20
>> Ok, here is a concrete RFC proposal which should make it easier to
>> understand.
>> I've tested that this fixes the specific problem in that a user with a
>> uid that doesn't match the file, but which the server will give
>> ownership rights to, can now setacl a file.
>
> Thanks, this makes sense to me.
>
> I might try to split this change into a couple steps, but I'm not sure
> exactly how.

I was originally thinking for keeping the nfsd change in a separate
patch, but it was so tiny...


>
> Minor nits:

All nits addressed - thanks.
>> @@ -2038,12 +2038,13 @@ nfsd_permission(struct svc_rqst *rqstp, struct s=
vc_export *exp,
>>  	 * We must trust the client to do permission checking - using "ACCESS"
>>  	 * with NFSv3.
>>  	 */
>> -	if ((acc & NFSD_MAY_OWNER_OVERRIDE) &&
>> -	    uid_eq(inode->i_uid, current_fsuid()))
>> -		return 0;
>>=20=20
>>  	/* This assumes  NFSD_MAY_{READ,WRITE,EXEC} =3D=3D MAY_{READ,WRITE,EXE=
C} */
>
> Can we do the same for NFSD_MAY_OWNER_OVERRIDE and drop the extra "if"
> statement?

Probably.  If we apply this change first, then it should be trivial.
It would be a bit nicer if we could use enum for bits (a bit like "go"
allows), but I don't think this is too bad.  Thoughts?
(Do we really need NFSD_MAY_MASK ???)

Thanks,
NeilBrown

diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a7e107309f76..6ca707511f65 100644
=2D-- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -13,13 +13,14 @@
  * Flags for nfsd_permission
  */
 #define NFSD_MAY_NOP			0
=2D#define NFSD_MAY_EXEC			0x001 /* =3D=3D MAY_EXEC */
=2D#define NFSD_MAY_WRITE			0x002 /* =3D=3D MAY_WRITE */
=2D#define NFSD_MAY_READ			0x004 /* =3D=3D MAY_READ */
=2D#define NFSD_MAY_SATTR			0x008
=2D#define NFSD_MAY_TRUNC			0x010
=2D#define NFSD_MAY_LOCK			0x020
=2D#define NFSD_MAY_MASK			0x03f
+#define NFSD_MAY_EXEC			MAY_EXEC
+#define NFSD_MAY_WRITE			MAY_WRITE
+#define NFSD_MAY_READ			MAY_READ
+#define NFSD_MAY_SATTR			(__MAY_UNUSED << 0)
+#define NFSD_MAY_TRUNC			(__MAY_UNUSED << 1)
+#define NFSD_MAY_LOCK			(__MAY_UNUSED << 2)
+#define __NFSD_MAY_UNUSED		(__MAY_UNUSED << 3)
+#define NFSD_MAY_MASK			(__NFSD_MAY_UNUSED - 1)
=20
 /* extra hints to permission and open routines: */
 #define NFSD_MAY_OWNER_OVERRIDE		0x040
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1ec33fd0423f..aed6a65f06b8 100644
=2D-- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -93,6 +93,8 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t off=
set,
 /* called from RCU mode, don't block */
 #define MAY_NOT_BLOCK		0x00000080
=20
+#define	__MAY_UNUSED		0x00000100
+
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must corres=
pond
  * to O_WRONLY and O_RDWR via the strange trick in do_dentry_open()

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlt1/6IACgkQOeye3VZi
gbkYeA/8CTihSRTl64th7QsvXWMBQVgHamTNh48yIF4/O3RDxVO351VbYjVvSFIG
89Hxc02Ss9HAK6YA8Y1moO3GGHZXsSOXX0vnYI6L8qIA4wTt9eqsAx+EVEqUDXbV
OTzqqE0rgMlz+b+Vbic00DgiYwjZj4A3/rcFKDf8AoCPk2dGNMTAt5ik7lwQ0Pqk
3o3MeITIoQsVBl8HsV67Ng9dokJ89KHhpXMxPTg3VMn3KOAfuy5vw6vQ1A3VFUdi
yxI69T5cwMp5ilrwikeBexYw519rgfBbgQ4WHI4V+6xAmxp1+FV85IyB4gd43M8D
LFY3LaPTHv1VGkbKDrSYsQT5RBDaIsHvZwAGTgxvW5Intw6UtYRh6lpGCxgG7Zdn
DRb7tVR4D+RAvbP2swDLqSVBFYK2XeajsSFlN/Nzp8Pm9pzB5UDRg6dehacFog3g
sZ1Y/QASKaLnR71sttpYEpF2uZgvsoS7VEboHt/356hlneq4jjT+e4ph0KSZryhs
DZfIzFOZWj/FNOwH9ZMBZG8rNAsRWLw2yPuHHHgVlwfdOPKgWVX385n/vDBlB8/N
rAYLwhsPU2uK3bTc6Rjkk0e/mCvSdgEsU+ID9YQdvUJBCT/23AP+jbxsvePQNCPH
DPX+s6zGvrYGD08+1YGtsehgnK17aAAK09+o2EDToIbG44bXiDc=
=tYN0
-----END PGP SIGNATURE-----
--=-=-=--
