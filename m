Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18349 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202Ab0K3PLh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 10:11:37 -0500
Subject: Re: [PATCH] mount: avoid po_destroy to modify errno what we really want
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CF45BD9.20908@cn.fujitsu.com>
Date: Tue, 30 Nov 2010 10:11:09 -0500
Cc: Steve Dickson <SteveD@redhat.com>, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>
Message-Id: <D05BF4A3-1BD5-4FC3-8921-A9D9DC5D8634@oracle.com>
References: <4CEE357D.2030007@cn.fujitsu.com> <9C08C339-281F-4CD4-B8C1-70441869E2F6@oracle.com> <4CF3C4D2.2060607@RedHat.com> <4CF45BD9.20908@cn.fujitsu.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bian

On Nov 29, 2010, at 9:05 PM, Bian Naimeng wrote:

> 
> 
> Steve Dickson wrote:
>> 
>> On 11/29/2010 09:45 AM, Chuck Lever wrote:
>>> On Nov 25, 2010, at 5:07 AM, Mi Jinlong wrote:
>>> 
>>>> We should return the errno that was set before po_destroy,
>>>> rather than the errno that was set at po_destroy.
>>>> 
>>>> Because the po_destroy function don't affect the return value,
>>>> this patch just revert the saved errno after po_destroy.
>>> The only library function used in po_destroy() is free(3).  
>>> Does free(3) change the value of errno?
>> Looking at the man page and taking a look a the 
>> glibc code it appears the answer is no. free(3)
>> does not set errno.
>> 
>> Bian, what was the problem you were seeing that this
>> patch fixed? 
>> 
> 
> Actually, there's no problem now. But this's not a good style, po_destroy
> maybe change the errno later on such as adding a printf.
> So if somebady want modify the po_destroy, he must be careful of it. :)
> 
> And, i don't think it's a good idea that explicitly set errno, it maybe make
> some trouble in the future. It's better returning error in nfs_do_mount_v3v2,
> or save the error in a input parameter. :)

Perhaps it isn't good style, but I'd rather see all of stropts.c updated to pass errno as an explicit parameter than to have it changed piecemeal.  I agree that we run into trouble everywhere in mount with errno.

I think this particular patch is unnecessary until we have a need for it.  Basically it confuses a reviewer who sees that we've gone to the trouble here to save and restore errno, but nowhere else, and besides po_destroy() doesn't even alter errno.  Why are we bothering?

> Thanks
>  Bian
> 
>> steved.
>> 
>>>> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
>>>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>>>> ---
>>>> utils/mount/stropts.c |    8 ++++++--
>>>> 1 files changed, 6 insertions(+), 2 deletions(-)
>>>> 
>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>> index 50a1a2a..d554877 100644
>>>> --- a/utils/mount/stropts.c
>>>> +++ b/utils/mount/stropts.c
>>>> @@ -592,7 +592,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>>>> 		struct sockaddr *sap, socklen_t salen)
>>>> {
>>>> 	struct mount_options *options = po_dup(mi->options);
>>>> -	int result = 0;
>>>> +	int result = 0, save = 0;
>>>> 
>>>> 	if (!options) {
>>>> 		errno = ENOMEM;
>>>> @@ -637,7 +637,9 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>>>> 	result = nfs_sys_mount(mi, options);
>>>> 
>>>> out_fail:
>>>> +	save = errno;
>>>> 	po_destroy(options);
>>>> +	errno = save;
>>>> 	return result;
>>>> }
>>>> 
>>>> @@ -673,7 +675,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>>>> 		struct sockaddr *sap, socklen_t salen)
>>>> {
>>>> 	struct mount_options *options = po_dup(mi->options);
>>>> -	int result = 0;
>>>> +	int result = 0, save = 0;
>>>> 
>>>> 	if (!options) {
>>>> 		errno = ENOMEM;
>>>> @@ -724,7 +726,9 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>>>> 	result = nfs_sys_mount(mi, options);
>>>> 
>>>> out_fail:
>>>> +	save = errno;
>>>> 	po_destroy(options);
>>>> +	errno = save;
>>>> 	return result;
>>>> }
>>>> 
>>>> -- 
>>>> 1.7.3.2
>>>> 
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> 
> 
> -- 
> Regards
> Bian Naimeng
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




