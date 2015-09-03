Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755043AbbICUZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2015 16:25:29 -0400
Subject: Re: [PATCH v2] xprtrdma: take HCA driver refcount at client
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Devesh Sharma <devesh.sharma@avagotech.com>,
        linux-rdma@vger.kernel.org
References: <1438254018-2816-1-git-send-email-devesh.sharma@avagotech.com>
 <55E8A98D.5060903@redhat.com> <55E8AC91.2050208@Netapp.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
From: Doug Ledford <dledford@redhat.com>
Message-ID: <55E8ACB8.8080809@redhat.com>
Date: Thu, 3 Sep 2015 16:25:28 -0400
MIME-Version: 1.0
In-Reply-To: <55E8AC91.2050208@Netapp.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="wvmEDFlIs4eUTRM1mPCGk7HmRnf2p6MKF"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wvmEDFlIs4eUTRM1mPCGk7HmRnf2p6MKF
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 09/03/2015 04:24 PM, Anna Schumaker wrote:
> Hi Doug,
>=20
> On 09/03/2015 04:11 PM, Doug Ledford wrote:
>> On 07/30/2015 07:00 AM, Devesh Sharma wrote:
>>> Thanks Chuck Lever for the valuable feedback and suggestions.
>>>
>>> This is a rework of the following patch sent almost a year back:
>>> http://www.mail-archive.com/linux-rdma%40vger.kernel.org/msg20730.htm=
l
>>>
>>> In presence of active mount if someone tries to rmmod vendor-driver, =
the
>>> command remains stuck forever waiting for destruction of all rdma-cm-=
id.
>>> in worst case client can crash during shutdown with active mounts.
>>>
>>> The existing code assumes that ia->ri_id->device cannot change during=

>>> the lifetime of a transport. xprtrdma do not have support for
>>> DEVICE_REMOVAL event either. Lifting that assumption and adding suppo=
rt
>>> for DEVICE_REMOVAL event is a long chain of work, and is in plan.
>>>
>>> The community decided that preventing the hang right now is more
>>> important than waiting for architectural changes.
>>>
>>> Thus, this patch introduces a temporary workaround to acquire HCA dri=
ver
>>> module reference count during the mount of a nfs-rdma mount point.
>>>
>>> Cc: chuck.lever@oracle.com
>>> Cc: linux-nfs@vger.kernel.org
>>> Signed-off-by: Devesh Sharma <devesh.sharma@avagotech.com>
>>> Reviewed-by: Sagi Grimberg <sagig@dev.mellanox.co.il>
>>
>> Chuck, was this given final approval, and if so, who's tree is it
>> expected to go through?  Just trying to make sure I don't need to do
>> anything here as I don't see a rejection in my linux-rdma folder, but =
I
>> also didn't see it in the initial 4.3 nfs merge.
>=20
> This was approved and went through my tree to Trond.  I don't think he'=
s sent out the v4.3 pull request yet, but hopefully it won't be too much =
longer!

Perfect, thanks!


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--wvmEDFlIs4eUTRM1mPCGk7HmRnf2p6MKF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJV6Ky4AAoJELgmozMOVy/d5bQP/0wcqrjgarVfQD8R46LYd9KS
bLA/aQq2v+vvwstJnTdeqbz5ZRPDPQhLNfDUOceN+mfWLiLsDQ8X4dzdql87Tdm/
TWw7AefLUld7cSZY5q4psOEUZ6LR4/KvC0GZ6TUEa3NsFMjuzl7v83BUB+iREz3B
QWjEnireK1CZZU6ZYc6CMxM8FL4na7wmyK5vS7DML+Y3ceD6r9LOl47vFCHlUfcU
P4kxdBOHZiwRi6ICiUQE/vpbtMCJsa8EblRsIFORTbTWgppUR3DSCEnkGhnPz4R6
gvMBKzaR0/u3uP59vQZAoBmMCyWUcVqkG7YtYuOsax5XAzI75o+Jx4VdflUtb/DG
WpxO//cInPTfflO5RxMPbaSnRtydKmvGUoQNb2ENUXXh0N83p1a3rn4U86jg4vUq
8PMVrlOSOAiyun7Qvz5DVGRNH50b1srWJ1emxIL9wiK+uRwxCwVsBzfVvTCHqhVv
khdh7Px9xbF+qwDK/fgcQEiIEivKqNkLjnW3U/inz+pqAjEK+yqbi3DyYM6vDauN
wjJRO9gsmWA1e3VnnKixrHvU1QTDocZM5fl0j5K5QNSi4xP6rL83uj5M+EWcSH9S
NDNzlCCqRVbJPQrWdNp8HjiCL979CcDCt0/sqkmO0hwhAJxcjCeu3Bnc8Ogn4C1N
9Fdsl6LQhnZvYAVrADev
=IL6P
-----END PGP SIGNATURE-----

--wvmEDFlIs4eUTRM1mPCGk7HmRnf2p6MKF--
