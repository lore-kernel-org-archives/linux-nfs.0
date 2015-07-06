Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate-01.zdv.uni-mainz.de ([134.93.178.241]:49043 "EHLO
	mailgate-01.zdv.uni-mainz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445AbbGFM7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 08:59:47 -0400
Message-ID: <559A7BBF.2080201@uni-mainz.de>
Date: Mon, 6 Jul 2015 14:59:43 +0200
From: Christoph Martin <martin@uni-mainz.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Andy Adamson <andros@netapp.com>, Markus Tacke <tacke@uni-mainz.de>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] make nfsd_drc_max_mem configurable
References: <55816C84.1080608@uni-mainz.de> <20150618161657.GC10305@fieldses.org>
In-Reply-To: <20150618161657.GC10305@fieldses.org>
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature";
	boundary="9DfHVrqf568vCgnNwhr56VteKn9uu8ekQ"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--9DfHVrqf568vCgnNwhr56VteKn9uu8ekQ
Content-Type: multipart/mixed;
 boundary="------------020905050102060508080200"

This is a multi-part message in MIME format.
--------------020905050102060508080200
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi Bruce,

Am 18.06.2015 um 18:16 schrieb J. Bruce Fields:
>=20
>> The first time we wanted to setup a NFS Server for our HPC cluster. We=

>> were wondering why we were only able to mount the filesystem on 380 of=

>> our ~700 nodes. It took us a long time to find out that it was the lim=
it
>> of the NFS4.1 session cache. Since this machine had 12G Ram, the kerne=
l
>> reserved 12M for the cache, which results in 384 slots a 32k:
>>
>> echo $(((12582912>>10)/32))
>> 384
>=20
> So each client is using 32k?

#define NFSD_SLOT_CACHE_SIZE		2048
/* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session */
#define NFSD_CACHE_SIZE_SLOTS_PER_SESSION	32
#define NFSD_MAX_MEM_PER_SESSION  \
		(NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NFSD_SLOT_CACHE_SIZE)

So this would be 64k. Maybe I missed a factor of 2 somewhere. But the
calculation above equals the experience in our tests.

>=20
> Might be interesting to take a look at the CREATE_SESSION call and repl=
y
> in wireshark (especially the values of maxresponsesize_cached and
> maxrequests)--there might also be defaults there that need tweaking.
>=20
>> We patched the kernel redhat 7 kernel to change NFSD_DRC_SIZE_SHIFT to=

>> from 10 to 7 to fix this problem.
>>
>> The second time we installed a small Debian VM with 1G ram to act as a=

>> NFS4 referral server for the home and group directories on our campus.=

>> Since the server does only NFS referrals it does not really need more
>> memory than the 1G. But it could only server about 30 clients with thi=
s
>> limitation of the session cache.
>>
>> I think it would be a good idea to have the amount of memory
>> configurable in nfsd. So I wrote this small patch to make drc_size
>> configurable while loading the kernel nfsd module.
>>
>> The patch uses the old value computed from NFSD_DRC_SIZE_SHIFT as the
>> lower limit. If drc_size as a parameter for then nfsd is higher than a=

>> 1/1000 of the RAM, this value will be used.
>>
>> One might consider to make NFSD_DRC_SIZE_SHIFT even higher to use less=

>> memory for situations where it is not needed. I did not implement an
>> upper limit, but it might be important.
>>
>> Please consider to include this patch into the nfsd code.
>=20
> Looks good,=20

As far as I understand the code now, it would even be possible to change
the value of nfsd_drc_max_mem during runtime of nfsd, since the value is
only used in nfsd4_get_drc_mem in nfs4state.c. I don't see that the
limit is on the slab. It seems only to be on the local usage of the slab.=


> my one concern is that this covers only the size of the 4.1
> session cache.  We may need to add some more limits in the future and
> might not want to require separate configuration of each limit.
>=20
> Maybe one or two more generic size parameters would be more useful?
> Like:
>=20
> 	- Maximum memory to devote to knfsd
> 	- Maximum memory to devote to a single client
>=20

We were discussing this and don't think that this is a good idea.

If you have only one limit per knfsd or client, you don't know how many
memory you have to assign to the different memory slabs, like drc or
others, because you can't know in advance if the nfs server is only used
for say nfs3 or nfs4 or nfs4.1 or a mixture.

So if you think it is necessary to have a global limit, you also need
tunabels for the distribution of the available memory to the different
protocols.

I found the following calls to kmem_cache_create:

>=20
> nfs4state.c:2635:	openowner_slab =3D kmem_cache_create("nfsd4_openowner=
s",
> nfs4state.c:2639:	lockowner_slab =3D kmem_cache_create("nfsd4_lockowner=
s",
> nfs4state.c:2643:	file_slab =3D kmem_cache_create("nfsd4_files",
> nfs4state.c:2647:	stateid_slab =3D kmem_cache_create("nfsd4_stateids",
> nfs4state.c:2651:	deleg_slab =3D kmem_cache_create("nfsd4_delegations",=

> nfscache.c:168:	drc_slab =3D kmem_cache_create("nfsd_drc", sizeof(struc=
t svc_cacherep),

At a first look, they all use different methods to administer this
memory if at all.

Yours
Christoph

--------------020905050102060508080200
Content-Type: text/x-vcard; charset=utf-8;
 name="martin.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="martin.vcf"

begin:vcard
fn:Christoph Martin
n:Martin;Christoph
email;internet:martin@uni-mainz.de
tel;work:+49-6131-3926337
tel;fax:+49-6131-3926407
tel;cell:+49-179-7952652
version:2.1
end:vcard


--------------020905050102060508080200--

--9DfHVrqf568vCgnNwhr56VteKn9uu8ekQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJVmnvAAAoJEPqBswqWsQmcu0YP/3VmJm45C+p0HZV10npUNVmn
wVCv6RZ2oo2PtAEyw9MSmfNS1fptRwJrSPJR4n7MeeV9JoxISzn7FbZ5b+cU93AF
B6ugVFhuH54abW5+h1qXo7KOuLoWkfgLo6Hy4OC6ID3V96tHoinoA8RacZTt95LQ
6kz5I1JIcDaUY9yjv5Yql1E6QDWTe0LZlwxIWz5owRB+TNKu9jQvYa9Z6doov0YP
cWKoiqeNa/e5UnKpRshL/c6RQmEC96RvNdpIodEcztBk1ylqD37m59C7RjaCqA1U
0Ba7qTGl5fTZuzZhN9eQxTN1OBxux/Z3K2V4EiOakT9JoGu2uaw2F1uqOpLFkkyD
LQg/NiLy+EMMYE+NnCGltes5Vg8Rb6Nzj2pQpIqJwv0ewBxBpv5E9uagLpBneVtC
Wr2rTktVNlcysOCcHk6kjP36ko/xBUB7jKx67ZDNmRvTizqqXIrIxlJ38qamgGDW
V9OJi2P+lJW9HqgfSMHeqI/k8nQck21vaqzIDPGGYL2fZ4djSJ3WRaeZdWO8bHIl
DErA3MP4eegJL5Y5XmnpJZV7aEqlBqNx0hpXW21YKPELID0KMWjSxaizjosvvbsQ
LGlJVvi+C7utpfIE9ZZbmkearg9l8XBHegfYptaq7DmpMEcSVaCxzERLuauIT0nY
Lvyu/ggEsdMY5suLA2HA
=Vq4n
-----END PGP SIGNATURE-----

--9DfHVrqf568vCgnNwhr56VteKn9uu8ekQ--
