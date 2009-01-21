From: "Sachin S. Prabhu" <sprabhu@redhat.com>
Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
Date: Wed, 21 Jan 2009 14:55:45 +0000
Message-ID: <49773771.6070909@redhat.com>
References: <49760685.4030409@redhat.com> <1232475301.7055.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9A3C369A7369296049E22272"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59792 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480AbZAUOzv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jan 2009 09:55:51 -0500
In-Reply-To: <1232475301.7055.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9A3C369A7369296049E22272
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Trond Myklebust wrote:
> On Tue, 2009-01-20 at 17:14 +0000, Sachin S. Prabhu wrote:
>> A mistake in calculating the space left in the header in nfs3_xdr_seta=
clargs()
>> can cause memory corruption when setting a large number of acls.
>>
>> Reproducer:
>>
>> On Server:
>> 1) Create directory /test and set mode 777.
>> mkdir /test; chmod 777 /test
>> 2) Add 200 users and set default acl for user on /test
>> for i in {1..200}; do echo $i; useradd user$i; setfacl -m d:u:user$i:r=
wx
>> /test;done
>> 3) Add export /test  in /etc/exports
>> /test *(rw)
>>
>> On client
>> 1) Mount server:/test
>> mount server:/test /mnt
>> 2) Create large number of directories on the the share.
>> cd/mnt; for i in {1..1000}; do mkdir $i; done
>> At this point, the client should crash.
>>
>> A change in call_header changes the value req->rq_snd_buf->head[0]->io=
v_len to
>> reflect the exact size of the header.
>> [PATCH] RPC: Ensure XDR iovec length is initialized correctly in call_=
header
>> 334ccfd545bba9690515f2c5c167d5adb161989b
>>
>> The iov_len is set to the size of the header in  call_header().
>> req->rq_slen =3D xdr_adjust_iovec(&req->rq_svec[0], p);
>>
>> nfs3_xdr_setaclargs() depends on the older behavior and uses this valu=
e when
>> calculating the number of ACLs it can fit into the header.
>>
>>         /* put as much of the acls into head as possible. */
>>         len_in_head =3D min_t(unsigned int, buf->head->iov_len - base,=
 len);
>>         len -=3D len_in_head;
>>         req->rq_slen =3D xdr_adjust_iovec(req->rq_svec, p + (len_in_he=
ad >> 2));
>>
>> Since at this stage, iov_len < base, len_in_head will always be set to=
 len. For
>> a large number of ACLs, this will end up over-writing other parts of m=
emory on
>> the nfs client.
>>
>> The following patch which set len_in_head to 0 was tested with the rep=
roducer
>> and was found to fix the problem.
>>
>=20
> Looks alright. Could you please add a s-o-b line?
>=20
> Cheers
>   Trond
>=20

Signed-off-by: Kevin Rudd <solgato@us.ibm.com>

--- fs/nfs/nfs3xdr.c.orig	2009-01-21 13:09:50.000000000 +0000
+++ fs/nfs/nfs3xdr.c	2009-01-21 13:12:11.000000000 +0000
@@ -712,7 +712,10 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req
 	*p++ =3D htonl(args->mask);
 	base =3D (char *)p - (char *)buf->head->iov_base;
 	/* put as much of the acls into head as possible. */
-	len_in_head =3D min_t(unsigned int, buf->head->iov_len - base, len);
+	if ( buf->head->iov_len > base )
+		len_in_head =3D min_t(unsigned int, buf->head->iov_len - base, len);
+	else
+		len_in_head =3D 0;
 	len -=3D len_in_head;
 	req->rq_slen =3D xdr_adjust_iovec(req->rq_svec, p + (len_in_head >> 2))=
;



--------------enig9A3C369A7369296049E22272
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAkl3N3IACgkQrGYtZINVEC59SgCbBx7FePYgmLM413T71uVKBYC9
GiUAoMhKHuTN31i0JLmB34g6o5+E93dz
=WCZv
-----END PGP SIGNATURE-----

--------------enig9A3C369A7369296049E22272--
