Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbbJFRgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Oct 2015 13:36:24 -0400
Subject: Re: [PATCH rdma-rc v1] xprtrdma: Don't require LOCAL_DMA_LKEY support
 for fasterg
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <1444150357-2362-1-git-send-email-sagig@mellanox.com>
 <56140404.1010809@Netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
From: Doug Ledford <dledford@redhat.com>
Message-ID: <56140697.6050205@redhat.com>
Date: Tue, 6 Oct 2015 13:36:23 -0400
MIME-Version: 1.0
In-Reply-To: <56140404.1010809@Netapp.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Kgvwk0cbUFF3jmSa1gWxBcDSBUmipoH6b"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Kgvwk0cbUFF3jmSa1gWxBcDSBUmipoH6b
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/06/2015 01:25 PM, Anna Schumaker wrote:
> Hi Sagi,
>=20
> On 10/06/2015 12:52 PM, Sagi Grimberg wrote:
>> There is no need to require LOCAL_DMA_LKEY support as the
>> PD allocation makes sure that there is a local_dma_lkey. Also
>> correctly set a return value in error path.
>>
>> This caused a NULL pointer dereference in mlx5 which removed
>> the support for LOCAL_DMA_LKEY.
>=20
> Looks good to me!  This is another patch going directly to an RDMA tree=
 somewhere, right?

Yeah, I'll pick this one up.  Thanks!

> Anna
>=20
>>
>> Fixes: bb6c96d72879 ("xprtrdma: Replace global lkey with lkey local to=
 PD")
>> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Changes from v0:
>> - Added error path rc assignment.
>>
>>  net/sunrpc/xprtrdma/verbs.c |    8 +++-----
>>  1 files changed, 3 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c=

>> index eb081ad..81e8d31 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -543,11 +543,8 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct=
 sockaddr *addr, int memreg)
>>  	}
>> =20
>>  	if (memreg =3D=3D RPCRDMA_FRMR) {
>> -		/* Requires both frmr reg and local dma lkey */
>> -		if (((devattr->device_cap_flags &
>> -		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=3D
>> -		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) ||
>> -		      (devattr->max_fast_reg_page_list_len =3D=3D 0)) {
>> +		if (!(devattr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) ||
>> +		    (devattr->max_fast_reg_page_list_len =3D=3D 0)) {
>>  			dprintk("RPC:       %s: FRMR registration "
>>  				"not supported by HCA\n", __func__);
>>  			memreg =3D RPCRDMA_MTHCAFMR;
>> @@ -557,6 +554,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct =
sockaddr *addr, int memreg)
>>  		if (!ia->ri_device->alloc_fmr) {
>>  			dprintk("RPC:       %s: MTHCAFMR registration "
>>  				"not supported by HCA\n", __func__);
>> +			rc =3D -EINVAL;
>>  			goto out3;
>>  		}
>>  	}
>>
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--Kgvwk0cbUFF3jmSa1gWxBcDSBUmipoH6b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWFAaXAAoJELgmozMOVy/djVoP/1P5fDBz18EVKC8yzPVyCgav
EtxNZ4Kx/m14Vhc7noQNm4c3vEpNibugpLkLnW3mPyIebTAaL7b/Rb1MDZ26PYYe
RtViAFWeHZ0B+nGiuaRcs7PKPfy40laiiCa1JcgbVyKmARDe46Y1LkHII6hl7XRF
anCi1QBvF0ZDPQIAKxIhV4HGN0JJjLoO7H1gVFLKV7CTz5EdUjeZYNzhFjXaykji
EDr4IiJGYdJ3mSFUqxpLQ+XdbZ8ocX2ZFYZ4A0ispvvLSA5Ciy1pciRg4F69aCCq
T+b+7YLxarSAnMSRIB0FGRJJRcNCzRPPJoO+ZbTw7wjw96pG5jWsv3Zve4yCVpXU
96B6qYULz5Ibsz4TrNr5epgIpDmttZVb5UFaD2eVsz8U1YtiRHY5feC7F2StUWlv
XNAiFZudj8smCLk+8lSec3Ba8IAIeKMttay9Q1i5EvH2j+hi/Dnv6OniAA3T0FnL
2Uhvdz2jK3ChrRVo2sOGyLYMFJfsMORs2Mds8t/a7/inLHiYgF2SaJHylSGGhloY
41GkR+BMvlByAKWvdXxCKNBJpKHczgUnmshnzWd1+/ci9Js+YAStwpAxyV6HDjEj
wq62/flstqlp4ol1QkWoxr+YoKr9X1+fTUwzenZ6n14cCR4sVOqE91RQ/4jzfzFO
QTcDo6HdpBt6ttHkoSFX
=Jky6
-----END PGP SIGNATURE-----

--Kgvwk0cbUFF3jmSa1gWxBcDSBUmipoH6b--
