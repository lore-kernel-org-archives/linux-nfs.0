Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2874 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979Ab0LOQAK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 11:00:10 -0500
Subject: Re: [PATCH 12/22] pnfs-submit: wave2: rewrite validate_bitmap_values to obey spec
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <4D08E52F.4090609@panasas.com>
Date: Wed, 15 Dec 2010 10:59:59 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <23310505-F664-499A-A376-0A6F7052212A@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com> <1291944177-7819-13-git-send-email-iisaman@netapp.com> <4D08C961.3090702@panasas.com> <394DBE14-A569-4BEA-99CE-1CB268392449@netapp.com> <4D08DED8.9090208@panasas.com> <05BB6938-AA62-4381-B33F-2DDC60466B90@netapp.com> <4D08E52F.4090609@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 15, 2010, at 10:56 AM, Benny Halevy wrote:

> On 2010-12-15 17:43, Fred Isaman wrote:
>> 
>> On Dec 15, 2010, at 10:29 AM, Benny Halevy wrote:
>> 
>>> On 2010-12-15 16:11, Fred Isaman wrote:
>>>> 
>>>> On Dec 15, 2010, at 8:57 AM, Benny Halevy wrote:
>>>> 
>>>>> On 2010-12-10 03:22, Fred Isaman wrote:
>>>>>> It was checking that at least one known bit was set.  It needs to check
>>>>>> no unknown bit was set.  From RFC5661, section 20.6.3:
>>>>>> 
>>>>>> When a bit is set in the type mask that corresponds to an undefined
>>>>>> type of recallable object, NFS4ERR_INVAL MUST be returned.
>>>>>> 
>>>>>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>>>>> ---
>>>>>> fs/nfs/callback.h      |    1 +
>>>>>> fs/nfs/callback_proc.c |   27 ++++-----------------------
>>>>>> 2 files changed, 5 insertions(+), 23 deletions(-)
>>>>>> 
>>>>>> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
>>>>>> index b16dd1f..616c5c1 100644
>>>>>> --- a/fs/nfs/callback.h
>>>>>> +++ b/fs/nfs/callback.h
>>>>>> @@ -126,6 +126,7 @@ extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
>>>>>> #define RCA4_TYPE_MASK_OBJ_LAYOUT_MAX  9
>>>>>> #define RCA4_TYPE_MASK_OTHER_LAYOUT_MIN 12
>>>>>> #define RCA4_TYPE_MASK_OTHER_LAYOUT_MAX 15
>>>>>> +#define RCA4_TYPE_MASK_ALL 0xf31f
>>>>>> 
>>>>>> struct cb_recallanyargs {
>>>>>> 	struct sockaddr	*craa_addr;
>>>>>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>>>>>> index 61b3c66..d4aec46 100644
>>>>>> --- a/fs/nfs/callback_proc.c
>>>>>> +++ b/fs/nfs/callback_proc.c
>>>>>> @@ -661,28 +661,10 @@ out_putclient:
>>>>>> 	goto out;
>>>>>> }
>>>>>> 
>>>>>> -static inline bool
>>>>>> -validate_bitmap_values(const unsigned long *mask)
>>>>>> +static bool
>>>>>> +validate_bitmap_values(unsigned long mask)
>>>>>> {
>>>>>> -	int i;
>>>>>> -
>>>>>> -	if (*mask == 0)
>>>>>> -		return true;
>>>>>> -	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, mask) ||
>>>>>> -	    test_bit(RCA4_TYPE_MASK_WDATA_DLG, mask) ||
>>>>>> -	    test_bit(RCA4_TYPE_MASK_DIR_DLG, mask) ||
>>>>>> -	    test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, mask) ||
>>>>>> -	    test_bit(RCA4_TYPE_MASK_BLK_LAYOUT, mask))
>>>>>> -		return true;
>>>>>> -	for (i = RCA4_TYPE_MASK_OBJ_LAYOUT_MIN;
>>>>>> -	     i <= RCA4_TYPE_MASK_OBJ_LAYOUT_MAX; i++)
>>>>>> -		if (test_bit(i, mask))
>>>>>> -			return true;
>>>>>> -	for (i = RCA4_TYPE_MASK_OTHER_LAYOUT_MIN;
>>>>>> -	     i <= RCA4_TYPE_MASK_OTHER_LAYOUT_MAX; i++)
>>>>>> -		if (test_bit(i, mask))
>>>>>> -			return true;
>>>>>> -	return false;
>>>>>> +	return mask & ~RCA4_TYPE_MASK_ALL;
>>>>> 
>>>>> Hmm, shouldn't that be
>>>>> 	return (mask & ~RCA4_TYPE_MASK_ALL) == 0;
>>>>> 
>>>>> Benny
>>>>> 
>>>> 
>>>> Yes, you are right.
>>> 
>>> OK. This is fixed in my branch to be released asap.
>> 
>> Thanks.  I have a bunch more minor code cleanups that I'll send once I see what you have, unless you want them immediately. I'll also have a rebase of the pnfs-submit branch with the wave2 patches pushed down to the bottom shortly after I see your branch.
>> 
> 
> I prefer that you send them now.

OK, I'll send them in a few minutes.

> 
>>> I've reverted large parts of this patchset in the post-submit stream
>>> to restore layoutcommit and layoutreturn, but not their embedding in
>>> the CLOSE compound.  I also kept the cleanups and bug fixes.
>>> I'll send out the post-submit when it's ready.
>>> Some more work will be required to restore the original patches
>>> author and signoffees.
>>> 
>>> This is the list as of now:
>>> 
>>> pick af44531 Revert "pnfs-submit: wave2: remove forgotten layoutreturn struct definitions"
>>> pick c465549 Revert "pnfs-submit: Turn off layoutcommits"
>>> pick 0f4ba67 Revert "pnfs-submit: wave2: remove all LAYOUTRETURN code"
>>> pick 486db47 Revert "pnfs-submit: wave2: Remove LAYOUTRETURN from return on close"
>>> 
>>> pick 484c935 FIXME: roc should return layout on last close
>>> (This patch just adds a FIXME comment.)
>>> 
>> 
>> The above looks good.
>> 
>>> pick 8698772 Revert "pnfs-submit: wave2: remove cl_layoutrecalls list"
>>> pick 263879b Revert "pnfs-submit: wave2: Pull out all recall initiated LAYOUTRETURNS"
>>> pick 693765f Revert "pnfs-submit: wave2: Don't wait in layoutget"
>> 
>> Just note the Trond was highly resistant to the above.
>> 
> 
> I understand that in the forgetful client model but eventually returning the layout
> on close will be more efficient overall vs. having the server poll the client.
> 
>>> pick de56e11 Revert "pnfs-submit: wave2: check that partial LAYOUTGET return is ignored"
>>> 
>> 
>> We need some sort of check that we got what we asked for, given that the xdr code can chop the servers reply.
> 
> The post-submit world is supposed to handle partial layouts correctly, as this is required for 
> the obj and block layouts so we can't just blindly toss away partial layouts.
> 
> If the files layout driver won't support partial layouts we can restrict this (sigh, ugly)
> only for it.
> 
> Benny

Note the problem right now is that the xdr decoding function will only parse the first array element, and toss the rest.  That is the real reason for the check, and something that needs to be fixed.

Fred

> 
>> 
>> Fred
>> 
>>> Anything else you had in mind?
>>> 
>>> Benny
>>> 
>>>> 
>>>> Fred
>>>> 
>>>>>> }
>>>>>> 
>>>>>> __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
>>>>>> @@ -702,8 +684,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
>>>>>> 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
>>>>>> 
>>>>>> 	status = cpu_to_be32(NFS4ERR_INVAL);
>>>>>> -	if (!validate_bitmap_values((const unsigned long *)
>>>>>> -				    &args->craa_type_mask))
>>>>>> +	if (!validate_bitmap_values(args->craa_type_mask))
>>>>>> 		goto out;
>>>>>> 
>>>>>> 	status = cpu_to_be32(NFS4_OK);
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 

