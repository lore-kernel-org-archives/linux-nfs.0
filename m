Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36584 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933323AbeCTAKE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 20:10:04 -0400
From: NeilBrown <neilb@suse.com>
To: "Mkrtchyan\, Tigran" <tigran.mkrtchyan@desy.de>
Date: Tue, 20 Mar 2018 11:09:52 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
In-Reply-To: <584484878.12780264.1521192712528.JavaMail.zimbra@desy.de>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name> <878tasc3ag.fsf@notabene.neil.brown.name> <584484878.12780264.1521192712528.JavaMail.zimbra@desy.de>
Message-ID: <87r2ofa9pr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 16 2018, Mkrtchyan, Tigran wrote:

> Hi Neil,
>
> according to rfc5661, NFS4ERR_INVAL is returned by the server if it
> thinks that client sends an invalid request (e.g. points to a client bug)
> or server misinterpret it (broken server).

Agreed.

>
> With your change instead of failing the mount, client will silently go for
> v4.0, even v4.1 mount was requested and produce undesirable behavior, e.g.
> proxy-io instead of pnfs. I fill prefer fail-fast instead of long debug
> sessions.

I don't quite agree.  With my change, the client will behave exactly the
same way as if the server explicitly didn't support v4.1
So if you explicitly ask for v4.1, you will get a fail-fast.
If you ask for "mount with whatever protocol seems to work" (the
default), then you will get a protocol that works - not 4.1 in this
case.

>
> On the other hand, I understand, that it's not always possible to fix ser=
ver
> or clients in production environment and time-to-time workarounds are
> necessary.

Yes.  We are not overly eager to work-around broken implementations, but
my memory is that we do it when it brings measurable benefits without
unreasonable compromises.

In this can I am suggesting that change that results in a user-visible
error of EPROTONOSUPPORT instead of EIO - in a case where the server
doesn't respond to out v4.1 in the way we think it should.  I don't
think there is any compromise there.

Thanks,
NeilBrown


>
>
> Tigran.
>
>
> ----- Original Message -----
>> From: "NeilBrown" <neilb@suse.com>
>> To: "Trond Myklebust" <trond.myklebust@primarydata.com>, "Anna Schumaker=
" <anna.schumaker@netapp.com>
>> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
>> Sent: Friday, March 16, 2018 12:44:23 AM
>> Subject: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
>
>> nfs4_proc_exchange_id() can return -EINVAL if the server
>> reported NFS4INVAL (which I have seen in a packet trace),
>> or nfs4_check_cl_exchange_flags() exchange flags detects
>> a problem.
>> Each of these mean that NFSv4.1 later cannot be use, but
>> they should not prevent fallback to NFSv4.0.
>>=20
>> Currently this EINVAL error is returned by nfs4_proc_exchange_id() to
>> nfs41_discover_server_trunking(), and thence to
>> nfs4_discover_server_trunking().
>> nfs4_discover_server_trunking() doesn't understand EINVAL, so converts
>> it to EIO which causes mount.nfs to think something is horribly wrong
>> and to give up.
>>=20
>> It would be a more graceful failure if nfs4_discover_server_trunking()
>> mapped -EINVAL to -EPROTONOSUPPORT - a failure to negotiate a client
>> ID clearly shows that NFSv4.1 cannot be supported, but isn't as
>> general a failure as EIO.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> Sorry - a bit too trigger-happy with that first version of the patch.
>>=20
>> NeilBrown
>>=20
>> fs/nfs/nfs4state.c | 2 ++
>> 1 file changed, 2 insertions(+)
>>=20
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 91a4d4eeb235..b988e460553d 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -2219,6 +2219,8 @@ int nfs4_discover_server_trunking(struct nfs_clien=
t *clp,
>> 		clnt =3D clp->cl_rpcclient;
>> 		goto again;
>>=20
>> +	case -NFS4ERR_INVAL:
>> +		/* Server confused - assume this minor isn't supported */
>> 	case -NFS4ERR_MINOR_VERS_MISMATCH:
>> 		status =3D -EPROTONOSUPPORT;
>> 		break;
>> --
>> 2.14.0.rc0.dirty

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqwUVEACgkQOeye3VZi
gbl+DA/7BvmwdeUL/rmiT066Tf1MtDeq42XNptIMGRJLMMwa7Sf/tLHN1Uc18jdF
2eJ8FHOgGCQ3u3nrN5+eOK3AYnUJEqRwIP5EeiJEXjU42fO0VtH0FDpljDxeXg5c
G5ipmkZWWX/qjBQuo/ioDnN6lBODsrx5wWqID2syZ8XgUYejtNUw9QOlP5JUpjoe
MwsIr67JU59D/qiau/1TERr7/je3vnhVi9PPN7L+bSLB5EeZmHFQGn8ob6sbLezb
DOqxftAnLRcQJ2g0G/pMAxkyeCiqE6ZUPbk12m91Lc5eEImj6uzoLBBMnnu8vUAO
izmDhGNDAB6WCPCbTAmhWZ0Cr1vLm4XYCs9APQXIsjM6IyCrGJNYLY6MG4hON8A4
aFk2OI/UBH5idt1/1EaCOTuSELlA4iv1HJPHexuarPJuTmbS6zD3gbnWbh+cM0gD
K3RjdhKfpHeqCqlCJQ5RHCNFq4ijpk8/s4nZzid49L8tc+iQTqLaBgXd8buGg9QG
tAOpu2VOViqhHObFRqETbi1u9r5J13GM8H7yWUQqgDegXzOuPY9E8rKbxNye9db0
2g6N03rTHasbKIcsmejgdQuSh/TSL3Wahzz/VjCWM2padi/YDdW/0sPsXj4iTJuD
9OO8vYyvg50q2i4oyzaiFC4PitTTbK6zGDONrhk4JB/8XwpYYUQ=
=fng2
-----END PGP SIGNATURE-----
--=-=-=--
