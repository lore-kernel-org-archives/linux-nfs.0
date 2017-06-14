Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51507 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753646AbdFNCJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 22:09:51 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Wed, 14 Jun 2017 12:09:42 +1000
Subject: Re: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is specified
In-Reply-To: <5881a561-2433-d0e2-c91a-684f3bd1b22d@RedHat.com>
References: <20170609132608.12213-1-steved@redhat.com> <20170609132608.12213-2-steved@redhat.com> <87poe88z1e.fsf@notabene.neil.brown.name> <5881a561-2433-d0e2-c91a-684f3bd1b22d@RedHat.com>
Message-ID: <87wp8f721l.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 13 2017, Steve Dickson wrote:

> Sorry I didn't see your entire response=20
> the first time around...
>
> On 06/12/2017 09:19 PM, NeilBrown wrote:
>> On Fri, Jun 09 2017, Steve Dickson wrote:
>>=20
>>> When v4 is specified on the command line the
>>> default minor version needs to be used.
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  utils/mount/stropts.c | 27 ++++++++++++++++++++-------
>>>  1 file changed, 20 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 81fb945..d2d303f 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount_i=
nfo *mi)
>>>  	if (mi->version.v_mode =3D=3D V_DEFAULT &&
>>>  		config_default_vers.v_mode !=3D V_DEFAULT) {
>>>  		mi->version.major =3D config_default_vers.major;
>>> -		mi->version.minor =3D config_default_vers.minor;
>>> +		if (config_default_vers.minor)
>>> +			mi->version.minor =3D config_default_vers.minor;
>>> +		else if (!mi->version.minor)
>>> +			mi->version.minor =3D NFS_DEFAULT_MINOR;
>>=20
>> No, this looks wrong.  A minor number of '0' can be perfectly valid.
>> Deciding to turn a minor of '0' into '2' is simply wrong.
> Please see my first response. Basically if the minor version
> is not set, the set it to the default version.

You are testing config_default_vers.minor without first confirming that
config_default_vers.v_mode is V_SPECIFIC.  I don't see how that makes
sense.

We should use major/minor values out of config_default_vers based on its
v_mode, not on whether the values are zero or not.

If v_mode =3D=3D V_DEFAULT, don't use anything
If v_mode =3D=3D V_GENERAL, use the major, not the minor
If v_mode =3D=3D V_SPECIFIC, use major and minor (though minor is irrelevant
                        if major !=3D 4)

>
>>=20
>> You can only tell if .minor is valid by looking at .v_mode.
>> If .v_mode is V_GENERAL or V_DEFAULT, then .minor is not valid
>> and a default should be used.  If it is V_SPECIFIC, then .minor is
>> either valid or irrelevant, depending on .major.
>>=20
>>=20
>>>  		return;
>>>  	}
>>>=20=20
>>>  	if (mi->version.v_mode =3D=3D V_GENERAL) {
>>>  		if (config_default_vers.v_mode !=3D V_DEFAULT &&
>>> -		    mi->version.major =3D=3D config_default_vers.major)
>>> -			mi->version.minor =3D config_default_vers.minor;
>>> +		    mi->version.major =3D=3D config_default_vers.major) {
>>> +			if (mi->version.minor)
>>> +				mi->version.minor =3D config_default_vers.minor;
>>=20
>> Again, don't test version.minor like this.
> You have to... For the -o minorversion=3D1 cast.
> If the minor is already set, don't reset it.

"-o minorversion=3D1" causes "v_mode =3D V_SPECIFIC" (in nfs_nfs_version()).
This isn't a case that is of any concern in nfs_default_version().

>
>>=20
>>> +			else if (!mi->version.minor)
>>> +				mi->version.minor =3D NFS_DEFAULT_MINOR;
>>> +		} else if (!mi->version.minor)
>>> +			mi->version.minor =3D NFS_DEFAULT_MINOR;
>>>  		return;
>>>  	}
>>>=20=20
>>> @@ -740,10 +748,15 @@ static int nfs_do_mount_v4(struct nfsmount_info *=
mi,
>>>  	}
>>>=20=20
>>>  	if (mi->version.v_mode !=3D V_SPECIFIC) {
>>> -		if (mi->version.v_mode =3D=3D V_GENERAL)
>>> -			snprintf(version_opt, sizeof(version_opt) - 1,
>>> -				"vers=3D%lu", mi->version.major);
>>> -		else
>>> +		if (mi->version.v_mode =3D=3D V_GENERAL) {
>>> +			if (mi->version.major > 3)
>>=20
>> This test is pointless as .v_mode is only ever V_GENERAL when
>>  .major =3D=3D 4
>>=20
>> And given that this is nfs_do_mount_v4(), we can be certain that
>> version.major =3D=3D 4.
>>=20
>> Prior to
>> Commit: 0d71b058092f ("NFS: Extend the -overs=3D mount option to allow 4=
.x minorversions")
>>=20
>> in Linux 3.4, writing "vers=3D4.1" wasn't supported.
>> So I think it would be safest to use
>>   vers=3D4                   if minor =3D=3D 0
> I'm thinking if you don't specify the minor version
> the default minor version should be used.=20

Yes, but I'm talking about how you tell the kernel that.
At this point in the code a choice has been made about what major/minor
to use.  Negotiation is happening at a higher level and here we just
need to tell the kernel the current choice.
If v_mode =3D=3D V_SPECIFIC, we don't do anything because the options passed
to mount.nfs are pass through to the kernel unchanged.
In other cases we need to create a kernel option to request
a specific version.
  vers=3D4
will always choose v4.0, in any kernel that supports it.  On some
kernels, "vers=3D4.0" won't work.
  vers=3D4,minorversion=3D1
will always choose v4.1 in any kernel that supports it.
  vers=3D4.2
will always choose v4.2 if supported.

So I think those are the options we should use.

>
> Again, I'm thinking there should be no difference
> between -t nfs4, -o vers=3D4, -o nfsvers=3D4 and -o v4.
> They all should become v4.2 mounts

They should on current kernels if the server supports it.  On older
kernels, or with older servers, they might become v4.1 or v4.0.
We need to make sure the way we tell the kernel what version to use,
works on the widest possible range of kernels.

Thanks,
NeilBrown


>
> This mean the only way to not used the default version
> is to specify it.
>
>>   vers=3D4,minorversion=3D1    if minor =3D=3D 1
>>   vers=3D4.2                 if minor =3D=3D 2
>>=20
>> This is despite the fact that the comment in the kernel says
>>                                                   In future,
>>                  * the mount program should always supply
>>                  * a NFSv4 minor version number.
> I agree...=20
>
>>=20
>> I think vers=3D4.%d is appropriate for v4.2 and later, but not for earli=
er
>> versions.
>>=20
>> Alternately we could test the kernel version and behave differently, but
>> I think that is worse.
> Yeah we have a few MAKE_VERSION() sprinkle though the legacy code=20
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>> +				snprintf(version_opt, sizeof(version_opt) - 1,
>>> +					"vers=3D%lu.%lu", mi->version.major,
>>> +					mi->version.minor);
>>> +			else=20
>>> +				snprintf(version_opt, sizeof(version_opt) - 1,
>>> +					"vers=3D%lu", mi->version.major);
>>> +		} else
>>>  			snprintf(version_opt, sizeof(version_opt) - 1,
>>>  				"vers=3D%lu.%lu", mi->version.major,
>>>  				mi->version.minor);
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllAmugACgkQOeye3VZi
gbnYJRAAwIUA1HLIR1/+2hdn2OEIh3X3W0J7Efo70Fs7SqecrBDVZbjR2Boh6Rzg
N2GYn/yKX624szmVG/qd4eb8CHY3Pwg9BTE1GeNH8QFgSFBU/SY/pRuNgtVzVSsH
rJXAOFkeztBkl1b+OWDqXIzUlfSJZf+G1yJNoLdEIIbWnoyV4oEWEsez4LX8chgq
/Ry+Q5p13gqm6lt8BDNDH4+MZvGR2G41Ir6Exd4Buhz/r2nzpKo5bhmjdKVh7RWI
Mk/P+vQhAX6z8RJ8TYQRyMV8mNyZ7Zwx2x4nGvGVFfuTVj/bUJAP9/BYjeobzxbL
efKJ+b2+QZtUZNZNj7G62+GXUaSGf0cLVkzTOi7GFO5D36rMvMTtjxwMNePGs0xR
lfR92yHwCNkFyc9e+1OEuACuLZ++jasFwhydE7QipsIKuDFKASLalffIItqH0/ke
OzfXqIYLA+gUrGUCUw3XomyspDN9nDL0MeZu3wY2Jinwes9ZV7lRkFd0l+N2A4W9
CeQONRTkA0gYsuXNVeqLoFVdSMygGFKD4fUbhnwXJ+DvbAc8dN7Pdzm30ETK28Ie
iSNl7RvwZ36VOrYARJIWoyrJDgwXuOmPU2luONcvFh2XePe2P0l+VtpnhRHny7wq
6XBjcmU55ciCoW7h9MzadY+efb7Op1PrlVxOlgsoGPa//evJOTs=
=Zdb8
-----END PGP SIGNATURE-----
--=-=-=--
