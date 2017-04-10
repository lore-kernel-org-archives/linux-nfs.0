Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46422 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752940AbdDJVgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Apr 2017 17:36:08 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 11 Apr 2017 07:35:08 +1000
Subject: Re: [PATCH] systemd: nfs-server service should use network-online
In-Reply-To: <e75ecc27-3e53-f643-160a-cdf121518121@RedHat.com>
References: <20170407150738.6200-1-steved@redhat.com> <87shlhxdzq.fsf@notabene.neil.brown.name> <e75ecc27-3e53-f643-160a-cdf121518121@RedHat.com>
Message-ID: <87tw5wvtdf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 10 2017, Steve Dickson wrote:

> On 04/09/2017 09:12 PM, NeilBrown wrote:
>> On Fri, Apr 07 2017, Steve Dickson wrote:
>>=20
>>> There has been an number startup problems where parts of
>>> the NFS server fail to start due to DNS and other
>>> parts of the network not be up.
>>>
>>> Reading the systemd.special it seems network.target is
>>> a passive unit which does not wait and network-online.target
>>> is an active unit which does not wait so that
>>> should be used.
>>=20
>> I assume that last "not" should not be there?
> Right...=20
>>=20
>> According to systemd.special, we should add
>>   Wants=3Dnetwork-online.target
>> though "Requires" is probably OK.
> I did see that... but the bug report said After=3D=20
> worked so I went with that...=20

I think that is dangerous, though obviously not very...

On my openSUSE system,
  systemctl show network-online.target | grep By=3D
only shows
  WantedBy=3Dwinbind.service

If I didn't have winbind installed, nothing would want the .target, so
it wouldn't be activated, so nfs-server wouldn't be ordered with it.

The network still comes up because the services that activate it are
WantedBy=3Dmulti-user.target
so nfs-server will (eventually) work, but there is no guarantee of
ordering.
I think it would be safest to follow the man page and Want or Require
network-online.target, rather than assume that something else will.

Thanks,
NeilBrown


>
>>=20
>> nfs-server.service already has
>>  Requires=3D network.target
>> which you didn't change.
>>=20
>> Also nfs-mountd rpc-statd-notify and rpc.statd all have
>>  After =3D network.target
>>=20
>> They should probably be changed too ??
> yup... good call.
>
> steved.
>
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>>>
>>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=3D1419351
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  systemd/nfs-server.service | 4 ++--
>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
>>> index 5be5de6..7cf4ae0 100644
>>> --- a/systemd/nfs-server.service
>>> +++ b/systemd/nfs-server.service
>>> @@ -7,8 +7,8 @@ Wants=3Drpcbind.socket
>>>  Wants=3Drpc-statd.service nfs-idmapd.service
>>>  Wants=3Drpc-statd-notify.service
>>>=20=20
>>> -After=3D local-fs.target
>>> -After=3D network.target proc-fs-nfsd.mount rpcbind.socket nfs-mountd.s=
ervice
>>> +After=3D local-fs.target network-online.target
>>> +After=3D proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
>>>  After=3D nfs-idmapd.service rpc-statd.service
>>>  Before=3D rpc-statd-notify.service
>>>=20=20
>>> --=20
>>> 2.9.3
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljr+owACgkQOeye3VZi
gbln1g//UX2qz59NQOkfD3C4ehIH5+/icIyS3UFZcXM+vif8fzdvL1cCIUM+8ppG
4qoM+PlUJ3j1mQe219JTO/yzZtOm8LfxVvNYSXlBBsKCgE2FSFa6FahcYC1tGlyg
O6ZPahc3/WxXh701BirjrPTGtnqo02RpcQ5yD7/KzNSP0jHFI2AGy1VHv5xt/Xuj
AoN69y5TdD2LWqgQby89q47Uu7UB8dgZEn4ENwOCrICxPvBij6oT7hQCs3HI87om
LGQovK3aM9QZQG2f5pPnNIfoNjjcYasBcQk6/wMpXLGA+FY3aeO/N3zhAE8Mrqv4
BsJvfeIGZZlrfZj8MOetyV/fPo17IN1VdCS29mPw9lsbBE3FJ5h59VRoQZ/U3PyF
YKdZe2887YUDEuxSdBu6qSFdL2I3QgfgAjud8q0lr/UVY6svwe/CCuamUVfiMSdf
+Cw9MSb/8s9NwV6AcvoyY58SICmaX9GNu2KzwTGHDZ7yK4nJfwgKDr8l1c6FOSjf
WxZ0btsf/Fj9+vTR5Xk1j6F5P4uG2Fv3PL6M+KVhNjrLzcA+6UmsVMCaly2aeUFC
88kv1wa2BUedve1hLtl5p6kcnPyjMiDqfU05Ogs94hS1tjNuKRRK9pUKSCDH7gWD
BaSNsCNLjq6hmVMgsSJYtGt1Y7qfwVOaGxp9Kfh3aXixQ/ywBj0=
=zAge
-----END PGP SIGNATURE-----
--=-=-=--
