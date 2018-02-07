Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56240 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755146AbeBGVUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 16:20:52 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 08 Feb 2018 08:20:43 +1100
Subject: Re: [PATCH 1/2] NFS: Remove a redundant call to unmap_mapping_range()
In-Reply-To: <1518003998.3483.0.camel@primarydata.com>
References: <20180129025822.5116-1-trond.myklebust@primarydata.com> <876079nvvc.fsf@notabene.neil.brown.name> <1518003998.3483.0.camel@primarydata.com>
Message-ID: <87vaf8mr84.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 07 2018, Trond Myklebust wrote:

> On Wed, 2018-02-07 at 17:42 +1100, NeilBrown wrote:
>> On Sun, Jan 28 2018, Trond Myklebust wrote:
>>=20
>> > We don't need to call unmap_mapping_range() prior to calling
>> > nfs_sync_mapping().
>>=20
>> Don't we?
>
> See line 2 of nfs_sync_mapping(). =E2=98=BA

Ahhh.  Makes perfect sense now - thanks

NeilBrown


>
>> Doesn't that allow a process which mapped the page to dirty it
>> immediately after nfs_sync_mapping(), without the page being
>> reloaded from the server first?
>> Doesn't seem right..
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>> >=20
>> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> > ---
>> >  fs/nfs/inode.c | 1 -
>> >  1 file changed, 1 deletion(-)
>> >=20
>> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> > index deeb7d1097d0..49fba9ea5872 100644
>> > --- a/fs/nfs/inode.c
>> > +++ b/fs/nfs/inode.c
>> > @@ -1170,7 +1170,6 @@ static int nfs_invalidate_mapping(struct
>> > inode *inode, struct address_space *map
>> >=20=20
>> >  	if (mapping->nrpages !=3D 0) {
>> >  		if (S_ISREG(inode->i_mode)) {
>> > -			unmap_mapping_range(mapping, 0, 0, 0);
>> >  			ret =3D nfs_sync_mapping(mapping);
>> >  			if (ret < 0)
>> >  				return ret;
>> > --=20
>> > 2.14.3
>> >=20
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-
>> > nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --=20
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp7bawACgkQOeye3VZi
gbmhMBAAsI9envk0UngT1E9LwSSvN94IgCxuK5qXJZRuLSKkAi7sq5cu4otAMf2J
hiZvJ9YvZzW/y4IKagO6oqkuGBYjOGEt+1WRpPmcwIp8fVzzyeSQxt20O8s3w377
XbfWFJOtw5zoqtVvYVH1P1PDoQ4eeN6GCV7Rq2k5Rzhdt5lfJ2l9cH6AC4EUhtOc
TPyKJIhcEIlf5vj2iI7poNFUJmASSoeXnxdxneLKIF36Nu8QnJt5FDpLe5f3KV+q
ymG8e0bUrvKscQhkEfXrxDtxvjNSi6eRdvNB10gYB0lNPMq7A5tr73gfGwds5Iza
835VDU0dFx+XCgiDLNNnX+C5t5b1V4o+LlnrnIRT3AApbud1sMmF0sXg06lgMIbJ
xH8eGCUotHh3Z8no16w4rkh74F+OoesKKJNh1wt926+LCfWXFisbw29PFFeGEyen
T7oAV8Iw0MHR87RtTmk8dyTZfyux9NXPbqpt2b6y2H62m9HH5lE6j84hcQpoMsBh
D826VEb0+vg80Fi7wj73qzwzA9/SeAJM4Cl/Ccdei8TbzeRp1p/qEpguCfQTd47P
ynQJp6sPmE889laJStjnrwPqP4Tl4Jth5kynex+oAxnoPkktUFh/VjJymZMtEehl
Q0WMXlf80FiUAnBQp2pdoof/wyFYGD2Wg4mz5Qa7jZvqZ439uoQ=
=Vk6V
-----END PGP SIGNATURE-----
--=-=-=--
