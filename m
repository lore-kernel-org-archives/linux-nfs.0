Return-Path: <kinglongmee@gmail.com>
Message-ID: <552BB4DF.2090200@gmail.com>
Date: Mon, 13 Apr 2015 20:21:51 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>
CC: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount: make sure mounting nfs with v4,vers=4 and nfsvers=4
References: <552A5F3F.1090206@gmail.com> <alpine.OSX.2.19.9992.1504130805140.4187@planck.local>
In-Reply-To: <alpine.OSX.2.19.9992.1504130805140.4187@planck.local>
Content-Type: text/plain; charset=windows-1252
List-ID: <linux-nfs.vger.kernel.org>

On 4/13/2015 8:16 PM, Benjamin Coddington wrote:
> Hi Kinglong,  I can't seem to figure out how to reproduce your problem, and
> I don't see show this change fixes it.  Your mount is falling back to a v3
> attempt without this patch?  What's set in nfsmount.conf?

Sorry for my missing notes for nfsmount.conf.
My nfsmount.conf is default config, 
besides [ NFSMount_Global_Options ], others line are commented by "#",
Defaultvers isn't set as, "# Defaultvers=4"

thanks,
Kinglong Mee

> 
> Ben
> 
> On Sun, 12 Apr 2015, Kinglong Mee wrote:
> 
>> When mounting nfs with -ov4, -overs=4 or -onfsvers=4, fail as,
>>
>> # mount -t nfs -ov4 192.168.31.12:/ /testidr/
>> mount.nfs: access denied by server while mounting 192.168.31.12:/
>>
>> Fixes: f980298853 "mount.nfs: configurable minor version defaults"
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  utils/mount/stropts.c | 12 +++---------
>>  1 file changed, 3 insertions(+), 9 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index df67fac..2ae532e 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -108,12 +108,6 @@ static void nfs_default_version(struct nfsmount_info *mi)
>>  		return;
>>  	}
>>
>> -	if (mi->version.v_mode == V_GENERAL &&
>> -		config_default_vers.v_mode == V_DEFAULT) {
>> -		mi->version.v_mode = V_SPECIFIC;
>> -		return;
>> -	}
>> -
>>  	if (mi->version.v_mode == V_DEFAULT &&
>>  		config_default_vers.v_mode != V_DEFAULT) {
>>  		mi->version.major = config_default_vers.major;
>> @@ -121,9 +115,9 @@ static void nfs_default_version(struct nfsmount_info *mi)
>>  		return;
>>  	}
>>
>> -	if (mi->version.v_mode == V_GENERAL &&
>> -		config_default_vers.v_mode != V_DEFAULT) {
>> -		if (mi->version.major == config_default_vers.major)
>> +	if (mi->version.v_mode == V_GENERAL) {
>> +		if (config_default_vers.v_mode != V_DEFAULT &&
>> +		    mi->version.major == config_default_vers.major)
>>  			mi->version.minor = config_default_vers.minor;
>>  		return;
>>  	}
>> --
>> 2.3.5
>>
>>
> 
