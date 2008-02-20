From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] lockd: fix race in nlm_release()
Date: Wed, 20 Feb 2008 17:10:24 -0500
Message-ID: <022C8A98-7487-475C-AD9C-89DDB2B1252C@oracle.com>
References: <20080220191153.GG30160@fieldses.org> <1203535466.15034.5.camel@heimdal.trondhjem.org> <20080220192759.GI30160@fieldses.org> <1203536918.15034.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48231 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759493AbYBTWKx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2008 17:10:53 -0500
In-Reply-To: <1203536918.15034.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 20, 2008, at 2:48 PM, Trond Myklebust wrote:
> On Wed, 2008-02-20 at 14:27 -0500, J. Bruce Fields wrote:
>> On Wed, Feb 20, 2008 at 02:24:26PM -0500, Trond Myklebust wrote:
>>>
>>> On Wed, 2008-02-20 at 14:11 -0500, J. Bruce Fields wrote:
>>>> From: J. Bruce Fields <bfields@citi.umich.edu>
>>>>
>>>> The sm_count is decremented to zero but left on the nsm_handles  
>>>> list.
>>>> So in the space between decrementing sm_count and acquiring  
>>>> nsm_mutex,
>>>> it is possible for another task to find this nsm_handle,  
>>>> increment the
>>>> use count and then enter nsm_release itself.
>>>>
>>>> Thus there's nothing to prevent the nsm being freed before we  
>>>> acquire
>>>> nsm_mutex here.
>>>>
>>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>>> ---
>>>>  fs/lockd/host.c |   10 ++++------
>>>>  1 files changed, 4 insertions(+), 6 deletions(-)
>>>>
>>>> Am I missing something here?--b.
>>>>
>>>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>>>> index c3f1194..960911c 100644
>>>> --- a/fs/lockd/host.c
>>>> +++ b/fs/lockd/host.c
>>>> @@ -529,12 +529,10 @@ nsm_release(struct nsm_handle *nsm)
>>>>  {
>>>>  	if (!nsm)
>>>>  		return;
>>>> +	mutex_lock(&nsm_mutex);
>>>>  	if (atomic_dec_and_test(&nsm->sm_count)) {
>>>> -		mutex_lock(&nsm_mutex);
>>>> -		if (atomic_read(&nsm->sm_count) == 0) {
>>>> -			list_del(&nsm->sm_link);
>>>> -			kfree(nsm);
>>>> -		}
>>>> -		mutex_unlock(&nsm_mutex);
>>>> +		list_del(&nsm->sm_link);
>>>> +		kfree(nsm);
>>>>  	}
>>>> +	mutex_unlock(&nsm_mutex);
>>>>  }
>>>
>>> It would be nice to get rid of that mutex. That should really be  
>>> either
>>> a spinlock or an rcu-protected list...
>>
>> OK, I'll look into doing that next.
>>
>> If you've got any other suggestions while I'm in the general area,  
>> I'm
>> all ears.
>
> Just the usual plea to replace the host->h_server flag with 2 separate
> lists: one list of client nlm_hosts, and one list of server
> nlm_hosts :-)

I have no objection to that, but my NLM IPv6 patches will be  
significantly affected by such a change right at this point.  Can we  
hold off until the IPv6 work is integrated, or make this change part  
of the IPv6 work itself?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
