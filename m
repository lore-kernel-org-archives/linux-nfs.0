Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55293 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750919AbcLAWKE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 17:10:04 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 09:09:49 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] mount: take history into account when assessing if an error is permanent.
In-Reply-To: <0ecc5408-5d21-5c0c-86fb-07cc804f3d4c@RedHat.com>
References: <148046718451.21092.10685567606499960786.stgit@noble> <148046723208.21092.12537997642943826780.stgit@noble> <0ecc5408-5d21-5c0c-86fb-07cc804f3d4c@RedHat.com>
Message-ID: <87mvgf713m.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 02 2016, Steve Dickson wrote:
>>  static int nfs_is_permanent_error(int error)
>>  {
>> +	static int prev_error;
>> +	static int rpt_cnt;
>> +
>> +	if (error =3D=3D prev_error)
>> +		rpt_cnt +=3D 1;
>> +	else
>> +		rpt_cnt =3D 1;
>> +	prev_error =3D error;
>> +
>>  	switch (error) {
>>  	case ESTALE:
>> -	case ETIMEDOUT:
>> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>> +		/* If two in a row, assume permanent */
>> +		return rpt_cnt >=3D 3;
> This looks good... very clean... and now the time
> out is control by the -o retry setting... Perfect!
>
>>  	case ECONNREFUSED:
>> +		return rpt_cnt >=3D 5;
> My only question is why mess with this? Over the years=20
> we've always time out after 2 mins (the default) and now=20
> we are bring that down to 15 secs? I'm think that might
> be a bit short... I seems like we might be fixing something
> that is not broken...=20

Because it seemed like the "right" thing to do.  ECONNREFUSED should be
a "permanent" error, except during a small window when the server is
booting.
But following the principle "if it ain't broke, don't fix it", I guess
it should stay as a "temporary" error.  I'll resend.

>
> But again the design is very clever... nice work!=20

Thanks!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhAn60ACgkQOeye3VZi
gbnIyhAAuYtSK3DWUYyMdOtl46drGAuzV395qHq3FUAEBl36f99oT2KLSamQobQV
cfFzrWfUl0JFhZ2V1bZ8KDf4WBE+KInvrRK+2QUcf88QIRCXH/NX1RWCAswSlyKE
ow+CRWZX4xU+r8EH6Rg+0rBqUrCe2wcQS4KFqLoLV3MRaum/fKgJb8W8Eiqcw/QT
FXUQPvRefCUttdCPgIk7RgCt/MFK42KtKf0k5l/xUSUhnYTO+foJyYeolX64t9uy
nMlzhXYOeE5v/kUXyOppHJxId9/nKA4CSAd57dU6oEQZj1qYcpuhX6QMwxCvIigE
sA4ukhlpI3hy4irvhQqLu8GNDtlc3wYElirLJ9PqvY58ln6herF421cicSa51ts9
PPP4vCNLDlMDTMefmh3lBP/fqjfwgXc/SYbeF5sQzmlXXeGH/Ymu5nP7Th7RPS2d
bfddjjPrdX8Ed76t6Q259eUpRKyZZaNEmQBd8wtvEwbi6IJb12TflMjLXXNox6G5
NpVfEtjPVqzOOYL04joyWfp2NkgOOM9e+cdGsdXLJqYzVUizHILYR/Pk4FjRU0Zt
uXRT+WVXqcCIASInQsfK9VKFIHM1O4AjmPwBj/UVJGXuwvt2RhHRgy2j9DGikFwr
wp+OF7AO9JrCpBLKMc6fIa7FAqQ0u84U+HAclF5f5dEKslrDRHQ=
=nWfM
-----END PGP SIGNATURE-----
--=-=-=--
