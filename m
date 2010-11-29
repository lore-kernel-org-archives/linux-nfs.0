Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6868 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753257Ab0K2PU7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 10:20:59 -0500
Message-ID: <4CF3C4D2.2060607@RedHat.com>
Date: Mon, 29 Nov 2010 10:20:50 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount: avoid po_destroy to modify errno what we really
 want
References: <4CEE357D.2030007@cn.fujitsu.com> <9C08C339-281F-4CD4-B8C1-70441869E2F6@oracle.com>
In-Reply-To: <9C08C339-281F-4CD4-B8C1-70441869E2F6@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 11/29/2010 09:45 AM, Chuck Lever wrote:
> 
> On Nov 25, 2010, at 5:07 AM, Mi Jinlong wrote:
> 
>> We should return the errno that was set before po_destroy,
>> rather than the errno that was set at po_destroy.
>>
>> Because the po_destroy function don't affect the return value,
>> this patch just revert the saved errno after po_destroy.
> 
> The only library function used in po_destroy() is free(3).  
> Does free(3) change the value of errno?
Looking at the man page and taking a look a the 
glibc code it appears the answer is no. free(3)
does not set errno.

Bian, what was the problem you were seeing that this
patch fixed? 

steved.

> 
>> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>> utils/mount/stropts.c |    8 ++++++--
>> 1 files changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 50a1a2a..d554877 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -592,7 +592,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>> 		struct sockaddr *sap, socklen_t salen)
>> {
>> 	struct mount_options *options = po_dup(mi->options);
>> -	int result = 0;
>> +	int result = 0, save = 0;
>>
>> 	if (!options) {
>> 		errno = ENOMEM;
>> @@ -637,7 +637,9 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>> 	result = nfs_sys_mount(mi, options);
>>
>> out_fail:
>> +	save = errno;
>> 	po_destroy(options);
>> +	errno = save;
>> 	return result;
>> }
>>
>> @@ -673,7 +675,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>> 		struct sockaddr *sap, socklen_t salen)
>> {
>> 	struct mount_options *options = po_dup(mi->options);
>> -	int result = 0;
>> +	int result = 0, save = 0;
>>
>> 	if (!options) {
>> 		errno = ENOMEM;
>> @@ -724,7 +726,9 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>> 	result = nfs_sys_mount(mi, options);
>>
>> out_fail:
>> +	save = errno;
>> 	po_destroy(options);
>> +	errno = save;
>> 	return result;
>> }
>>
>> -- 
>> 1.7.3.2
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
