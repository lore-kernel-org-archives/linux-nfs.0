From: "Sachin S. Prabhu" <sprabhu@redhat.com>
Subject: Memory corruption in nfs3_xdr_setaclargs()
Date: Tue, 20 Jan 2009 17:14:45 +0000
Message-ID: <49760685.4030409@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9CFDC45F3EA6497339AF4BBD"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47486 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757889AbZATROq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jan 2009 12:14:46 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n0KHEkda016177
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2009 12:14:46 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n0KHEk1Y009553
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2009 12:14:46 -0500
Received: from localhost.localdomain (splp.fab.redhat.com [10.33.0.53])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n0KHEjK9027841
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2009 12:14:46 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9CFDC45F3EA6497339AF4BBD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

A mistake in calculating the space left in the header in nfs3_xdr_setacla=
rgs()
can cause memory corruption when setting a large number of acls.

Reproducer:

On Server:
1) Create directory /test and set mode 777.
mkdir /test; chmod 777 /test
2) Add 200 users and set default acl for user on /test
for i in {1..200}; do echo $i; useradd user$i; setfacl -m d:u:user$i:rwx
/test;done
3) Add export /test  in /etc/exports
/test *(rw)

On client
1) Mount server:/test
mount server:/test /mnt
2) Create large number of directories on the the share.
cd/mnt; for i in {1..1000}; do mkdir $i; done
At this point, the client should crash.

A change in call_header changes the value req->rq_snd_buf->head[0]->iov_l=
en to
reflect the exact size of the header.
[PATCH] RPC: Ensure XDR iovec length is initialized correctly in call_hea=
der
334ccfd545bba9690515f2c5c167d5adb161989b

The iov_len is set to the size of the header in  call_header().
req->rq_slen =3D xdr_adjust_iovec(&req->rq_svec[0], p);

nfs3_xdr_setaclargs() depends on the older behavior and uses this value w=
hen
calculating the number of ACLs it can fit into the header.

        /* put as much of the acls into head as possible. */
        len_in_head =3D min_t(unsigned int, buf->head->iov_len - base, le=
n);
        len -=3D len_in_head;
        req->rq_slen =3D xdr_adjust_iovec(req->rq_svec, p + (len_in_head =
>> 2));

Since at this stage, iov_len < base, len_in_head will always be set to le=
n. For
a large number of ACLs, this will end up over-writing other parts of memo=
ry on
the nfs client.

The following patch which set len_in_head to 0 was tested with the reprod=
ucer
and was found to fix the problem.

--- fs/nfs/nfs3xdr.c.orig	2009-01-20 15:18:12.000000000 +0000
+++ fs/nfs/nfs3xdr.c	2009-01-20 15:33:45.000000000 +0000
@@ -691,7 +691,10 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req
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

Thanks to Kevin Rudd who did the major legwork here to figure the problem=
 and
create the patch.

Sachin Prabhu


--------------enig9CFDC45F3EA6497339AF4BBD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAkl2BoUACgkQrGYtZINVEC5oMgCgshuUCirfy0/oeFwkLBv3IWZ8
fDkAnAoP5h7AET+jX0U6XJgcpdJtGd3e
=GcHC
-----END PGP SIGNATURE-----

--------------enig9CFDC45F3EA6497339AF4BBD--
