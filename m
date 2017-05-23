Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43792 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752580AbdEWAwq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 20:52:46 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 23 May 2017 10:52:38 +1000
Subject: Re: [PATCH 1/2] mount.nfs: v4 mounts should fail when -o flag is used.
In-Reply-To: <5a0d2640-ec93-279b-9113-228994283923@RedHat.com>
References: <20170519222510.31205-1-steved@redhat.com> <87inktk2yg.fsf@notabene.neil.brown.name> <5a0d2640-ec93-279b-9113-228994283923@RedHat.com>
Message-ID: <877f18jsx5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, May 22 2017, Steve Dickson wrote:

> On 05/21/2017 11:03 PM, NeilBrown wrote:
>> On Fri, May 19 2017, Steve Dickson wrote:
>>=20
>>> When the pseudo root is set with fsid=3D0, explicit
>>> v4 mounts (via the -o flag) should fail when
>>> the incorrect export is tried instead of rolling
>>> back to v3.
>>=20
>> Hi Steve,
>>  I think this patch makes sense, but the above description doesn't.
>>  Where does fsid=3D0 fit in anywhere here?
> It sets the export to be the pseudo root
>     /home *(rw,fsid=3D0,sec=3Dsys:krb5:krb5i:krb5p)
>
> so when then that export using either -t nfs4 or -o v4
>     mount -o v4.0 127.0.0.1:/home /mnt
>
> the mount should fail instead of rolling back to v3
> Basically its be used to cause the error.=20
>
>>=20
>> I think you want to say
>>=20
>>   When the protocol is set with "-t nfs4", we should behave just like
>>   with do with "-o vers=3D4" and not fall back to v3.
> Actually the first patch fixes the -o vers=3D4 case since
> that too was rolling back to v3 in the above scenario
>=20=20
>>=20
>> Is that what you were really trying to say?
> How about
>
> When the protocol is set the "-o v4" flag,
> and the mount fails due to a pseudo root
> issue, the mount should fail not, roll=20
> back to v3.

Better, but I don't think the pseudo root has any relevance.
If you ask for v4, you should get v4, not v3.  How the server may or may
not behave differently between v3 and v4 is irrelevant.  You should get
what you asked for.

But now that I look at the code again... I don't understand.

You say this is for the "-o v4" case.

In that case, the current code in nfs_nfs_version() will find the "v4"
entry in nfs_version_opttbl[] and set
  version_val =3D "4";
  version->v_mode =3D V_SPECIFIC;
then
  version_major =3D 4;
then as *cptr =3D=3D '\0' and ->major > 4,
  version->v_mode =3D V_GENERAL;

Your change skips that last step so it finished with
   v_mod =3D=3D V_SPECIFIC.

According to the extra comments you have added for the modes:

>>> +	V_GENERAL,     /* single digit =3D> 4 */
>>> +	V_SPECIFIC,    /* single digit < 4 or decimal included */

And it seems to me that "v4" should be V_GENERAL, not V_SPECIFIC.
So I think the current code is correct.

Except... nfs_try_mount() will then call nfs_autonegotiate(),
and nfs_autonegotiate() isn't very consistent about how it
interprets V_GENERAL and V_SPECIFIC.
For EINVAL, it gets the difference right, for other errors it doesn't.

So I think that this is the fix you want:

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0fbb37569ef9..98cf813fe439 100644
=2D-- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -838,9 +838,6 @@ check_result:
 	case EINVAL:
 		/* A less clear indication that our client
 		 * does not support NFSv4 minor version. */
=2D		if (mi->version.v_mode =3D=3D V_GENERAL &&
=2D			mi->version.minor =3D=3D 0)
=2D				return result;
 		if (mi->version.v_mode !=3D V_SPECIFIC) {
 			if (mi->version.minor > 0) {
 				mi->version.minor--;
@@ -862,6 +859,9 @@ check_result:
 		/* UDP-Only servers won't support v4, but maybe it
 		 * just isn't ready yet.  So try v3, but double-check
 		 * with rpcbind for v4. */
+		if (mi->version.v_mode =3D=3D V_GENERAL)
+			/* Mustn't try v2,v3 */
+			return result;
 		result =3D nfs_try_mount_v3v2(mi, TRUE);
 		if (result =3D=3D 0 && errno =3D=3D EAGAIN) {
 			/* v4 server seems to be registered now. */
@@ -878,6 +878,9 @@ check_result:
 	}
=20
 fall_back:
+	if (mi->version.v_mode =3D=3D V_GENERAL)
+		/* v2,3 fallback not allowed */
+		return result;
 	return nfs_try_mount_v3v2(mi, FALSE);
 }
=20


I haven't even compile-tested of course :-)

Thanks,
NeilBrown


>
> steved.
>
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  utils/mount/network.c | 3 ++-
>>>  utils/mount/network.h | 8 ++++----
>>>  2 files changed, 6 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index 281e935..e39263e 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -1299,7 +1299,8 @@ nfs_nfs_version(struct mount_options *options, st=
ruct nfs_version *version)
>>>  		if (!(version->minor =3D strtol(version_val, &cptr, 10)) && cptr =3D=
=3D version_val)
>>>  			goto ret_error;
>>>  		version->v_mode =3D V_SPECIFIC;
>>> -	} else if (version->major > 3 && *cptr =3D=3D '\0')
>>> +	} else if (version->major > 3 && *cptr =3D=3D '\0' &&
>>> +			version->v_mode =3D=3D V_DEFAULT) /* v_mode has not been set */
>>>  		version->v_mode =3D V_GENERAL;
>>>=20=20
>>>  	if (*cptr !=3D '\0')
>>> diff --git a/utils/mount/network.h b/utils/mount/network.h
>>> index 9cc5dec..45e2b24 100644
>>> --- a/utils/mount/network.h
>>> +++ b/utils/mount/network.h
>>> @@ -58,10 +58,10 @@ int clnt_ping(struct sockaddr_in *, const unsigned =
long,
>>>  struct mount_options;
>>>=20=20
>>>  enum {
>>> -	V_DEFAULT =3D 0,
>>> -	V_GENERAL,
>>> -	V_SPECIFIC,
>>> -	V_PARSE_ERR,
>>> +	V_DEFAULT =3D 0, /* not set */
>>> +	V_GENERAL,     /* single digit =3D> 4 */
>>> +	V_SPECIFIC,    /* single digit < 4 or decimal included */
>>> +	V_PARSE_ERR,   /* miss all others */
>>>  };
>>>=20=20
>>>  struct nfs_version {
>>> --=20
>>> 2.9.4
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkjh9YACgkQOeye3VZi
gbkhyBAAhml/ywUWzriJFJt3BRW2jOsgEeER0CwhcgAZ7BZsSGs6qVsalplnyVAs
RtvKqfwb9vqoJ3E6mZFGkLE65/L6BLOECGFYe+PQuWzIYYQbQfRjA+iFsBL0fFmx
4mzu3W+O6QZjpnDA4xq2ABPulS7TGGFNmx9rDPDW5SIIRYQS70qxg2bwQx9P74Py
L5kKxd7BggC0+CRdzbnD00qVLHXnWlpuLwa5hYMxsvWKeS4/KuzlvvjrSQWISIeH
RF7ENpys8T9TC7Oj+JGgJvyIRFmAZJxdPrZFeyVMEPcRmsE1uYxJWlwVuadxGHob
O4ihmYAOQBW7wJwGmsNWS1AwZKNO6qi9ojmSNfv7B43LzYGv6Kfty9Nx6NUGrXm+
UpgRYF5oyrka+UjGUSk7gE1dSD9mSJA/C26618yTc09+0y68VICyDx6g5+geQKsk
sIs0404Fft1nNnn2qJ1J1rHtC9Jd+vvZ8C57xqdcbie+kGZfXPxciDHTgLfFioDD
QhJAIQQKeYchaaQFyDLUm0xgOjlVFgNhRJyTLbrgg46rpDS7Lf0uSwKu7TssUG9q
otblMHlNE5O83u2tzpoNVwyzbhMiNx8UDxfZcb4nr8Wt3sO93FOj4UQdU2wiROqs
GLgI77vFdr5c+PTgoibObOEna+0v4w0G9krNX8qamvZTYhaNgnM=
=SK0K
-----END PGP SIGNATURE-----
--=-=-=--
