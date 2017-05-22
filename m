Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40968 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933917AbdEVOac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 10:30:32 -0400
Subject: Re: [PATCH 1/2] mount.nfs: v4 mounts should fail when -o flag is
 used.
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170519222510.31205-1-steved@redhat.com>
 <87inktk2yg.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5a0d2640-ec93-279b-9113-228994283923@RedHat.com>
Date: Mon, 22 May 2017 10:30:30 -0400
MIME-Version: 1.0
In-Reply-To: <87inktk2yg.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/21/2017 11:03 PM, NeilBrown wrote:
> On Fri, May 19 2017, Steve Dickson wrote:
> 
>> When the pseudo root is set with fsid=0, explicit
>> v4 mounts (via the -o flag) should fail when
>> the incorrect export is tried instead of rolling
>> back to v3.
> 
> Hi Steve,
>  I think this patch makes sense, but the above description doesn't.
>  Where does fsid=0 fit in anywhere here?
It sets the export to be the pseudo root
    /home *(rw,fsid=0,sec=sys:krb5:krb5i:krb5p)

so when then that export using either -t nfs4 or -o v4
    mount -o v4.0 127.0.0.1:/home /mnt

the mount should fail instead of rolling back to v3
Basically its be used to cause the error. 

> 
> I think you want to say
> 
>   When the protocol is set with "-t nfs4", we should behave just like
>   with do with "-o vers=4" and not fall back to v3.
Actually the first patch fixes the -o vers=4 case since
that too was rolling back to v3 in the above scenario
 
> 
> Is that what you were really trying to say?
How about

When the protocol is set the "-o v4" flag,
and the mount fails due to a pseudo root
issue, the mount should fail not, roll 
back to v3.

steved.

> 
> Thanks,
> NeilBrown
> 
> 
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/network.c | 3 ++-
>>  utils/mount/network.h | 8 ++++----
>>  2 files changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index 281e935..e39263e 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -1299,7 +1299,8 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
>>  		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
>>  			goto ret_error;
>>  		version->v_mode = V_SPECIFIC;
>> -	} else if (version->major > 3 && *cptr == '\0')
>> +	} else if (version->major > 3 && *cptr == '\0' &&
>> +			version->v_mode == V_DEFAULT) /* v_mode has not been set */
>>  		version->v_mode = V_GENERAL;
>>  
>>  	if (*cptr != '\0')
>> diff --git a/utils/mount/network.h b/utils/mount/network.h
>> index 9cc5dec..45e2b24 100644
>> --- a/utils/mount/network.h
>> +++ b/utils/mount/network.h
>> @@ -58,10 +58,10 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
>>  struct mount_options;
>>  
>>  enum {
>> -	V_DEFAULT = 0,
>> -	V_GENERAL,
>> -	V_SPECIFIC,
>> -	V_PARSE_ERR,
>> +	V_DEFAULT = 0, /* not set */
>> +	V_GENERAL,     /* single digit => 4 */
>> +	V_SPECIFIC,    /* single digit < 4 or decimal included */
>> +	V_PARSE_ERR,   /* miss all others */
>>  };
>>  
>>  struct nfs_version {
>> -- 
>> 2.9.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
