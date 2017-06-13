Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41270 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753175AbdFMPV0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 11:21:26 -0400
Subject: Re: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is
 specified
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170609132608.12213-1-steved@redhat.com>
 <20170609132608.12213-2-steved@redhat.com>
 <87poe88z1e.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ab1e7d91-8b63-b8c0-e2ad-a6d352532983@RedHat.com>
Date: Tue, 13 Jun 2017 11:21:24 -0400
MIME-Version: 1.0
In-Reply-To: <87poe88z1e.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



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
The only way to have a minor version of '0' is to use 
the -o v4.0 flag. That would causes v_mode to be V_SPECIFIC.
Also note, in nfs_nfs_version() when major is < 4 
the v_mode is also set to V_SPECIFIC (aka -o v3)
For both those case nfs_default_version() is not called. 

So the only way we can get into this code is if v_mode 
is V_GENERAL or V_DEFAULT. So it is a v4 mount and the
minor version needs to be set. So a minor == 0 means
the minor version has not be set so set it to the
default minor version. 

So I think we are good with this...

steved.

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
>   vers=4,minorversion=1    if minor == 1
>   vers=4.2                 if minor == 2
> 
> This is despite the fact that the comment in the kernel says
>                                                   In future,
>                  * the mount program should always supply
>                  * a NFSv4 minor version number.
> 
> I think vers=4.%d is appropriate for v4.2 and later, but not for earlier
> versions.
> 
> Alternately we could test the kernel version and behave differently, but
> I think that is worse.
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
