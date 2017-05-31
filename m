Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41358 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750912AbdEaPd4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 May 2017 11:33:56 -0400
Subject: Re: [PATCH 1/2] mount.nfs: v4 mounts should fail when -o flag is
 used.
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170519222510.31205-1-steved@redhat.com>
 <87inktk2yg.fsf@notabene.neil.brown.name>
 <5a0d2640-ec93-279b-9113-228994283923@RedHat.com>
 <877f18jsx5.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <10eb706b-2f8b-24ad-d572-eb38abdb331d@RedHat.com>
Date: Wed, 31 May 2017 11:33:53 -0400
MIME-Version: 1.0
In-Reply-To: <877f18jsx5.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Sorry for the delayed response... that damn 
flux capacitor broke... again! ;-) 

On 05/22/2017 08:52 PM, NeilBrown wrote:
> On Mon, May 22 2017, Steve Dickson wrote:
> 
>> On 05/21/2017 11:03 PM, NeilBrown wrote:
>>> On Fri, May 19 2017, Steve Dickson wrote:
>>>
>>>> When the pseudo root is set with fsid=0, explicit
>>>> v4 mounts (via the -o flag) should fail when
>>>> the incorrect export is tried instead of rolling
>>>> back to v3.
>>>
>>> Hi Steve,
>>>  I think this patch makes sense, but the above description doesn't.
>>>  Where does fsid=0 fit in anywhere here?
>> It sets the export to be the pseudo root
>>     /home *(rw,fsid=0,sec=sys:krb5:krb5i:krb5p)
>>
>> so when then that export using either -t nfs4 or -o v4
>>     mount -o v4.0 127.0.0.1:/home /mnt
>>
>> the mount should fail instead of rolling back to v3
>> Basically its be used to cause the error. 
>>
>>>
>>> I think you want to say
>>>
>>>   When the protocol is set with "-t nfs4", we should behave just like
>>>   with do with "-o vers=4" and not fall back to v3.
>> Actually the first patch fixes the -o vers=4 case since
>> that too was rolling back to v3 in the above scenario
>>  
>>>
>>> Is that what you were really trying to say?
>> How about
>>
>> When the protocol is set the "-o v4" flag,
>> and the mount fails due to a pseudo root
>> issue, the mount should fail not, roll 
>> back to v3.
> 
> Better, but I don't think the pseudo root has any relevance.
> If you ask for v4, you should get v4, not v3.  How the server may or may
> not behave differently between v3 and v4 is irrelevant.  You should get
> what you asked for.
Fine.

> 
> But now that I look at the code again... I don't understand.
> 
> You say this is for the "-o v4" case.
> 
> In that case, the current code in nfs_nfs_version() will find the "v4"
> entry in nfs_version_opttbl[] and set
>   version_val = "4";
>   version->v_mode = V_SPECIFIC;
> then
>   version_major = 4;
> then as *cptr == '\0' and ->major > 4,
>   version->v_mode = V_GENERAL;
> 
> Your change skips that last step so it finished with
>    v_mod == V_SPECIFIC.
Right.. If v_mode has already set don't reset it.

> 
> According to the extra comments you have added for the modes:
> 
>>>> +	V_GENERAL,     /* single digit => 4 */
>>>> +	V_SPECIFIC,    /* single digit < 4 or decimal included */
> 
> And it seems to me that "v4" should be V_GENERAL, not V_SPECIFIC.
> So I think the current code is correct.
Personally I don't see a needed for V_GENERAL v_mode type
I guess it has to do with the specifying minor version or not
but if any thing is specified on the command line or 
nfsmount.conf then it is V_SPECIFIC... IMHO.

> 
> Except... nfs_try_mount() will then call nfs_autonegotiate(),
> and nfs_autonegotiate() isn't very consistent about how it
> interprets V_GENERAL and V_SPECIFIC.
> For EINVAL, it gets the difference right, for other errors it doesn't.
> 
> So I think that this is the fix you want:
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 0fbb37569ef9..98cf813fe439 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -838,9 +838,6 @@ check_result:
>  	case EINVAL:
>  		/* A less clear indication that our client
>  		 * does not support NFSv4 minor version. */
> -		if (mi->version.v_mode == V_GENERAL &&
> -			mi->version.minor == 0)
> -				return result;
>  		if (mi->version.v_mode != V_SPECIFIC) {
>  			if (mi->version.minor > 0) {
>  				mi->version.minor--;
> @@ -862,6 +859,9 @@ check_result:
>  		/* UDP-Only servers won't support v4, but maybe it
>  		 * just isn't ready yet.  So try v3, but double-check
>  		 * with rpcbind for v4. */
> +		if (mi->version.v_mode == V_GENERAL)
> +			/* Mustn't try v2,v3 */
> +			return result;
>  		result = nfs_try_mount_v3v2(mi, TRUE);
>  		if (result == 0 && errno == EAGAIN) {
>  			/* v4 server seems to be registered now. */
> @@ -878,6 +878,9 @@ check_result:
>  	}
>  
>  fall_back:
> +	if (mi->version.v_mode == V_GENERAL)
> +		/* v2,3 fallback not allowed */
> +		return result;
>  	return nfs_try_mount_v3v2(mi, FALSE);
>  }
>  
> 
> 
> I haven't even compile-tested of course :-)
I have and it does compile and work... Would you
mind reposting the patch in the proper format?
You can added Tested-by: Steve Dickson <steved@redhat.com>

Note: The second patch should probably use V_GENERAL as well.

tia,

steved.
> 
> Thanks,
> NeilBrown
> 
> 
>>
>> steved.
>>
>>>
>>> Thanks,
>>> NeilBrown
>>>
>>>
>>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>>  utils/mount/network.c | 3 ++-
>>>>  utils/mount/network.h | 8 ++++----
>>>>  2 files changed, 6 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>>> index 281e935..e39263e 100644
>>>> --- a/utils/mount/network.c
>>>> +++ b/utils/mount/network.c
>>>> @@ -1299,7 +1299,8 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
>>>>  		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
>>>>  			goto ret_error;
>>>>  		version->v_mode = V_SPECIFIC;
>>>> -	} else if (version->major > 3 && *cptr == '\0')
>>>> +	} else if (version->major > 3 && *cptr == '\0' &&
>>>> +			version->v_mode == V_DEFAULT) /* v_mode has not been set */
>>>>  		version->v_mode = V_GENERAL;
>>>>  
>>>>  	if (*cptr != '\0')
>>>> diff --git a/utils/mount/network.h b/utils/mount/network.h
>>>> index 9cc5dec..45e2b24 100644
>>>> --- a/utils/mount/network.h
>>>> +++ b/utils/mount/network.h
>>>> @@ -58,10 +58,10 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
>>>>  struct mount_options;
>>>>  
>>>>  enum {
>>>> -	V_DEFAULT = 0,
>>>> -	V_GENERAL,
>>>> -	V_SPECIFIC,
>>>> -	V_PARSE_ERR,
>>>> +	V_DEFAULT = 0, /* not set */
>>>> +	V_GENERAL,     /* single digit => 4 */
>>>> +	V_SPECIFIC,    /* single digit < 4 or decimal included */
>>>> +	V_PARSE_ERR,   /* miss all others */
>>>>  };
>>>>  
>>>>  struct nfs_version {
>>>> -- 
>>>> 2.9.4
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
