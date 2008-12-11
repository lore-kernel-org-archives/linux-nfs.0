From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 18/27] NSM: Refactor nsm_handle creation into a helper function
Date: Thu, 11 Dec 2008 12:09:49 -0500
Message-ID: <C1536996-3F69-458A-87D9-B7BE91043626@oracle.com>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000409.24075.37859.stgit@ingres.1015granger.net> <20081210232830.GP1212@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:16669 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755795AbYLKRKG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 12:10:06 -0500
In-Reply-To: <20081210232830.GP1212@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 10, 2008, at Dec 10, 2008, 6:28 PM, J. Bruce Fields wrote:
> On Fri, Dec 05, 2008 at 07:04:09PM -0500, Chuck Lever wrote:
>> Clean up.
>
> The nsm_create_handle() thing is fine, but
>
>>
>> We're about to get rid of the "goto retry" in nsm_get_handle().
>
> I'm not that interested in removing the "goto retry".  I realize  
> tastes
> differ here, but I don't see a great improvement.  The:
>
> 	retry:
> 		look for something
> 		oops, not there, allocate a new one
> 		goto retry
>
> pattern is pretty common and I'm comfortable with it.

Would we need the retry at all if we replaced nsm_lock with a mutex?   
nlm_lookup_host() holds its mutex across a kzalloc() call.  We could  
do the same here, and it would make this much more straightforward.

Is there any real need for the atomic_dec_and_lock in nsm_release(),  
for example?  That's not exactly a performance-critical code path.

> There's also a few conflicts that result from my dropping the changes
> that move the dprintk's out from under the spinlock, and I'm getting
> lazy....  Could you humor me here and rebase these last 10 patches  
> on my
> latest for-2.6.29:
>
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.29
>
> without futzing with this goto?
>
> From a quick skim the rest of the patches they seem reasonable.  If  
> you
> have more 2.6.29 patches, this'd be a good time to send them along as
> well.

>> To facilitate this, move the nsm_handle initialization logic to
>> a helper function.
>>
>> Fields are initialized in increasing address order to make efficient
>> use of CPU caches.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/mon.c |   41 ++++++++++++++++++++++++++++-------------
>> 1 files changed, 28 insertions(+), 13 deletions(-)
>>
>> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
>> index 4267a57..24857a8 100644
>> --- a/fs/lockd/mon.c
>> +++ b/fs/lockd/mon.c
>> @@ -240,6 +240,30 @@ static void nsm_init_private(struct nsm_handle  
>> *nsm)
>> 	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
>> }
>>
>> +static struct nsm_handle *nsm_create_handle(const struct sockaddr  
>> *sap,
>> +					    const size_t salen,
>> +					    const char *hostname,
>> +					    const size_t hostname_len)
>> +{
>> +	struct nsm_handle *new;
>> +
>> +	new = kzalloc(sizeof(*new) + hostname_len + 1, GFP_KERNEL);
>> +	if (unlikely(new == NULL))
>> +		return NULL;
>> +
>> +	atomic_set(&new->sm_count, 1);
>> +	new->sm_name = (char *)(new + 1);
>> +	memcpy(nsm_addr(new), sap, salen);
>> +	new->sm_addrlen = salen;
>> +	nsm_init_private(new);
>> +	nsm_display_address((const struct sockaddr *)&new->sm_addr,
>> +				new->sm_addrbuf, sizeof(new->sm_addrbuf));
>> +	memcpy(new->sm_name, hostname, hostname_len);
>> +	new->sm_name[hostname_len] = '\0';
>> +
>> +	return new;
>> +}
>> +
>> /**
>>  * nsm_get_handle - Find or create a cached nsm_handle
>>  * @sap: pointer to socket address of handle to find
>> @@ -299,20 +323,11 @@ retry:
>>
>> 	spin_unlock(&nsm_lock);
>>
>> -	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
>> -	if (nsm == NULL)
>> -		return NULL;
>> +	nsm = nsm_create_handle(sap, salen, hostname, hostname_len);
>> +	if (nsm != NULL)
>> +		goto retry;
>>
>> -	memcpy(nsm_addr(nsm), sap, salen);
>> -	nsm->sm_addrlen = salen;
>> -	nsm->sm_name = (char *) (nsm + 1);
>> -	memcpy(nsm->sm_name, hostname, hostname_len);
>> -	nsm->sm_name[hostname_len] = '\0';
>> -	nsm_init_private(nsm);
>> -	nsm_display_address((struct sockaddr *)&nsm->sm_addr,
>> -				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
>> -	atomic_set(&nsm->sm_count, 1);
>> -	goto retry;
>> +	return NULL;
>> }
>>
>> /**
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




