Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41836 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935395AbdCLV6a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Mar 2017 17:58:30 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 13 Mar 2017 08:58:22 +1100
Cc: Trond Myklebust <trondmy@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFSD: fix nfsd_minorversion(.., NFSD_AVAIL)
In-Reply-To: <20170310221648.GN29791@fieldses.org>
References: <148910618557.3032.8265198632788708076.stgit@noble> <148910619931.3032.2841124907029105276.stgit@noble> <20170310221648.GN29791@fieldses.org>
Message-ID: <87innef98h.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 10 2017, J. Bruce Fields wrote:

> On Fri, Mar 10, 2017 at 11:36:39AM +1100, NeilBrown wrote:
>> Current code will return 1 if the version is supported,
>> and -1 if it isn't.
>> This is confusing and inconsistent with the one place where this
>> is used.
>
> It's used?  I don't see it.--b.

You are correct of course.  NFSD_AVAIL is used once, but not with
nfsd_minorversion.
Would it ever make sense to selectively include different minor
versions at compile time?  Probably not, but it probably doesn't matter
anyway.

NeilBrown


>
>> So change to return 1 if it is supported, and zero if not.
>> i.e. an error is never returned.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  fs/nfsd/nfssvc.c |    3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>> index 786a4a2cb2d7..892137b1e330 100644
>> --- a/fs/nfsd/nfssvc.c
>> +++ b/fs/nfsd/nfssvc.c
>> @@ -167,7 +167,8 @@ nfsd_adjust_nfsd_versions4(void)
>>=20=20
>>  int nfsd_minorversion(u32 minorversion, enum vers_op change)
>>  {
>> -	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION)
>> +	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION &&
>> +	    change !=3D NFSD_AVAIL)
>>  		return -1;
>>  	switch(change) {
>>  	case NFSD_SET:
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljFxH4ACgkQOeye3VZi
gbnRew/9Eae/yGvG6xOM3cL/YJMwRtpsE45Q0k/uh8rrL8A1OfERtPSobT4r98BN
WxLvQ6CpbtjorilV8xHsK0nQju98PduD2ZnrjQ+EUT+BFPfOl9EX4ZO8GYE/si8+
aCIve2s75yF5uaoFN+RlPmYHZPd37CeUBb+ZEqhvjzQLdavzpmANOof2C+Y1Rx1w
k7XIOggOe6MSg9+8qH77EqxhTXtgkGR+LLmn5wuiveNHksUJAi+hl3cOJ3gDTo67
Y9zu81s9Eh0AMugSTbMW5vnan8mqsVGbsoyQzXNXPKLX0a6wyIdWdVZRvcJ5qflJ
FDSiMvYRld/em5kZEPIvFKvEweD21ITm9pDamCqRCy5gxh+Jt8gcGbnApmaBn1a+
RFGmBYBdxw2lNjThpwEdJlKQ4Le9Clf9lFVU+Q4C7mCRnjjRY57N65RjeefmMMfs
Gi8NL8CdevLSckyH8th0jmpt8FiUzVHzmB4pPhm2XpOP78kWoeCAAQRDujAZZFpj
08FopbgDikluujRZzOFp27ZKpHsBTxzRDl4G1pJYXs/d2BjTGkadwErq/V/+9SV9
dumXhGpWytTNdpXVyWGaPwI7aA2ugMwzQBztrlxhuCIfnm7OXHiMTg7xCO1e7kbU
r/RUhtifI8u5x35WhhpCbPSCETrEqOXPnSlDWpkPJn58Iw+lems=
=Fky6
-----END PGP SIGNATURE-----
--=-=-=--
