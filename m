Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752695AbdFMPy5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 11:54:57 -0400
Subject: Re: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is
 specified
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170609132608.12213-1-steved@redhat.com>
 <20170609132608.12213-2-steved@redhat.com>
 <87poe88z1e.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5881a561-2433-d0e2-c91a-684f3bd1b22d@RedHat.com>
Date: Tue, 13 Jun 2017 11:54:55 -0400
MIME-Version: 1.0
In-Reply-To: <87poe88z1e.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Sorry I didn't see your entire response 
the first time around...

On 06/12/2017 09:19 PM, NeilBrown wrote:
> On Fri, Jun 09 2017, Steve Dickson wrote:
> 
>> When v4 is specified on the command line the
>> default minor version needs to be used.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/stropts.c | 27 ++++++++++++++++++++-------
>>  1 file changed, 20 insertions(+), 7 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 81fb945..d2d303f 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount_info *mi)
>>  	if (mi->version.v_mode == V_DEFAULT &&
>>  		config_default_vers.v_mode != V_DEFAULT) {
>>  		mi->version.major = config_default_vers.major;
>> -		mi->version.minor = config_default_vers.minor;
>> +		if (config_default_vers.minor)
>> +			mi->version.minor = config_default_vers.minor;
>> +		else if (!mi->version.minor)
>> +			mi->version.minor = NFS_DEFAULT_MINOR;
> 
> No, this looks wrong.  A minor number of '0' can be perfectly valid.
> Deciding to turn a minor of '0' into '2' is simply wrong.
Please see my first response. Basically if the minor version
is not set, the set it to the default version.

> 
> You can only tell if .minor is valid by looking at .v_mode.
> If .v_mode is V_GENERAL or V_DEFAULT, then .minor is not valid
> and a default should be used.  If it is V_SPECIFIC, then .minor is
> either valid or irrelevant, depending on .major.
> 
> 
>>  		return;
>>  	}
>>  
>>  	if (mi->version.v_mode == V_GENERAL) {
>>  		if (config_default_vers.v_mode != V_DEFAULT &&
>> -		    mi->version.major == config_default_vers.major)
>> -			mi->version.minor = config_default_vers.minor;
>> +		    mi->version.major == config_default_vers.major) {
>> +			if (mi->version.minor)
>> +				mi->version.minor = config_default_vers.minor;
> 
> Again, don't test version.minor like this.
You have to... For the -o minorversion=1 cast.
If the minor is already set, don't reset it.

> 
>> +			else if (!mi->version.minor)
>> +				mi->version.minor = NFS_DEFAULT_MINOR;
>> +		} else if (!mi->version.minor)
>> +			mi->version.minor = NFS_DEFAULT_MINOR;
>>  		return;
>>  	}
>>  
>> @@ -740,10 +748,15 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>>  	}
>>  
>>  	if (mi->version.v_mode != V_SPECIFIC) {
>> -		if (mi->version.v_mode == V_GENERAL)
>> -			snprintf(version_opt, sizeof(version_opt) - 1,
>> -				"vers=%lu", mi->version.major);
>> -		else
>> +		if (mi->version.v_mode == V_GENERAL) {
>> +			if (mi->version.major > 3)
> 
> This test is pointless as .v_mode is only ever V_GENERAL when
>  .major == 4
> 
> And given that this is nfs_do_mount_v4(), we can be certain that
> version.major == 4.
> 
> Prior to
> Commit: 0d71b058092f ("NFS: Extend the -overs= mount option to allow 4.x minorversions")
> 
> in Linux 3.4, writing "vers=4.1" wasn't supported.
> So I think it would be safest to use
>   vers=4                   if minor == 0
I'm thinking if you don't specify the minor version
the default minor version should be used. 

Again, I'm thinking there should be no difference
between -t nfs4, -o vers=4, -o nfsvers=4 and -o v4.
They all should become v4.2 mounts

This mean the only way to not used the default version
is to specify it.

>   vers=4,minorversion=1    if minor == 1
>   vers=4.2                 if minor == 2
> 
> This is despite the fact that the comment in the kernel says
>                                                   In future,
>                  * the mount program should always supply
>                  * a NFSv4 minor version number.
I agree... 

> 
> I think vers=4.%d is appropriate for v4.2 and later, but not for earlier
> versions.
> 
> Alternately we could test the kernel version and behave differently, but
> I think that is worse.
Yeah we have a few MAKE_VERSION() sprinkle though the legacy code 
> 
> Thanks,
> NeilBrown
> 
>> +				snprintf(version_opt, sizeof(version_opt) - 1,
>> +					"vers=%lu.%lu", mi->version.major,
>> +					mi->version.minor);
>> +			else 
>> +				snprintf(version_opt, sizeof(version_opt) - 1,
>> +					"vers=%lu", mi->version.major);
>> +		} else
>>  			snprintf(version_opt, sizeof(version_opt) - 1,
>>  				"vers=%lu.%lu", mi->version.major,
>>  				mi->version.minor);
>> -- 
>> 2.9.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
