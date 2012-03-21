Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:36864 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760510Ab2CUVf1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 17:35:27 -0400
Subject: Re: [PATCH] RFC: export options for junctions
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120321212937.GG12309@fieldses.org>
Date: Wed, 21 Mar 2012 17:35:17 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0F4CD350-9CAE-47B8-9FA3-FE80C5742A7F@oracle.com>
References: <20120302195451.18167.81861.stgit@degas.1015granger.net> <20120320195607.GD1431@fieldses.org> <FD566AE0-4B3E-413B-AA04-AD3BDB97A6E9@oracle.com> <20120321212937.GG12309@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 21, 2012, at 5:29 PM, J. Bruce Fields wrote:

> On Wed, Mar 21, 2012 at 05:11:40PM -0400, Chuck Lever wrote:
>> Hi-
>> 
>> On Mar 20, 2012, at 3:56 PM, J. Bruce Fields wrote:
>> 
>>> On Fri, Mar 02, 2012 at 02:54:51PM -0500, Chuck Lever wrote:
>>>> At Connectathon, I ran my FedFS-enabled client in a guest environment
>>>> with NAT networking.  This made the source port for my NFS connections
>>>> unprivileged.
>>>> 
>>>> Attempting to access a junction on my test server failed with a
>>>> "client insecure" error on the server, even if I specified the
>>>> "insecure" export option on the parent export.  I added "insecure" to
>>>> the default junction export options, and this fixed the problem.
>>>> 
>>>> Bruce suggested, however, that the correct way to address this is to
>>>> have junctions inherit the export options of their parent.  I don't
>>>> see a direct way to do this, so I'm posting this patch as a
>>>> conversation starter.
>>> 
>>> I think you want to do something like the search in
>>> nfs-utils/utils/mountd/cache.c:lookup_export()--look for the export with
>>> the longest matching path, and copy options from that.
>> 
>> This still looks hopelessly complex.
> 
> I bet there's an easy way to do it if we just modify the right code.
> Remind me where your nfs-utils patches live, and maybe I could take a
> look?

I admit to not being at all familiar with mountd's export cache, so I simply haven't found anything that appears to do what is needed.

Steve has already taken the basic junction support patch, so you can just grab a copy of the current nfs-utils git repo.  Junction supported was added with commit ab74900f (according to my copy of his repo).

Thanks very much for your time.

> --b.
> 
>> 
>>  1.  We have to create a version of lookup_export() that does exactly what's needed to find the junction's parent.
>> 
>>  2.  Once we find the parent's exportent, we have to reverse parse the data in that exportent to get an options string, and concatenate that to the options string we're building for the junction itself.
>> 
>>  3.  Once we have the full options string for the junction, we use mkexportent() to convert it all back into another exportent.  (or is there a simple way to merge the exportents?)
>> 
>>  4.  Then, we send the referral data to the kernel by converting that exportent back into a string with dump_to_cache().
>> 
>> For the time being, though a kludge, it seems easiest by far to simply stick the "insecure" option on all junctions.  I don't think this is otherwise terribly risky.
>> 
>> Maybe at some later point we can think of a cleaner way to approach this?  Is there a possible kernel solution for this (ie something that can be done in the kernel's export cache only for referrals)?
>> 
>>> --b.
>>> 
>>>> 
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> 
>>>> utils/mountd/cache.c |    2 +-
>>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>> 
>>>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>>> index ac9cdbd..35bc2e9 100644
>>>> --- a/utils/mountd/cache.c
>>>> +++ b/utils/mountd/cache.c
>>>> @@ -853,7 +853,7 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
>>>> 			ptr += len;
>>>> 		} else {
>>>> 			if (last_path == NULL)
>>>> -				len = snprintf(ptr, remaining, "refer=%s@%s",
>>>> +				len = snprintf(ptr, remaining, "insecure,refer=%s@%s",
>>>> 							rootpath, server);
>>>> 			else
>>>> 				len = snprintf(ptr, remaining, ":%s@%s",
>>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




