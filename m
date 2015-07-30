Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36308 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752786AbbG3QmE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 12:42:04 -0400
Subject: Re: [PATCH for-4.3 00/15] Modify MR allocation API
To: Steve Wise <swise@opengridcomputing.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, target-devel@vger.kernel.org
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
 <55BA3B2A.9010403@opengridcomputing.com>
From: Doug Ledford <dledford@redhat.com>
Message-ID: <55BA53D8.8090600@redhat.com>
Date: Thu, 30 Jul 2015 12:42:00 -0400
MIME-Version: 1.0
In-Reply-To: <55BA3B2A.9010403@opengridcomputing.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xRitB4THXHCMX51dx7tffbcdihfFCaiT4"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xRitB4THXHCMX51dx7tffbcdihfFCaiT4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/30/2015 10:56 AM, Steve Wise wrote:
> On 7/30/2015 2:32 AM, Sagi Grimberg wrote:
>> This patch set is detached from my WIP for modifying our
>> fast registration kernel API. I incorporated some comments
>> from Jason and Christoph. The current set is a drop-in replacement
>> of ib_alloc_fast_reg_mr to ib_alloc_mr which receives a memory
>> region type (whcih can be IB_MR_TYPE_MEM_REG for normal memory
>> registration, IB_MR_TYPE_SIGNATURE for a data-integrity capable
>> memory region and future arbitrary SG support capable memory
>> region).
>>
>>
>=20
> Series looks good.
>=20
> Reviewed-by: Steve Wise <swise@opengridcomputing.com>

I've pulled this in for 4.3.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--xRitB4THXHCMX51dx7tffbcdihfFCaiT4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVulPYAAoJELgmozMOVy/dMj0P/1HqHgYOO8NmK14hgsbXS+rR
yxlYD4wmzvE4WBLF8tgyZ/7saKVHzyTpSHeOLucaNsn4KkPRv59s4Htbx+8+Q4xu
B2WS+uGIePhEJxdbCNsAfH+DldSvRB5G9hH5LxeaUP/brVZQDcOWCNruY16O+ZzN
6c+sb6n1phSkm+RjV2nj7Px8IRKE/tyRAa++F78OOhyUpZnohdelNajzWJPO2usz
FI2blnb1SfDLct81Ia8kQhPthfKRIRKRIk9NLm6gvAzYDvCaSSA5BUWwSp4wXwDJ
wtgcAkInj6ou6i20B9TmpGPaKmHTVaF/b7jZiJsjauG/f1kMbGkiV9HV3N6PPaCU
CwCnw/CgLLjK0MSdwnUqwSmfqOkUDbTobOufp0O48r0al1E39TxGfARMaGLZZ88o
TUz/u1XfZiaGX//dBa2v1GAF21J+laXBYR4FH5oVPSL8iVQAI0ENSEntxZY3D5x9
z8u35L74rvjqbR9UplycfjIBH5Abvkf/8vjSDwYYHCjQQZkxlMuuNfIclmap1QOy
Ee8Kif21wjfJTOJ/hueYxO4T+XEEnwJn4G2vjZCKq30Swz/b0KDURLbES7rhh9Ny
kYnJ4WxRtbgEuOrh8F8Ma/utDf7DWfe6VPc61GizNynAmZ4Q1GMElRig3VOY4+2D
T8kqqlrZu9H7wRds3Hh+
=6fjg
-----END PGP SIGNATURE-----

--xRitB4THXHCMX51dx7tffbcdihfFCaiT4--
