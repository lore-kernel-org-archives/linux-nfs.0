Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751717AbdFHPgl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 11:36:41 -0400
Subject: Re: [PATCH] mount.nfs: Use default minor version when -t nfs4 is
 specified
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>
References: <20170606194812.4248-1-steved@redhat.com>
 <87y3t4bjhs.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <980ef718-075d-4c68-7e2c-853add72e184@RedHat.com>
Date: Thu, 8 Jun 2017 11:36:39 -0400
MIME-Version: 1.0
In-Reply-To: <87y3t4bjhs.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/06/2017 10:48 PM, NeilBrown wrote:
> On Tue, Jun 06 2017, Steve Dickson wrote:
> 
>> When the nfs4 filesystem specified, the default minor
>> version should be used not v4.0.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/stropts.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index c0266e5..57efb26 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -317,7 +317,8 @@ static int nfs_set_version(struct nfsmount_info *mi)
>>  
>>  	if (strncmp(mi->type, "nfs4", 4) == 0) {
>>  		mi->version.major = 4;
>> -		mi->version.v_mode = V_GENERAL;
>> +		mi->version.minor = 2;
>> +		mi->version.v_mode = V_SPECIFIC;
> 
> I think this is wrong.
> 
> By setting the mode to SPECIFIC, you are saying that if the server
> doesn't support v4.2, then fail the mount.  That cannot be right.
Ok... I though since nfs4 was being specify it should be
V_SPECIFIC but I do see your point about negotiating  down.

It turns out setting  vers4.2=n in /etc/nfs.conf breaks 
all v4 mounts... So I think we have issues in that area
ATM... ;-)

> 
> Given that (currently) v_mode is not V_SPECIFIC, nfs_set_version()
> will go on and call nfs_default_version(), which will use the default
> value from the config file - just as Chuck suggests.
> 
> If there is no default in the config file .... nfs_default_version()
> will do nothing.  So version.minor will probably remain at zero.
> So setting
>> +		mi->version.minor = 2;
> 
> (where 2 is the maximum supported version) is probably correct.
> Setting
>> +		mi->version.v_mode = V_SPECIFIC;
> is unnecessary and wrong.
> 
> If there an easy way to find out the maximum minor version that the
> kernel supports?  We should really default version.minor to that.
> Once we get up to v4.20, it'll seem odd to try to mount 4.20, 4.19,
> 4.18,... until something succeeds....
Maybe it should be something like the server does under /proc/fs/nfsd/version

steved.

> 
> Thanks,
> NeilBrown
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
