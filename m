From: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Subject: Re: [PATCH] NLM: Set address family before calling nlm_host_rebooted()
Date: Thu, 23 Oct 2008 17:32:54 -0400
Message-ID: <BF3BC6B3-D58F-43B1-AACD-284DDFA291DC@ORACLE.COM>
References: <20081023044245.15258.55293.stgit@ingres.1015granger.net> <20081023205820.GB26419@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:59714 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbYJWVdJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2008 17:33:09 -0400
In-Reply-To: <20081023205820.GB26419@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 23, 2008, at Oct 23, 2008, 4:58 PM, J. Bruce Fields wrote:
> On Thu, Oct 23, 2008 at 12:50:35AM -0400, Chuck Lever wrote:
>> The nlm_host_rebooted() function uses nlm_cmp_addr() to find an
>> nsm_handle that matches the rebooted peer.  In order for this to  
>> work,
>> the passed-in address must have a proper address family.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>
> Thanks!
>
>> Bruce - since we dropped the remaining NSM IPv6 patches for 2.6.28, I
>> think we need to add this one to make sure lock recovery continues to
>> work.
>
> So this is a regression?  (If so, when was it introduced?)

I think this was introduced when AF_INET6 support was added to  
nlm_cmp_addr() in commit 781b61a6.  Before that commit, nlm_cmp_addr()  
didn't care about the address family; it compared only the  
sin_addr.s_addr field for equality.

This is a regression in the sense that it probably broke lock recovery  
in .28, but I don't think this is a problem in any released kernel.

> Have you tested lock recovery?  I'll see if I can get some sort of  
> lock
> recovery test running as part of my default regression tests this
> weekend....  It seems to be something that hasn't been watched closely
> enough.

Sankar has a lock recovery test.  He didn't report a problem with lock  
recovery with the full set of patches I had for 2.6.28.  He never  
tested what is actually in .28 now, which is missing those NSM patches.

I'm preparing my latest patches for him to try out soon.

> --b.
>
>
>>
>> Please consider this one for 2.6.28.
>>
>> fs/lockd/svc4proc.c |    1 +
>> fs/lockd/svcproc.c  |    1 +
>> 2 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
>> index 014f6ce..4dfdcbc 100644
>> --- a/fs/lockd/svc4proc.c
>> +++ b/fs/lockd/svc4proc.c
>> @@ -434,6 +434,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp,  
>> struct nlm_reboot *argp,
>> 	 * reclaim all locks we hold on this server.
>> 	 */
>> 	memset(&saddr, 0, sizeof(saddr));
>> +	saddr.sin_family = AF_INET;
>> 	saddr.sin_addr.s_addr = argp->addr;
>> 	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
>>
>> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
>> index 548b0bb..3ca89e2 100644
>> --- a/fs/lockd/svcproc.c
>> +++ b/fs/lockd/svcproc.c
>> @@ -466,6 +466,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp,  
>> struct nlm_reboot *argp,
>> 	 * reclaim all locks we hold on this server.
>> 	 */
>> 	memset(&saddr, 0, sizeof(saddr));
>> +	saddr.sin_family = AF_INET;
>> 	saddr.sin_addr.s_addr = argp->addr;
>> 	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




