Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54223 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751738AbeA2KYB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Jan 2018 05:24:01 -0500
From: NeilBrown <neilb@suse.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 29 Jan 2018 17:07:21 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/20] SUNRPC: add 'struct cred *' to auth_cred and rpc_cred
In-Reply-To: <ea9fad0d-a718-aba8-3dd1-042644577c81@Netapp.com>
References: <151538903497.25812.13293229343061416612.stgit@noble> <151538917875.25812.10005878132438571890.stgit@noble> <ea9fad0d-a718-aba8-3dd1-042644577c81@Netapp.com>
Message-ID: <87zi4x5hba.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 18 2018, Anna Schumaker wrote:

> Hi Neil,
>
> On 01/08/2018 12:26 AM, NeilBrown wrote:
>> The SUNRPC credential framework was put together before
>> Linux has 'struct cred'.  Now that we have it, it makes sense to
>> use it.
>> This first step just includes a suitable 'struct cred *' pointer
>> in every 'struct auth_cred' and almost every 'struct rpc_cred'.
>>=20
>> The rpc_cred used for auth_null has a NULL 'struct cred *' as nothing
>> else really makes sense.
>>=20
>> For rpc_cred, the pointer is reference counted.
>> For auth_cred it isn't.  struct auth_cred are either allocated on
>> the stack, in which case the thread owns a reference to the auth,
>> or are part of 'struct generic_cred' in which case gc_base owns the
>> reference and acred shares it.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
...

>> @@ -669,11 +671,15 @@ rpcauth_bind_root_cred(struct rpc_task *task, int =
lookupflags)
>>  	struct auth_cred acred =3D {
>>  		.uid =3D GLOBAL_ROOT_UID,
>>  		.gid =3D GLOBAL_ROOT_GID,
>> +		.cred =3D get_task_cred(&init_task),
>
> Is there a patch somewhere to add "EXPORT_SYMBOL_GPL(get_task_cred)" to k=
ernel/cred.c?
> I'm getting:=20
>     ERROR: "get_task_cred" [net/sunrpc/sunrpc.ko] undefined!
> when I compile.
>

Thanks for finding that - I don't often compile things as modules :-)
I'll separate out the core cred.[ch] patches, add this, and send those
for an ACK to the relevant maintainer.

thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpuuhkACgkQOeye3VZi
gbkg8RAAnoPigJWKthS10ezFtlobbj3+1IpabFIDIIwbffYkglNGBe/DAQKq5BoR
R/jyQxzgHHqLEYbmqwe02hEKtZhGbQ1Qzf2Ejc+KQUEQU3gjUYdWhU2vPj08alue
jTem9QS6x3qPYgUjA9VdQn5wSf8aiLMTjW8oUeoTN1MAz+mJn062zCR8i8jbAJNG
LmRjrn/ASZqkkj2+S+hbFDj7Mh4JIIf89U5InTnkVOmCyp/DquX+ZNlprEjVxwmH
1TdbqGrjzp0ADhccQwVh0+ONRx0aaXDuGvTV3sa9qpccQZSVvIrARdTnK+y9xX5v
ZZMYJHSvFSKVIQkQ+1Muc7qKREV522qeFTjn4bjLyMv3L4xR9quK0nuul+69sk/C
7Cr3IVMadCoTlLOd9QcVQmh14+V4/uWOlltEVmqVAR9DP/hLDnpjDk2AOD7GKuXJ
3R0cQ3SCxqwRDg+qLKwEXQoXsAzhceSmvGdNzV/itsAJFnLRFj/fCcytqpzI7jaq
NdJD5Td8EcBUI7Uuyq5DDLtyEqr49Ocej5sNPCDxc8Hm71fvpRRDFtPs7a2SjQoK
zoxKAMUVIrDZxt+K2SoNeneq/Rb37y6mLZTfSg3pFnj/nFC9W0UpwKEzNJHQ6Rob
0spael7gYpDnNYUeJbxtazrL5CZaxWrQaz/+i8MRfU0FUBcF4JY=
=HxWl
-----END PGP SIGNATURE-----
--=-=-=--
