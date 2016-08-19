Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57408 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754127AbcHSUno (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 16:43:44 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Sat, 20 Aug 2016 06:43:37 +1000
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 1/2] systemd: improve ordering between nfs-server and various mounts
In-Reply-To: <20160819173830.GK32329@fieldses.org>
References: <147157095612.26568.14161646901346011334.stgit@noble> <147157115637.26568.2867884353016441810.stgit@noble> <20160819173830.GK32329@fieldses.org>
Message-ID: <87r39kh4li.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 20 2016, J. Bruce Fields wrote:

> On Fri, Aug 19, 2016 at 11:45:56AM +1000, NeilBrown wrote:
>> Commit: 1e41488f428c ("systemd: Order NFS server before client")
>>=20
>> added an ordering dependency between network mounts and nfs-server.
>> This is good for loop-back NFS mounts as it ensures the server
>> will remain until after the mountpoint is unmounted.
>>=20
>> However is is bad for _net mounts (such as those via iSCSI) which
>> are being NFS exported.
>>=20
>> nfs-server needs to be start *after* exported filesystems are mounted,
>> and *before* NFS filesystems are mounted.  systemd isn't able to make
>> this distinction natively, so we need to help it.
>>=20
>> This patch adds a systemd generator which creates a drop-in for
>> nfs-server.services so that it is started "After" any "nfs" or "nfs4"
>
> s/After/Before/ ?

Yes.  I suspect this was caused by the fact that my goal was for
nfs-server to stop After nfs mounts.  The concepts start to blur.
It is a bit like doing a git-bisect to find out where some bug was
fixed.  good=3D=3Dbad, bad=3D=3Dgood

>
> The code's right:

I remember fixing the code....

Steve: if there are no other revisions, would you still like me to
resend to fix this, or will you just correct it when you eventually
commit it?

Thanks,
NeilBrown


>
>> +	fstab =3D setmntent("/etc/fstab", "r");
>> +	while ((mnt =3D getmntent(fstab)) !=3D NULL) {
>> +		if (strcmp(mnt->mnt_type, "nfs") !=3D 0 &&
>> +		    strcmp(mnt->mnt_type, "nfs4") !=3D 0)
>> +			continue;
>> +		fprintf(f, "Before=3D ");
>> +		systemd_escape(f, mnt->mnt_dir);
>> +		fprintf(f, ".mount\n");
>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXt295AAoJEDnsnt1WYoG5Zh8P/06H+lRKUF/eSK/c3qIljwEP
HOLedfgxA8E6RhJoyMnjlsD6//NZQb4e82sKrlKOq5lQWEiBZNOxrTZlOUHCe90v
fS/WR0DC19LSZBrrhNb3nlSsuBrgSBU4nphsH2RxOM74QL0Geon3h024F6DNBIps
BbnnuDNFiZWKUdAPSHR2me3F0/G8vKzJURyyzFl0N31/GKCbzGXxv+PVoRwpB63c
+7V9DQC3tVSpi6187lDGXY52SlI8sG4PgseanCenPJjtPUKmIuMAU6fDdccXcBSl
LlUpbsbSKAgRWZGVypeC0g1xBC8wEJn9DikIgEpVbCZSVVr1kN51tC2oTuKNcedm
gsnydZRscQUUBFo7bAt+iReQsENdnequMzJDhXGsbZWqRY+Pzt8jTUHd2SrrtcXV
GHbcHroeFleNU3Xr+OLniF7yJ4r+s1gaRyOlPlynch8Y8M/yahNm8skH0po8AOLW
btFViM/lkGIRBnDvP+toRT5W8LptAASmGximYl34L7rU9aBH1hnJ/n8tO5jbyDYW
J2hKiA0EOVu/YYfk2yLRcsj9QnqiZpXzD+CGzbgABkBlM13F/sdNAXQ3iobnx5nG
yPSBDrFfgwYIORp30uOmUWE+nTxIlW4RSc7sq7auds//NJ3q4rcMlEduv2Qb1Snx
wyF/wGWzmCvVpulUdAcF
=Nwx5
-----END PGP SIGNATURE-----
--=-=-=--
