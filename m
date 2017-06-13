Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53190 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753432AbdFMP0g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 11:26:36 -0400
Subject: Re: [PATCH 1/2 V2] mount.nfs: Use default minor version when -t nfs4
 is specified
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170609132608.12213-1-steved@redhat.com>
 <87shj48zyx.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5c30f909-255e-1568-910d-34619003f638@RedHat.com>
Date: Tue, 13 Jun 2017 11:26:34 -0400
MIME-Version: 1.0
In-Reply-To: <87shj48zyx.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/12/2017 08:59 PM, NeilBrown wrote:
> On Fri, Jun 09 2017, Steve Dickson wrote:
> 
>> When the nfs4 filesystem specified, the default major
>> and minor versions should be used.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/stropts.c | 16 ++++++++++++----
>>  1 file changed, 12 insertions(+), 4 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index c0266e5..81fb945 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -73,6 +73,13 @@
>>  #define NFS_DEF_BG_TIMEOUT_MINUTES	(10000u)
>>  #endif
>>  
>> +#ifndef NFS_DEFAULT_MAJOR
>> +#define NFS_DEFAULT_MAJOR	4
>> +#endif
>> +#ifndef NFS_DEFAULT_MINOR
>> +#define NFS_DEFAULT_MINOR	2
>> +#endif
>> +
>>  extern int nfs_mount_data_version;
>>  extern char *progname;
>>  extern int verbose;
>> @@ -124,8 +131,8 @@ static void nfs_default_version(struct nfsmount_info *mi)
>>  	}
>>  
>>  #endif /* MOUNT_CONFIG */
>> -	mi->version.major = 4;
>> -	mi->version.minor = 2;
>> +	mi->version.major = NFS_DEFAULT_MAJOR;
>> +	mi->version.minor = NFS_DEFAULT_MINOR;
>>  }
>>  
>>  /*
>> @@ -316,8 +323,9 @@ static int nfs_set_version(struct nfsmount_info *mi)
>>  		return 0;
>>  
>>  	if (strncmp(mi->type, "nfs4", 4) == 0) {
>> -		mi->version.major = 4;
>> -		mi->version.v_mode = V_GENERAL;
>> +		/* Set to default values */
>> +		mi->version.major = NFS_DEFAULT_MAJOR;
>> +		mi->version.minor = NFS_DEFAULT_MINOR;
> 
> Why do you remove the setting of v_mode to V_GENERAL?
> Won't that leave it as V_DEFAULT, and doesn't that mean
> that it will negotiate from v4 down to v3??
I was thinking v_mode was being set to V_GENERAL by
the previous call to nfs_nfs_version(), but is
not the cause for -t nfs4, so are correct.
The v_mode needs to be set to V_GENERAL in
this case... Thanks!

steved.

> 
> NeilBrown
> 
> 
>>  	}
>>  	/*
>>  	 * Before 2.6.32, the kernel NFS client didn't
>> -- 
>> 2.9.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
