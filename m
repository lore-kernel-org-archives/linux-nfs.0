Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH] mount.nfs: skip option validation on remount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5C9855F4-AF15-479B-989E-B0B056A8604E@oracle.com>
Date: Wed, 6 Apr 2016 08:59:08 -0700
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8221480D-323C-4F0D-A8FA-DE32E1CABF44@oracle.com>
References: <712798c489f69e39f235077f6ca85a7c133eeb58.1459949813.git.bcodding@redhat.com> <541141C7-9928-43FE-8C45-82A914038EC1@oracle.com> <alpine.OSX.2.19.9992.1604061124080.18253@planck> <5C9855F4-AF15-479B-989E-B0B056A8604E@oracle.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 6, 2016, at 8:47 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>>=20
>> On Apr 6, 2016, at 8:24 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>>=20
>> On Wed, 6 Apr 2016, Chuck Lever wrote:
>>>=20
>>>> On Apr 6, 2016, at 6:41 AM, Benjamin Coddington =
<bcodding@redhat.com> wrote:
>>>>=20
>>>> I'm not exactly sure this is the safest thing to do since you can =
pass
>>>> -oremount on the first mount and skip option validation.  Maybe =
someone with
>>>> better insight into the mount paths could comment.  Does mount need =
some
>>>> refactoring?  Its logic seems arcane.. and I think there is a lot =
of dead
>>>> code.
>>>=20
>>> It's arcane because NFS mounting has a lot of corner cases
>>> that have evolved over the years. If you have an example of
>>> dead code, can you post it?
>>=20
>> Absolutely.  I don't have it ready right now, but I do remember =
coming across
>> some sections several times and wondering how they could be used.
>>=20
>> I need to do a better job of posting when I find things instead of =
putting
>> them off and forgetting about them.
>>=20
>>>> This is very quick attempt to fix
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D1313550
>>>=20
>>> "You are not authorized to access bug #1313550."
>>=20
>> Sorry.  I've just tried to fix that and I cannot.  The basic info =
there is
>> that kdump always tries to remount,rw a target.. and that is breaking =
on
>> NFS.
>=20
> Always breaking? Or just in the case where the server has
> multiple homes?
>=20
>=20
>> The bug doesn't really provide anything more useful to the discussion
>> other than maybe help Steved find the original problem.
>>=20
>>> I'm guessing you want to use the existing addr=3D option on a
>>> remount in case the DNS resolution returns a different address.
>>=20
>> Right.
>>=20
>>> I'm uncertain why a remount should succeed in this case: if
>>> the server has a different IP address, how was the mount working
>>> at all?
>>=20
>> If the server has multiple A or AAAA records, and the the results are
>> returned round-robin style, we can end up with a different address =
for
>> the server.
>=20
> I agree that a second DNS resolution here is probably not
> helpful or needed. Still, multi-home NFS seems like a crap
> shoot to begin with. Maybe I'm just not awake yet.

I should clarify: I mean round-robin here, not multi-home.

Is this only a problem when the server has an A and an
AAAA address, and there's no "proto=3D" specified?


> But I think you do need to validate mount options on a
> remount: otherwise you can pass "-o remount,garbage". Or
> did I misunderstand?
>=20
>=20
>> Ben
>>=20
>>>> =
8<------------------------------------------------------------------------=
-
>>>>=20
>>>> A remount might fail if name resolution returns a different server =
address
>>>> for the mount.  Since we've already validated the options the first =
time,
>>>> skip validation if remounting.
>>>>=20
>>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>>> ---
>>>> utils/mount/stropts.c |    6 +++---
>>>> 1 files changed, 3 insertions(+), 3 deletions(-)
>>>>=20
>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>> index 86829a9..9383bb4 100644
>>>> --- a/utils/mount/stropts.c
>>>> +++ b/utils/mount/stropts.c
>>>> @@ -1090,15 +1090,15 @@ static const char *nfs_background_opttbl[] =
=3D {
>>>>=20
>>>> static int nfsmount_start(struct nfsmount_info *mi)
>>>> {
>>>> -	if (!nfs_validate_options(mi))
>>>> -		return EX_FAIL;
>>>> -
>>>> 	/*
>>>> 	 * Avoid retry and negotiation logic when remounting
>>>> 	 */
>>>> 	if (mi->flags & MS_REMOUNT)
>>>> 		return nfs_remount(mi);
>>>>=20
>>>> +	if (!nfs_validate_options(mi))
>>>> +		return EX_FAIL;
>>>> +
>>>> 	if (po_rightmost(mi->options, nfs_background_opttbl) =3D=3D 0)
>>>> 		return nfsmount_bg(mi);
>>>> 	else
>>>> --
>>>> 1.7.1
>>>>=20
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>=20
>>> --
>>> Chuck Lever
>=20
> --
> Chuck Lever
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
