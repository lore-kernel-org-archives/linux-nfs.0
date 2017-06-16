Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59242 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751923AbdFPDUa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Jun 2017 23:20:30 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Fri, 16 Jun 2017 13:20:20 +1000
Subject: Re: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is specified
In-Reply-To: <0b850e57-b4a7-fae5-ba29-69ffde0c3db2@RedHat.com>
References: <20170609132608.12213-1-steved@redhat.com> <20170609132608.12213-2-steved@redhat.com> <87poe88z1e.fsf@notabene.neil.brown.name> <5881a561-2433-d0e2-c91a-684f3bd1b22d@RedHat.com> <87wp8f721l.fsf@notabene.neil.brown.name> <0b850e57-b4a7-fae5-ba29-69ffde0c3db2@RedHat.com>
Message-ID: <87a8587h57.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 14 2017, Steve Dickson wrote:

> On 06/13/2017 10:09 PM, NeilBrown wrote:
>> On Tue, Jun 13 2017, Steve Dickson wrote:
>>=20
>>> Sorry I didn't see your entire response=20
>>> the first time around...
>>>
>>> On 06/12/2017 09:19 PM, NeilBrown wrote:
>>>> On Fri, Jun 09 2017, Steve Dickson wrote:
>>>>
>>>>> When v4 is specified on the command line the
>>>>> default minor version needs to be used.
>>>>>
>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>>> ---
>>>>>  utils/mount/stropts.c | 27 ++++++++++++++++++++-------
>>>>>  1 file changed, 20 insertions(+), 7 deletions(-)
>>>>>
>>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>>> index 81fb945..d2d303f 100644
>>>>> --- a/utils/mount/stropts.c
>>>>> +++ b/utils/mount/stropts.c
>>>>> @@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount=
_info *mi)
>>>>>  	if (mi->version.v_mode =3D=3D V_DEFAULT &&
>>>>>  		config_default_vers.v_mode !=3D V_DEFAULT) {
>>>>>  		mi->version.major =3D config_default_vers.major;
>>>>> -		mi->version.minor =3D config_default_vers.minor;
>>>>> +		if (config_default_vers.minor)
>>>>> +			mi->version.minor =3D config_default_vers.minor;
>>>>> +		else if (!mi->version.minor)
>>>>> +			mi->version.minor =3D NFS_DEFAULT_MINOR;
>>>>
>>>> No, this looks wrong.  A minor number of '0' can be perfectly valid.
>>>> Deciding to turn a minor of '0' into '2' is simply wrong.
>>> Please see my first response. Basically if the minor version
>>> is not set, the set it to the default version.
>>=20
>> You are testing config_default_vers.minor without first confirming that
>> config_default_vers.v_mode is V_SPECIFIC.  I don't see how that makes
>> sense.
> Well at this point we know the config_default v_mode is either=20
> V_SPECIFIC or V_GENERAL.=20

Yes.
If v_mode=3D=3DV_GENERAL then minor=3D=3D0, but that doesn't mean anything.
If v_mode=3D=3DV_SPECIFIC and minor=3D=3D0, it means that v4.0 was explicit=
ly requested.

>>=20
>> We should use major/minor values out of config_default_vers based on its
>> v_mode, not on whether the values are zero or not.
>>=20
>> If v_mode =3D=3D V_DEFAULT, don't use anything
>> If v_mode =3D=3D V_GENERAL, use the major, not the minor
> How can't we use the minor if its v4... The whole point of
> these patches is to used the default minor when v4 is used.

If v_mode=3D=3DV_GENERAL, then the minor doesn't mean anything.  It will
happen to be zero, but it is safer to think of it as undefined.

Just to check what you want:
 If someone mounts with "-t nfs4" or "-o v4" or "-o vers=3D4" and
 nfsmount.conf contains "vers=3D4.1" then you want it to default to
 try 4.1, then fallback to 4.0
 But if nfsmount.conf contains "vers=3D4.0", you want to try
 4.0, and not fall back to anything.
 If nfsmount.conf contains "vers=3D4", you want to try 4.2 first (because
 that is NFS_DEFAULT_MINOR), then fall back to 4.1, then 4.0

 Is that correct (seems reasonable to me)?

We know that the user requested one of those because mi->version.v_mode =3D=
=3D
V_GENERAL.
Then if config_default_vers.v_mode =3D=3D V_SPECIFIC and major=3D=3D4, we
want to copy .minor in.  Otherwise we use NFS_DEFAULT_MINOR.


>
>> If v_mode =3D=3D V_SPECIFIC, use major and minor (though minor is irrele=
vant
>>                         if major !=3D 4)
>>=20
>>>
>>>>
>>>> You can only tell if .minor is valid by looking at .v_mode.
>>>> If .v_mode is V_GENERAL or V_DEFAULT, then .minor is not valid
>>>> and a default should be used.  If it is V_SPECIFIC, then .minor is
>>>> either valid or irrelevant, depending on .major.
>>>>
>>>>
>>>>>  		return;
>>>>>  	}
>>>>>=20=20
>>>>>  	if (mi->version.v_mode =3D=3D V_GENERAL) {
>>>>>  		if (config_default_vers.v_mode !=3D V_DEFAULT &&
>>>>> -		    mi->version.major =3D=3D config_default_vers.major)
>>>>> -			mi->version.minor =3D config_default_vers.minor;
>>>>> +		    mi->version.major =3D=3D config_default_vers.major) {
>>>>> +			if (mi->version.minor)
>>>>> +				mi->version.minor =3D config_default_vers.minor;
>>>>
>>>> Again, don't test version.minor like this.
>>> You have to... For the -o minorversion=3D1 cast.
>>> If the minor is already set, don't reset it.
>>=20
>> "-o minorversion=3D1" causes "v_mode =3D V_SPECIFIC" (in nfs_nfs_version=
()).
>> This isn't a case that is of any concern in nfs_default_version().
> True..=20
>>>
>>>>
>>>>> +			else if (!mi->version.minor)
>>>>> +				mi->version.minor =3D NFS_DEFAULT_MINOR;
>>>>> +		} else if (!mi->version.minor)
>>>>> +			mi->version.minor =3D NFS_DEFAULT_MINOR;
>>>>>  		return;
>>>>>  	}
>>>>>=20=20
>>>>> @@ -740,10 +748,15 @@ static int nfs_do_mount_v4(struct nfsmount_info=
 *mi,
>>>>>  	}
>>>>>=20=20
>>>>>  	if (mi->version.v_mode !=3D V_SPECIFIC) {
>>>>> -		if (mi->version.v_mode =3D=3D V_GENERAL)
>>>>> -			snprintf(version_opt, sizeof(version_opt) - 1,
>>>>> -				"vers=3D%lu", mi->version.major);
>>>>> -		else
>>>>> +		if (mi->version.v_mode =3D=3D V_GENERAL) {
>>>>> +			if (mi->version.major > 3)
>>>>
>>>> This test is pointless as .v_mode is only ever V_GENERAL when
>>>>  .major =3D=3D 4
>>>>
>>>> And given that this is nfs_do_mount_v4(), we can be certain that
>>>> version.major =3D=3D 4.
>>>>
>>>> Prior to
>>>> Commit: 0d71b058092f ("NFS: Extend the -overs=3D mount option to allow=
 4.x minorversions")
>>>>
>>>> in Linux 3.4, writing "vers=3D4.1" wasn't supported.
>>>> So I think it would be safest to use
>>>>   vers=3D4                   if minor =3D=3D 0
>>> I'm thinking if you don't specify the minor version
>>> the default minor version should be used.=20
>>=20
>> Yes, but I'm talking about how you tell the kernel that.
>> At this point in the code a choice has been made about what major/minor
>> to use.  Negotiation is happening at a higher level and here we just
>> need to tell the kernel the current choice.
>> If v_mode =3D=3D V_SPECIFIC, we don't do anything because the options pa=
ssed
>> to mount.nfs are pass through to the kernel unchanged.
> Fine...=20
>
>> In other cases we need to create a kernel option to request
>> a specific version.
>>   vers=3D4
>> will always choose v4.0, in any kernel that supports it.  On some
>> kernels, "vers=3D4.0" won't work.
> which ones don't support v4.0?=20
>

Everything prior to
 Commit: 0d71b058092f ("NFS: Extend the -overs=3D mount option to allow 4.x=
 minorversions")

in Linux 3.4.

>>   vers=3D4,minorversion=3D1
>> will always choose v4.1 in any kernel that supports it.
>>   vers=3D4.2
>> will always choose v4.2 if supported.
>>=20
>> So I think those are the options we should use.
> I guess I don't see how we can test what a kernel can
> or can not support... It has to be an assumption.
> Does it have to be dynamic? Meaning and the mount
> command be tailored to a particular kernel?=20=20=20

The mount command doesn't need to be tailored because the
kernel is, fortunately, backward compatible.
Each of
  vers=3D4
  vers=3D4,minorversion=3D1
  vers=3D4.2

will work correctly on all kernels which support that particular minor
version.


>>=20
>>>
>>> Again, I'm thinking there should be no difference
>>> between -t nfs4, -o vers=3D4, -o nfsvers=3D4 and -o v4.
>>> They all should become v4.2 mounts
>>=20
>> They should on current kernels if the server supports it.  On older
>> kernels, or with older servers, they might become v4.1 or v4.0.
>> We need to make sure the way we tell the kernel what version to use,
>> works on the widest possible range of kernels.
> So you are talking about using a new nfs-utils on a older kernel?

Correct.

> Is that something that is done?

We have to assume that it is. We don't necessarily need to test all the
combinations, but we need to make a reasonable effort to support
all kernels which have the functionality requested.
The only alternative is to put some sort of rule in the configure
script so that it refuses to compile on old kernels, but I think that
should be a last-resort.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIyBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllDTnYACgkQOeye3VZi
gbllVA/4hbFO56AwEd0OBOuQRyN6q1obTNwDazI5EZ2TjHOsJzfHtP42IeSeWmec
Q2qV0LzauDHrUHLHbY+Jgp3DNODtzYWbvcXhYZjGhf3wKCtpQ3WiKxseIGTZyo3a
2Y1CTWOOVAlIep/j86gCsgSs8HPbf+exkC0t0tNivPZZPZHAQihEXhu5Sn7jdQsN
8OnanLX+ov5UhqjKdu6g+pfI1hmVS/y7YEzYUE2iE0Omns0IZNdHS6YHFw/ljoES
eIgi5+Y5zpMtqvmraOWu9+XrdGjCnCexpsxtdCT4yuyjU3AQtbA+kjeMytK+JmXn
sEFVISbUmeqvearSPuO0BsBQTADfSLNIvD87PG9CwaaqmVa0RAmx5dfI2X81xnTs
UZynlg3KMjCUCHyYEMnNB/3AK7ZvDWSn8EIIPBjkzc72ZeHtwdnTNJr1m+O4951m
gZIbUhJv9v5I0NVQz6CfMss0b9V+tWlOIwMXTMRgE6LDlGY1Za0O10MWgzH60GkP
pFqaNMEFgMwOBhzdHDO/9ioMVWgqIP4Eh8GB9CXEgsMs28GcsWGWKVV00M09y/Vz
AeQi1uFhMcqLCGGghmlIec896NRXqJ0yiemo5k6UF+crplod8bUU/ykykZfmf73K
R8JDd99az61azoY7Ao9cEGgKCvt+A8eLG64XVO0TMIF4XgX6MQ==
=3SMK
-----END PGP SIGNATURE-----
--=-=-=--
