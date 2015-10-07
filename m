Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49934 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754141AbbJGRdH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2015 13:33:07 -0400
Subject: Re: [PATCH RESEND] svcrdma: handle rdma read with a non-zero initial
 page offset
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <20150928214605.17900.50257.stgit@build2.ogc.int>
 <56140879.3040000@redhat.com> <20151007170151.GB26514@fieldses.org>
Cc: Steve Wise <swise@opengridcomputing.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
From: Doug Ledford <dledford@redhat.com>
Message-ID: <56155751.7010903@redhat.com>
Date: Wed, 7 Oct 2015 13:33:05 -0400
MIME-Version: 1.0
In-Reply-To: <20151007170151.GB26514@fieldses.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xrxxU38gWGaJ9tAbifLo7ElPsImx5Lk1o"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xrxxU38gWGaJ9tAbifLo7ElPsImx5Lk1o
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/07/2015 01:01 PM, J. Bruce Fields wrote:
> On Tue, Oct 06, 2015 at 01:44:25PM -0400, Doug Ledford wrote:
>> On 09/28/2015 05:46 PM, Steve Wise wrote:
>>> The server rdma_read_chunk_lcl() and rdma_read_chunk_frmr() functions=

>>> were not taking into account the initial page_offset when determining=

>>> the rdma read length.  This resulted in a read who's starting address=

>>> and length exceeded the base/bounds of the frmr.
>>>
>>> Most work loads don't tickle this bug apparently, but one test hit it=

>>> every time: building the linux kernel on a 16 core node with 'make -j=

>>> 16 O=3D/mnt/0' where /mnt/0 is a ramdisk mounted via NFSRDMA.
>>>
>>> This bug seems to only be tripped with devices having small fastreg p=
age
>>> list depths.  I didn't see it with mlx4, for instance.
>>
>> Bruce, what's you're take on this?  Do you want to push this through o=
r
>> would you care if I push it through my tree?
>=20
> Whoops, sorry, I meant to send a pull request for that last week.  Uh, =
I
> think I'll go ahead and do that now if it's OK with you.

Fine with me.  I was just trying to make sure it didn't get forgotten ;-)=


> --b.
>=20
>>
>>> Fixes: 0bf4828983df ('svcrdma: refactor marshalling logic')
>>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>>> Tested-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    6 ++++--
>>>  1 files changed, 4 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xpr=
trdma/svc_rdma_recvfrom.c
>>> index cb51742..5f6ca47 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> @@ -136,7 +136,8 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt=
,
>>>  	ctxt->direction =3D DMA_FROM_DEVICE;
>>>  	ctxt->read_hdr =3D head;
>>>  	pages_needed =3D min_t(int, pages_needed, xprt->sc_max_sge_rd);
>>> -	read =3D min_t(int, pages_needed << PAGE_SHIFT, rs_length);
>>> +	read =3D min_t(int, (pages_needed << PAGE_SHIFT) - *page_offset,
>>> +		     rs_length);
>>> =20
>>>  	for (pno =3D 0; pno < pages_needed; pno++) {
>>>  		int len =3D min_t(int, rs_length, PAGE_SIZE - pg_off);
>>> @@ -235,7 +236,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xpr=
t,
>>>  	ctxt->direction =3D DMA_FROM_DEVICE;
>>>  	ctxt->frmr =3D frmr;
>>>  	pages_needed =3D min_t(int, pages_needed, xprt->sc_frmr_pg_list_len=
);
>>> -	read =3D min_t(int, pages_needed << PAGE_SHIFT, rs_length);
>>> +	read =3D min_t(int, (pages_needed << PAGE_SHIFT) - *page_offset,
>>> +		     rs_length);
>>> =20
>>>  	frmr->kva =3D page_address(rqstp->rq_arg.pages[pg_no]);
>>>  	frmr->direction =3D DMA_FROM_DEVICE;
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma"=
 in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>> --=20
>> Doug Ledford <dledford@redhat.com>
>>               GPG KeyID: 0E572FDD
>>
>>
>=20
>=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--xrxxU38gWGaJ9tAbifLo7ElPsImx5Lk1o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWFVdRAAoJELgmozMOVy/daFwQALL5mMOzsPu1bYHhkn1TF5Oc
8fkser3KaPZsFwZzGfBc1sCLZYUwAV2A9e3zhoGTt77eLdHzkabjVovV50ZmXQC7
iu8dKKUxrsLRHknNOYbcI+WnZxuQrxWDqEh/6V2KRSsKuU3FrK9sM5kZ4o6x8VcP
ZNwf6fPtszujJBmgtT5FMJtUaejWJj4n2ax9ZF5VU2TUz+NBlMYlG+FdqFRW6sti
wVxIiaPOeJhUPTH0g9mK8tsOHmQSNfKtoyO11J1Z7B+8LFdzEHYeh0qdanbqxABo
aarlbyzXLXzFKv1NpUyiXSe9bX5tvcbSwGQb8DdnKOU9Pe0U1o95g3Dz6mWnIMfC
kMyUjHgJ7L2Ia7f/fkwFYZRBdsqL7bOCl9VIoa7nl6PMgxLVdlbI4B+iKQtLvoAb
N7ErXv3E6apKDspvHIRNf8QM3rmhf3evM2PtM5XM5TzAhP6nJG7OaV7Zyed2Na7n
AEP/y/g1uSBxpzdt8/7AgZ3z+RFtYoIWXQcqaW1eS2F+EPDaGEuVlzZO4eo4F0dw
CD0AgZrpcngbUoouFYTEuB+rlNO9HKhDqtMQts2+MAJtg0o6hom1Cmq/ELzfmBI8
JbGBTMCla0+UVlp3g5PQ2tjnAqeIULJjiWp9cVK14qFxJiSdJFngpdZ0hxIuFo4V
XB6r4ahRgVwBx4hY89Qj
=Xozb
-----END PGP SIGNATURE-----

--xrxxU38gWGaJ9tAbifLo7ElPsImx5Lk1o--
