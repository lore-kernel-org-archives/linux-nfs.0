Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49196 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751624AbdFNKDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 06:03:35 -0400
Subject: Re: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is
 specified
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170609132608.12213-1-steved@redhat.com>
 <20170609132608.12213-2-steved@redhat.com>
 <87poe88z1e.fsf@notabene.neil.brown.name>
 <5881a561-2433-d0e2-c91a-684f3bd1b22d@RedHat.com>
 <87wp8f721l.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <0b850e57-b4a7-fae5-ba29-69ffde0c3db2@RedHat.com>
Date: Wed, 14 Jun 2017 06:03:34 -0400
MIME-Version: 1.0
In-Reply-To: <87wp8f721l.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/13/2017 10:09 PM, NeilBrown wrote:
> On Tue, Jun 13 2017, Steve Dickson wrote:
> 
>> Sorry I didn't see your entire response 
>> the first time around...
>>
>> On 06/12/2017 09:19 PM, NeilBrown wrote:
>>> On Fri, Jun 09 2017, Steve Dickson wrote:
>>>
>>>> When v4 is specified on the command line the
>>>> default minor version needs to be used.
>>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>>  utils/mount/stropts.c | 27 ++++++++++++++++++++-------
>>>>  1 file changed, 20 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>> index 81fb945..d2d303f 100644
>>>> --- a/utils/mount/stropts.c
>>>> +++ b/utils/mount/stropts.c
>>>> @@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount_info *mi)
>>>>  	if (mi->version.v_mode == V_DEFAULT &&
>>>>  		config_default_vers.v_mode != V_DEFAULT) {
>>>>  		mi->version.major = config_default_vers.major;
>>>> -		mi->version.minor = config_default_vers.minor;
>>>> +		if (config_default_vers.minor)
>>>> +			mi->version.minor = config_default_vers.minor;
>>>> +		else if (!mi->version.minor)
>>>> +			mi->version.minor = NFS_DEFAULT_MINOR;
>>>
>>> No, this looks wrong.  A minor number of '0' can be perfectly valid.
>>> Deciding to turn a minor of '0' into '2' is simply wrong.
>> Please see my first response. Basically if the minor version
>> is not set, the set it to the default version.
> 
> You are testing config_default_vers.minor without first confirming that
> config_default_vers.v_mode is V_SPECIFIC.  I don't see how that makes
> sense.
Well at this point we know the config_default v_mode is either 
V_SPECIFIC or V_GENERAL. 
> 
> We should use major/minor values out of config_default_vers based on its
> v_mode, not on whether the values are zero or not.
> 
> If v_mode == V_DEFAULT, don't use anything
> If v_mode == V_GENERAL, use the major, not the minor
How can't we use the minor if its v4... The whole point of
these patches is to used the default minor when v4 is used.

> If v_mode == V_SPECIFIC, use major and minor (though minor is irrelevant
>                         if major != 4)
> 
>>
>>>
>>> You can only tell if .minor is valid by looking at .v_mode.
>>> If .v_mode is V_GENERAL or V_DEFAULT, then .minor is not valid
>>> and a default should be used.  If it is V_SPECIFIC, then .minor is
>>> either valid or irrelevant, depending on .major.
>>>
>>>
>>>>  		return;
>>>>  	}
>>>>  
>>>>  	if (mi->version.v_mode == V_GENERAL) {
>>>>  		if (config_default_vers.v_mode != V_DEFAULT &&
>>>> -		    mi->version.major == config_default_vers.major)
>>>> -			mi->version.minor = config_default_vers.minor;
>>>> +		    mi->version.major == config_default_vers.major) {
>>>> +			if (mi->version.minor)
>>>> +				mi->version.minor = config_default_vers.minor;
>>>
>>> Again, don't test version.minor like this.
>> You have to... For the -o minorversion=1 cast.
>> If the minor is already set, don't reset it.
> 
> "-o minorversion=1" causes "v_mode = V_SPECIFIC" (in nfs_nfs_version()).
> This isn't a case that is of any concern in nfs_default_version().
True.. 
>>
>>>
>>>> +			else if (!mi->version.minor)
>>>> +				mi->version.minor = NFS_DEFAULT_MINOR;
>>>> +		} else if (!mi->version.minor)
>>>> +			mi->version.minor = NFS_DEFAULT_MINOR;
>>>>  		return;
>>>>  	}
>>>>  
>>>> @@ -740,10 +748,15 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>>>>  	}
>>>>  
>>>>  	if (mi->version.v_mode != V_SPECIFIC) {
>>>> -		if (mi->version.v_mode == V_GENERAL)
>>>> -			snprintf(version_opt, sizeof(version_opt) - 1,
>>>> -				"vers=%lu", mi->version.major);
>>>> -		else
>>>> +		if (mi->version.v_mode == V_GENERAL) {
>>>> +			if (mi->version.major > 3)
>>>
>>> This test is pointless as .v_mode is only ever V_GENERAL when
>>>  .major == 4
>>>
>>> And given that this is nfs_do_mount_v4(), we can be certain that
>>> version.major == 4.
>>>
>>> Prior to
>>> Commit: 0d71b058092f ("NFS: Extend the -overs= mount option to allow 4.x minorversions")
>>>
>>> in Linux 3.4, writing "vers=4.1" wasn't supported.
>>> So I think it would be safest to use
>>>   vers=4                   if minor == 0
>> I'm thinking if you don't specify the minor version
>> the default minor version should be used. 
> 
> Yes, but I'm talking about how you tell the kernel that.
> At this point in the code a choice has been made about what major/minor
> to use.  Negotiation is happening at a higher level and here we just
> need to tell the kernel the current choice.
> If v_mode == V_SPECIFIC, we don't do anything because the options passed
> to mount.nfs are pass through to the kernel unchanged.
Fine... 

> In other cases we need to create a kernel option to request
> a specific version.
>   vers=4
> will always choose v4.0, in any kernel that supports it.  On some
> kernels, "vers=4.0" won't work.
which ones don't support v4.0? 

>   vers=4,minorversion=1
> will always choose v4.1 in any kernel that supports it.
>   vers=4.2
> will always choose v4.2 if supported.
> 
> So I think those are the options we should use.
I guess I don't see how we can test what a kernel can
or can not support... It has to be an assumption.
Does it have to be dynamic? Meaning and the mount
command be tailored to a particular kernel?   
> 
>>
>> Again, I'm thinking there should be no difference
>> between -t nfs4, -o vers=4, -o nfsvers=4 and -o v4.
>> They all should become v4.2 mounts
> 
> They should on current kernels if the server supports it.  On older
> kernels, or with older servers, they might become v4.1 or v4.0.
> We need to make sure the way we tell the kernel what version to use,
> works on the widest possible range of kernels.
So you are talking about using a new nfs-utils on a older kernel?
Is that something that is done?

steved.
> 
> Thanks,
> NeilBrown
> 
> 
>>
>> This mean the only way to not used the default version
>> is to specify it.
>>
>>>   vers=4,minorversion=1    if minor == 1
>>>   vers=4.2                 if minor == 2
>>>
>>> This is despite the fact that the comment in the kernel says
>>>                                                   In future,
>>>                  * the mount program should always supply
>>>                  * a NFSv4 minor version number.
>> I agree... 
>>
>>>
>>> I think vers=4.%d is appropriate for v4.2 and later, but not for earlier
>>> versions.
>>>
>>> Alternately we could test the kernel version and behave differently, but
>>> I think that is worse.
>> Yeah we have a few MAKE_VERSION() sprinkle though the legacy code 
>>>
>>> Thanks,
>>> NeilBrown
>>>
>>>> +				snprintf(version_opt, sizeof(version_opt) - 1,
>>>> +					"vers=%lu.%lu", mi->version.major,
>>>> +					mi->version.minor);
>>>> +			else 
>>>> +				snprintf(version_opt, sizeof(version_opt) - 1,
>>>> +					"vers=%lu", mi->version.major);
>>>> +		} else
>>>>  			snprintf(version_opt, sizeof(version_opt) - 1,
>>>>  				"vers=%lu.%lu", mi->version.major,
>>>>  				mi->version.minor);
>>>> -- 
>>>> 2.9.4
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
