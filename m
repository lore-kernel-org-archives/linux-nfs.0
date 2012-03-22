Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:35997 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759266Ab2CVTe1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 15:34:27 -0400
Subject: Re: [PATCH] RFC: export options for junctions
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <D513613A-0CA8-4011-8371-2F2957A87317@oracle.com>
Date: Thu, 22 Mar 2012 15:34:18 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9C3B5489-2045-4D14-9FEE-81E831C56EA8@oracle.com>
References: <20120302195451.18167.81861.stgit@degas.1015granger.net> <20120320195607.GD1431@fieldses.org> <FD566AE0-4B3E-413B-AA04-AD3BDB97A6E9@oracle.com> <20120321212937.GG12309@fieldses.org> <0F4CD350-9CAE-47B8-9FA3-FE80C5742A7F@oracle.com> <20120322105938.GB17569@fieldses.org> <D513613A-0CA8-4011-8371-2F2957A87317@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 22, 2012, at 3:28 PM, Chuck Lever wrote:

> 
> On Mar 22, 2012, at 6:59 AM, J. Bruce Fields wrote:
> 
>> On Wed, Mar 21, 2012 at 05:35:17PM -0400, Chuck Lever wrote:
>>> 
>>> On Mar 21, 2012, at 5:29 PM, J. Bruce Fields wrote:
>>> 
>>>> On Wed, Mar 21, 2012 at 05:11:40PM -0400, Chuck Lever wrote:
>>>>> 1.  We have to create a version of lookup_export() that does exactly what's needed to find the junction's parent.
>>>>> 
>>>>> 2.  Once we find the parent's exportent, we have to reverse parse the data in that exportent to get an options string, and concatenate that to the options string we're building for the junction itself.
>>>>> 
>>>>> 3.  Once we have the full options string for the junction, we use mkexportent() to convert it all back into another exportent.  (or is there a simple way to merge the exportents?)
>> 
>> You should be able to skip steps 2 and 3 and use dupexportent.
>> 
>> Does that sound doable?
> 
> The current junction lookup logic uses mkexportent(), which returns a statically allocated exportent that doesn't need to be freed.  That makes the lookup_junction() call site simple, but that's too clever by half.  Using dupexportent() unchanged would require some reworking there in order to free the duplicated exportent.
> 
> Also I'm not quite sure how to safely combine the use of mkexportent(), which parses the referral options we just created, and dupexportent(), which would duplicate the options from the parent, but would walk on e_hostname.
> 
> I could address both those problems by constructing a new function which was an amalgam of the two.

updateexportent() might do the trick.

> I still have to play with the lookup_export() logic to see how to find a junction's parent export.
> 
>> --b.
>> 
>>>>> 
>>>>> 4.  Then, we send the referral data to the kernel by converting that exportent back into a string with dump_to_cache().
>>>>> 
>>>>> For the time being, though a kludge, it seems easiest by far to simply stick the "insecure" option on all junctions.  I don't think this is otherwise terribly risky.
>>>>> 
>>>>> Maybe at some later point we can think of a cleaner way to approach this?  Is there a possible kernel solution for this (ie something that can be done in the kernel's export cache only for referrals)?
>>>>> 
>>>>>> --b.
>>>>>> 
>>>>>>> 
>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>> ---
>>>>>>> 
>>>>>>> utils/mountd/cache.c |    2 +-
>>>>>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>>>>> 
>>>>>>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>>>>>> index ac9cdbd..35bc2e9 100644
>>>>>>> --- a/utils/mountd/cache.c
>>>>>>> +++ b/utils/mountd/cache.c
>>>>>>> @@ -853,7 +853,7 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
>>>>>>> 			ptr += len;
>>>>>>> 		} else {
>>>>>>> 			if (last_path == NULL)
>>>>>>> -				len = snprintf(ptr, remaining, "refer=%s@%s",
>>>>>>> +				len = snprintf(ptr, remaining, "insecure,refer=%s@%s",
>>>>>>> 							rootpath, server);
>>>>>>> 			else
>>>>>>> 				len = snprintf(ptr, remaining, ":%s@%s",
>>>>>>> 
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>> 
>>>>> -- 
>>>>> Chuck Lever
>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>> 
>>>>> 
>>>>> 
>>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>>> -- 
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>> 
>>> 
>>> 
>>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




