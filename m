Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59211 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752021AbdIGAni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Sep 2017 20:43:38 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Thu, 07 Sep 2017 10:43:29 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
In-Reply-To: <20170906160342.GB28077@parsley.fieldses.org>
References: <20170829214026.GI8822@parsley.fieldses.org> <8760d5hol3.fsf@notabene.neil.brown.name> <20170830170938.GC24373@parsley.fieldses.org> <87wp5kfxi3.fsf@notabene.neil.brown.name> <20170831190531.GA8223@parsley.fieldses.org> <873787fhc5.fsf@notabene.neil.brown.name> <20170901161809.GA22140@parsley.fieldses.org> <871snndq04.fsf@notabene.neil.brown.name> <20170905195619.GB17828@parsley.fieldses.org> <877excde18.fsf@notabene.neil.brown.name> <20170906160342.GB28077@parsley.fieldses.org>
Message-ID: <87tw0fbaoe.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


>> +		host_err = nfsd_conflicting_leases(dentry, rqstp);
>> +		host_err = host_err ?: notify_change(dentry, &size_attr, nfsd_deleg_owner, NULL);
>
> And then you recall nfsd delegations and delegations held by
> (hypothetical) non-nfsd users separately, OK (also ignoring how).
>
> There are no such users currently, so nfsd could just pass NULL.

I don't think so.  If we pass NULL (as the owner), when VFS will recall
the one nfsd delegation that we want to preserve. ???

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmwljIACgkQOeye3VZi
gbl01BAAr1Qul87HJhyRqo1eQw/a7hHVU6kdNgtyowhSULLhxMPPZyZ8+kt6BRu6
uYAac38IxufVyc9TPABQ7loRCy2HPO7dNAJ8v1NbNStfINSabY7KHHRNbHfbX6/k
ns98lbbCKyCldbcLS2mVx2KoK8txgOHSsh08XwDLb1B4pRelcBrIXz9DWeZapeaM
6McZGa8J452jUlqicK6LezwKjwHN44b3z8qdcQu8uAs/6rgRwyc/D/jG9e31E1it
6VlYtRyEdhfUvHSpAyLxK4fD8IgeXGIP2I4W19tajPLgKbo7f9J8T8FejIKmyO1o
GD3aIY9JnkMCqDB9L0qweFZbNZ6FDnGMYXE9r5SdM5hPaBEDlcBUzx61Ak70WxH5
26+pP86w53p8lmGv/dNTjk+unTcDtG57Sz2Os2+RnaHnEB7MY3CW4qb8Q2g2PRuY
wEnjDljbwHPUelREdHcUTYXeBzGXpLSq28DSCpxK2DnS9Y3j89zMYVuvSAqXz5IK
wnvt/fE3acDh+gxFGjOdvoA0EepANGxoc4yqmQGIjSKkAvYGGmC858yva+lAJn5y
zQc77ixnuu/vysOrOV1P6gCr0QmgsRxHbCNbQ3ndBSA/3Q3cEKKWCt91FWZ0tjfW
CH7JPIiyyYTvBzhV8n9goEhD+aA2wtiCXdAZE8dJqAx2/hRFNVU=
=Qw/T
-----END PGP SIGNATURE-----
--=-=-=--
