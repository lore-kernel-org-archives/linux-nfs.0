Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60571 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751190AbdDCCN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Apr 2017 22:13:56 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 03 Apr 2017 12:13:49 +1000
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: don't try to cross a mountpount when there isn't one there.
In-Reply-To: <20170401013241.GD14424@fieldses.org>
References: <87fuife2qr.fsf@notabene.neil.brown.name> <20170401013241.GD14424@fieldses.org>
Message-ID: <87o9wedyqq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 31 2017, J. Bruce Fields wrote:

> Sorry for the delay, I need to find a little time to digest that one.
>
> Makes sense to me--but it's a little subtle, and it looks like this
> bug's been lurking for a few years, so I think I'll let it wait for
> 4.12 if that's OK.

4.12 is fine with me.
Yes, it has been lurking.  As containers and other users of filesystem
name spaces become more common, we can expect this bug to trigger more
often.
I've only seen it under test conditions - not in a real-world use case -
so I don't think there is any rush.

Thanks,
NeilBrown


>
> --b.
>
> On Wed, Mar 15, 2017 at 12:40:44PM +1100, NeilBrown wrote:
>>=20
>> consider the sequence of commands:
>>  mkdir -p /import/nfs /import/bind /import/etc
>>  mount --bind / /import/bind
>>  mount --make-private /import/bind
>>  mount --bind /import/etc /import/bind/etc
>>=20
>>  exportfs -o rw,no_root_squash,crossmnt,async,no_subtree_check localhost=
:/
>>  mount -o vers=3D4 localhost:/ /import/nfs
>>  ls -l /import/nfs/etc
>>=20
>> You would not expect this to report a stale file handle.
>> Yet it does.
>>=20
>> The manipulations under /import/bind cause the dentry for
>> /etc to get the DCACHE_MOUNTED flag set, even though nothing
>> is mounted on /etc.  This causes nfsd to call
>> nfsd_cross_mnt() even though there is no mountpoint.  So an
>> upcall to mountd for "/etc" is performed.
>>=20
>> The 'crossmnt' flag on the export of / causes mountd to
>> report that /etc is exported as it is a descendant of /.  It
>> assumes the kernel wouldn't ask about something that wasn't
>> a mountpoint.  The filehandle returned identifies the
>> filesystem and the inode number of /etc.
>>=20
>> When this filehandle is presented to rpc.mountd, via
>> "nfsd.fh", the inode cannot be found associated with any
>> name in /etc/exports, or with any mountpoint listed by
>> getmntent().  So rpc.mountd says the filehandle doesn't
>> exist. Hence ESTALE.
>>=20
>> This is fixed by teaching nfsd not to trust DCACHE_MOUNTD
>> too much.  It is just a hint, not a guarantee.
>> Change nfsd_mountpoint() to return '1' for a certain mountpoint,
>> '2' for a possible mountpoint, and 0 otherwise.
>>=20
>> Then change nfsd_crossmnt() to check if follow_down()
>> actually found a mountpount and, if not, to avoid performing
>> a lookup if the location is not known to certainly require
>> an export-point.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  fs/nfsd/vfs.c | 24 ++++++++++++++++++++----
>>  1 file changed, 20 insertions(+), 4 deletions(-)
>>=20
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 19d50f600e8d..04cafaa94bf7 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -94,6 +94,12 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry =
**dpp,
>>  	err =3D follow_down(&path);
>>  	if (err < 0)
>>  		goto out;
>> +	if (path.mnt =3D=3D exp->ex_path.mnt && path.dentry =3D=3D dentry &&
>> +	    nfsd_mountpoint(dentry, exp) =3D=3D 2) {
>> +		/* This is only a mountpoint in some other namespace */
>> +		path_put(&path);
>> +		goto out;
>> +	}
>>=20=20
>>  	exp2 =3D rqst_exp_get_by_name(rqstp, &path);
>>  	if (IS_ERR(exp2)) {
>> @@ -167,16 +173,26 @@ static int nfsd_lookup_parent(struct svc_rqst *rqs=
tp, struct dentry *dparent, st
>>  /*
>>   * For nfsd purposes, we treat V4ROOT exports as though there was an
>>   * export at *every* directory.
>> + * We return:
>> + * '1' if this dentry *must* be an export point,
>> + * '2' if it might be, if there is really a mount here, and
>> + * '0' if there is no chance of an export point here.
>>   */
>>  int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
>>  {
>> -	if (d_mountpoint(dentry))
>> +	if (!d_inode(dentry))
>> +		return 0;
>> +	if (exp->ex_flags & NFSEXP_V4ROOT)
>>  		return 1;
>>  	if (nfsd4_is_junction(dentry))
>>  		return 1;
>> -	if (!(exp->ex_flags & NFSEXP_V4ROOT))
>> -		return 0;
>> -	return d_inode(dentry) !=3D NULL;
>> +	if (d_mountpoint(dentry))
>> +		/*
>> +		 * Might only be a mountpoint in a different namespace,
>> +		 * but we need to check.
>> +		 */
>> +		return 2;
>> +	return 0;
>>  }
>>=20=20
>>  __be32
>> --=20
>> 2.12.0
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljhr90ACgkQOeye3VZi
gbmcOg//T3aUj3pwUDn4myjcZD7ig+Sih91b4C3d7Zj1T0rmxctihVrsx2tvyisJ
7F2fA1PlYR1XFZUXcyc4BON7MHZ6Siju1JSkf+abcPW8+zokodYNJHGLfv81eO8+
1ePyb5oKYjn5xmFo7E1pA/a71yqz1rc6SgcT2CGfCKxp9VHIkfViHT/ghPqiRDNj
IGRVPaqp3xfpegrcQwiuZWZprUqoFf0PRB9VCdaNykFM3cY01a7nSeDgb0gkL+E0
/FShf0vMDNv0zQNUHf3imxyNP7sOksQRFHVFpr2b/6/2shJhxaVnUm2WYUgnb9tE
kFplkLN5ocl2xQ9gNkvvAOy9Cj0DB0vwHnv/4Yq0Lb15o4rOTKaJCepph+tRkBCS
3sZZ4BP40I20FQsnqbalgsPWJJQMCjWUHiqI+fkwSdOF9EIvHKvLGHuX2zezmaOV
gAEXX6RE25V4TnphwALo9FKSv1W9ecY9s2toy0Otagsl6aXkeSJZurdJugVXqZd1
CFp0UP0FPESg2g9rCCyDmfVVX9T086GGt50HDKPExDAFVN4qmHh5oqM9EbpHC/8M
ANhxeAhoe+n2cSv6U7KFXQSqy3xfaPg8VI65QDQx81ocQUjQR5XrL0m2Guni+3uU
cJeCnhJyas5ym5IngcoUpG2m5XVfRxpsdjGJEjRQFQFpJZfIzmw=
=RI5c
-----END PGP SIGNATURE-----
--=-=-=--
