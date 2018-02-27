Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33685 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751721AbeB0UtL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Feb 2018 15:49:11 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Wed, 28 Feb 2018 07:49:01 +1100
Subject: Re: [PATCH 1/1] mount.nfs: minorversion setting is being ignored with -t flag
In-Reply-To: <517662da-56b9-5a41-7e3f-25431ced819b@RedHat.com>
References: <20180226191542.31447-1-steved@redhat.com> <20180226191542.31447-2-steved@redhat.com> <87zi3vgoza.fsf@notabene.neil.brown.name> <517662da-56b9-5a41-7e3f-25431ced819b@RedHat.com>
Message-ID: <87woyygnuq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 27 2018, Steve Dickson wrote:

> On 02/26/2018 09:12 PM, NeilBrown wrote:
>> On Mon, Feb 26 2018, Steve Dickson wrote:
>>=20
>>> mount -t nfs or mount -t nfs4 and setting minorversion
>>> should set the v4 minor version. This patch adds a few
>>> checks to make sure the minor version is set.
>>>
>>> The patch also translate the minorversion=3D option
>>> to vers=3D4.x in the arguments passed to the kernel.
>>>
>>=20
>> If you do this, then you break compatibility with v3.4 and earlier.
>> (anything without Commit: 0d71b058092f ("NFS: Extend the -overs=3D mount
>> option to allow 4.x minorversions")).
> Yeah... I did realized that...=20
>>=20
>> Maybe that is OK, but I think that fact should be clearly stated in the
>> commit log, and preferably the configure script should warn if you try
>> to build on an unsupported kernel.Well I just took a look and it's easy =
enough to put
> a kernel version check in... We do that all over the mount code.
>>=20
>> Do we have any sort of policy on the oldest kernel the nfs-utils still
>> supports?  Should we?
> No... and IDK... I think it is more of a compilation issue.=20
> Getting the code to compile on older systems is not easy.
> You have to disable a number features as well as hack up
> the configure.ac file.=20
>
> Question, do packages like glibc have these types of policies?

glibc documents in README the minimum kernel version.
In Apr 2014 it was raised to 2.6.32.
In Map 2017 it was raised to 3.2
Though some archs have different rules
  git grep arch_minimum_kernel sysdeps
in the glibc source.

systemd also sets a minimum, currently:
REQUIREMENTS:
        Linux kernel >=3D 3.13
        Linux kernel >=3D 4.2 for unified cgroup hierarchy support

according to README.

So if we want to require 3.5 or later, then I have not problem with
that.
I just think it should be clearly announced in the git commit, and
documented in a README or similar.

Thanks,
NeilBrown


>
> steved.=20
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  utils/mount/network.c | 15 ++++++++++-----
>>>  utils/mount/stropts.c | 14 ++++++++++++++
>>>  2 files changed, 24 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index 8ab5be8..8d6e4c6 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -1275,8 +1275,8 @@ nfs_nfs_version(char *type, struct mount_options =
*options, struct nfs_version *v
>>>  		}
>>>  	}
>>>=20=20
>>> -	if (!found && strcmp(type, "nfs4") =3D=3D 0)
>>> -		version_val =3D type + 3;
>>> +	if (!found && strncmp(type, "nfs", 3) =3D=3D 0)
>>> +		version_val =3D "4";
>>>  	else if (!found)
>>>  		return 1;
>>>  	else if (i <=3D 2 ) {
>>> @@ -1308,9 +1308,14 @@ nfs_nfs_version(char *type, struct mount_options=
 *options, struct nfs_version *v
>>>  		if (!(version->minor =3D strtol(version_val, &cptr, 10)) && cptr =3D=
=3D version_val)
>>>  			goto ret_error;
>>>  		version->v_mode =3D V_SPECIFIC;
>>> -	} else if (version->major > 3 && *cptr =3D=3D '\0')
>>> -		version->v_mode =3D V_GENERAL;
>>> -
>>> +	} else if (version->major > 3 && *cptr =3D=3D '\0') {
>>> +		version_val =3D po_get(options, "minorversion");
>>> +		if (version_val !=3D NULL) {
>>> +			version->minor =3D strtol(version_val, &cptr, 10);
>>> +			version->v_mode =3D V_SPECIFIC;
>>> +		} else=20
>>> +			version->v_mode =3D V_GENERAL;
>>> +	}
>>>  	if (*cptr !=3D '\0')
>>>  		goto ret_error;
>>>=20=20
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 777de39..6bbfd71 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -767,6 +767,20 @@ static int nfs_do_mount_v4(struct nfsmount_info *m=
i,
>>>  			mi->version.minor);
>>>  #pragma GCC diagnostic warning "-Wformat-nonliteral"
>>>=20=20
>>> +		if (po_append(options, version_opt) =3D=3D PO_FAILED) {
>>> +			errno =3D EINVAL;
>>> +			goto out_fail;
>>> +		}
>>> +	} else if (po_get(options, "minorversion")) {
>>> +		/*
>>> +	 	 * convert minorversion=3D into vers=3D4.x
>>> +	 	 */
>>> +		po_remove_all(options, "minorversion");
>>> +
>>> +		snprintf(version_opt, sizeof(version_opt) - 1,
>>> +			"vers=3D%lu.%lu", mi->version.major,
>>> +			mi->version.minor);
>>> +
>>>  		if (po_append(options, version_opt) =3D=3D PO_FAILED) {
>>>  			errno =3D EINVAL;
>>>  			goto out_fail;
>>> --=20
>>> 2.14.3
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqVxD4ACgkQOeye3VZi
gbkpuw//al6Uih2KL+nhB2XQk7xfE/lDICqpAo3QNE0wfsnssxOPpchGv+TSz/Kp
7cbmAWapl17DIh+/sst7703+kaUQ72MlcbdGEgpAALmPobwWM4yoC1l5U+zICgLN
si4hRixnnhT9CvIc/k7uer9sCmldv/R0sz3DxcU2nQ2PlbxgN9cUfSx8LJDgrIeH
J3/RacHV0UzbYUbCyYuYoqEYO3Th9qqxHCzaV1KVGaSIjteefYErYrjUBXMkZWad
1zszBhB/hLrJN4UrqrHf/JhKTToLGlAkm0p7JBLEOVLA1wSUANNd/xXrDZSK2Wo1
9ovEKRH9vLC2yQyPbSjyLTLgu1cSwfsl0NJdaa+KAAueftonA6Vk4a+NCzfCLYx9
dC/bPtC0nrUMXf2R2zttpPqRmMtgCYX9iq1JwzbS99LZ+r1yhBPfxvd/FbLRijN7
MTaVcf4lIwDe3c7/wy98Cv+cKRs1qIb994hgO6/3hCp4rkC2FTxY9dn18A5ISWJ8
SkQYM+6CvM1G57aUx9Tof1coHXNlbe/YkvNdcawsVTRVQUL9zIOtqCHsBso8aWn+
JNYtXiUoM8ReoIODf+KKJUiKVH6eBy4LHvpq6U1cfemwS5B6wWuebLfsW410pOK4
N4DtF97OhRG2F3HwDhCYZpSuOSt2sI4SuYA9q4qhinBzZ3N1xn0=
=0mZA
-----END PGP SIGNATURE-----
--=-=-=--
