Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57466 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750839AbdFSOGv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jun 2017 10:06:51 -0400
Subject: Re: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is
 specified
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170609132608.12213-1-steved@redhat.com>
 <20170609132608.12213-2-steved@redhat.com>
 <87poe88z1e.fsf@notabene.neil.brown.name>
 <5881a561-2433-d0e2-c91a-684f3bd1b22d@RedHat.com>
 <87wp8f721l.fsf@notabene.neil.brown.name>
 <0b850e57-b4a7-fae5-ba29-69ffde0c3db2@RedHat.com>
 <87a8587h57.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <16c28559-7007-c32e-e36c-71b7e72219d7@RedHat.com>
Date: Mon, 19 Jun 2017 10:06:50 -0400
MIME-Version: 1.0
In-Reply-To: <87a8587h57.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/15/2017 11:20 PM, NeilBrown wrote:
> On Wed, Jun 14 2017, Steve Dickson wrote:
> 
>> On 06/13/2017 10:09 PM, NeilBrown wrote:
>>> On Tue, Jun 13 2017, Steve Dickson wrote:
>>>
>>>> Sorry I didn't see your entire response 
>>>> the first time around...
>>>>
>>>> On 06/12/2017 09:19 PM, NeilBrown wrote:
>>>>> On Fri, Jun 09 2017, Steve Dickson wrote:
>>>>>
>>>>>> When v4 is specified on the command line the
>>>>>> default minor version needs to be used.
>>>>>>
>>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>>>> ---
>>>>>>  utils/mount/stropts.c | 27 ++++++++++++++++++++-------
>>>>>>  1 file changed, 20 insertions(+), 7 deletions(-)
>>>>>>
>>>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>>>> index 81fb945..d2d303f 100644
>>>>>> --- a/utils/mount/stropts.c
>>>>>> +++ b/utils/mount/stropts.c
>>>>>> @@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount_info *mi)
>>>>>>  	if (mi->version.v_mode == V_DEFAULT &&
>>>>>>  		config_default_vers.v_mode != V_DEFAULT) {
>>>>>>  		mi->version.major = config_default_vers.major;
>>>>>> -		mi->version.minor = config_default_vers.minor;
>>>>>> +		if (config_default_vers.minor)
>>>>>> +			mi->version.minor = config_default_vers.minor;
>>>>>> +		else if (!mi->version.minor)
>>>>>> +			mi->version.minor = NFS_DEFAULT_MINOR;
>>>>>
>>>>> No, this looks wrong.  A minor number of '0' can be perfectly valid.
>>>>> Deciding to turn a minor of '0' into '2' is simply wrong.
>>>> Please see my first response. Basically if the minor version
>>>> is not set, the set it to the default version.
>>>
>>> You are testing config_default_vers.minor without first confirming that
>>> config_default_vers.v_mode is V_SPECIFIC.  I don't see how that makes
>>> sense.
>> Well at this point we know the config_default v_mode is either 
>> V_SPECIFIC or V_GENERAL. 
> 
> Yes.
> If v_mode==V_GENERAL then minor==0, but that doesn't mean anything.
This means v4 and use the NFS_DEFAULT_MINOR as the minor version

> If v_mode==V_SPECIFIC and minor==0, it means that v4.0 was explicitly requested.
> 
>>>
>>> We should use major/minor values out of config_default_vers based on its
>>> v_mode, not on whether the values are zero or not.
>>>
>>> If v_mode == V_DEFAULT, don't use anything
>>> If v_mode == V_GENERAL, use the major, not the minor
>> How can't we use the minor if its v4... The whole point of
>> these patches is to used the default minor when v4 is used.
> 
> If v_mode==V_GENERAL, then the minor doesn't mean anything.  It will
> happen to be zero, but it is safer to think of it as undefined.
When v_mode==V_GENERAL we know it is a v4 mount so the minor does
mean something... and since we want to used the latest minor
version, in the case minor should be set to NFS_DEFAULT_MINOR.

> 
> Just to check what you want:
>  If someone mounts with "-t nfs4" or "-o v4" or "-o vers=4" and
>  nfsmount.conf contains "vers=4.1" then you want it to default to
>  try 4.1, then fallback to 4.0
>  But if nfsmount.conf contains "vers=4.0", you want to try
>  4.0, and not fall back to anything.
>  If nfsmount.conf contains "vers=4", you want to try 4.2 first (because
>  that is NFS_DEFAULT_MINOR), then fall back to 4.1, then 4.0
> 
>  Is that correct (seems reasonable to me)?
Yes.

> 
> We know that the user requested one of those because mi->version.v_mode ==
> V_GENERAL.
> Then if config_default_vers.v_mode == V_SPECIFIC and major==4, we
> want to copy .minor in.  Otherwise we use NFS_DEFAULT_MINOR.
I believe this is what the code is doing... 

> 
> 
>>
>>> If v_mode == V_SPECIFIC, use major and minor (though minor is irrelevant
>>>                         if major != 4)
>>>
>>>>
>>>>>
>>>>> You can only tell if .minor is valid by looking at .v_mode.
>>>>> If .v_mode is V_GENERAL or V_DEFAULT, then .minor is not valid
>>>>> and a default should be used.  If it is V_SPECIFIC, then .minor is
>>>>> either valid or irrelevant, depending on .major.
>>>>>
>>>>>
>>>>>>  		return;
>>>>>>  	}
>>>>>>  
>>>>>>  	if (mi->version.v_mode == V_GENERAL) {
>>>>>>  		if (config_default_vers.v_mode != V_DEFAULT &&
>>>>>> -		    mi->version.major == config_default_vers.major)
>>>>>> -			mi->version.minor = config_default_vers.minor;
>>>>>> +		    mi->version.major == config_default_vers.major) {
>>>>>> +			if (mi->version.minor)
>>>>>> +				mi->version.minor = config_default_vers.minor;
>>>>>
>>>>> Again, don't test version.minor like this.
>>>> You have to... For the -o minorversion=1 cast.
>>>> If the minor is already set, don't reset it.
>>>
>>> "-o minorversion=1" causes "v_mode = V_SPECIFIC" (in nfs_nfs_version()).
>>> This isn't a case that is of any concern in nfs_default_version().
>> True.. 
>>>>
>>>>>
>>>>>> +			else if (!mi->version.minor)
>>>>>> +				mi->version.minor = NFS_DEFAULT_MINOR;
>>>>>> +		} else if (!mi->version.minor)
>>>>>> +			mi->version.minor = NFS_DEFAULT_MINOR;
>>>>>>  		return;
>>>>>>  	}
>>>>>>  
>>>>>> @@ -740,10 +748,15 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>>>>>>  	}
>>>>>>  
>>>>>>  	if (mi->version.v_mode != V_SPECIFIC) {
>>>>>> -		if (mi->version.v_mode == V_GENERAL)
>>>>>> -			snprintf(version_opt, sizeof(version_opt) - 1,
>>>>>> -				"vers=%lu", mi->version.major);
>>>>>> -		else
>>>>>> +		if (mi->version.v_mode == V_GENERAL) {
>>>>>> +			if (mi->version.major > 3)
>>>>>
>>>>> This test is pointless as .v_mode is only ever V_GENERAL when
>>>>>  .major == 4
>>>>>
>>>>> And given that this is nfs_do_mount_v4(), we can be certain that
>>>>> version.major == 4.
>>>>>
>>>>> Prior to
>>>>> Commit: 0d71b058092f ("NFS: Extend the -overs= mount option to allow 4.x minorversions")
>>>>>
>>>>> in Linux 3.4, writing "vers=4.1" wasn't supported.
>>>>> So I think it would be safest to use
>>>>>   vers=4                   if minor == 0
>>>> I'm thinking if you don't specify the minor version
>>>> the default minor version should be used. 
>>>
>>> Yes, but I'm talking about how you tell the kernel that.
>>> At this point in the code a choice has been made about what major/minor
>>> to use.  Negotiation is happening at a higher level and here we just
>>> need to tell the kernel the current choice.
>>> If v_mode == V_SPECIFIC, we don't do anything because the options passed
>>> to mount.nfs are pass through to the kernel unchanged.
>> Fine... 
>>
>>> In other cases we need to create a kernel option to request
>>> a specific version.
>>>   vers=4
>>> will always choose v4.0, in any kernel that supports it.  On some
>>> kernels, "vers=4.0" won't work.
>> which ones don't support v4.0? 
>>
> 
> Everything prior to
>  Commit: 0d71b058092f ("NFS: Extend the -overs= mount option to allow 4.x minorversions")
> 
> in Linux 3.4.
> 
>>>   vers=4,minorversion=1
>>> will always choose v4.1 in any kernel that supports it.
>>>   vers=4.2
>>> will always choose v4.2 if supported.
>>>
>>> So I think those are the options we should use.
>> I guess I don't see how we can test what a kernel can
>> or can not support... It has to be an assumption.
>> Does it have to be dynamic? Meaning and the mount
>> command be tailored to a particular kernel?   
> 
> The mount command doesn't need to be tailored because the
> kernel is, fortunately, backward compatible.
> Each of
>   vers=4
>   vers=4,minorversion=1
>   vers=4.2
> 
> will work correctly on all kernels which support that particular minor
> version.
And it does... see below.

> 
> 
>>>
>>>>
>>>> Again, I'm thinking there should be no difference
>>>> between -t nfs4, -o vers=4, -o nfsvers=4 and -o v4.
>>>> They all should become v4.2 mounts
>>>
>>> They should on current kernels if the server supports it.  On older
>>> kernels, or with older servers, they might become v4.1 or v4.0.
>>> We need to make sure the way we tell the kernel what version to use,
>>> works on the widest possible range of kernels.
>> So you are talking about using a new nfs-utils on a older kernel?
> 
> Correct.
> 
>> Is that something that is done?
> 
> We have to assume that it is. We don't necessarily need to test all the
> combinations, but we need to make a reasonable effort to support
> all kernels which have the functionality requested.
> The only alternative is to put some sort of rule in the configure
> script so that it refuses to compile on old kernels, but I think that
> should be a last-resort.
I tested the latest patch version (V3) on a 2.6 kernel. It ends
up falling back to v3 since nfs_autonegotiate() retries with
lower minor version then ends up doing a v3 mount which succeeds.

mount: no type was given - I'll assume nfs because of the colon
mount.nfs: timeout set for Sun Dec 11 23:16:15 2016
mount.nfs: trying text-based options 'vers=4.2,addr=172.31.1.50,clientaddr=172.31.1.28'
mount.nfs: mount(2): Invalid argument
mount.nfs: trying text-based options 'vers=4.1,addr=172.31.1.50,clientaddr=172.31.1.28'
mount.nfs: mount(2): Invalid argument
mount.nfs: trying text-based options 'vers=4.0,addr=172.31.1.50,clientaddr=172.31.1.28'
mount.nfs: mount(2): Invalid argument
mount.nfs: trying text-based options 'addr=172.31.1.50'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 172.31.1.50 prog 100003 vers 3 prot TCP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 172.31.1.50 prog 100005 vers 3 prot UDP port 20048

So I think we are good with older kernels. 
> 
> Thanks,
> NeilBrown
> 
