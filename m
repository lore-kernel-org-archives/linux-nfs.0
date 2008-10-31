From: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Subject: Re: [PATCH] NLM: Set address family before calling nlm_host_rebooted()
Date: Fri, 31 Oct 2008 13:39:29 -0400
Message-ID: <A34BAC35-D8FB-4DD2-8A1F-6780FD0914C5@ORACLE.COM>
References: <20081023044245.15258.55293.stgit@ingres.1015granger.net> <20081023205820.GB26419@fieldses.org> <BF3BC6B3-D58F-43B1-AACD-284DDFA291DC@ORACLE.COM> <20081030212856.GB24156@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:57950 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbYJaRj5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2008 13:39:57 -0400
In-Reply-To: <20081030212856.GB24156@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 30, 2008, at Oct 30, 2008, 5:28 PM, J. Bruce Fields wrote:
> On Thu, Oct 23, 2008 at 05:32:54PM -0400, Chuck Lever wrote:
>> On Oct 23, 2008, at Oct 23, 2008, 4:58 PM, J. Bruce Fields wrote:
>>> On Thu, Oct 23, 2008 at 12:50:35AM -0400, Chuck Lever wrote:
>>>> The nlm_host_rebooted() function uses nlm_cmp_addr() to find an
>>>> nsm_handle that matches the rebooted peer.  In order for this to
>>>> work,
>>>> the passed-in address must have a proper address family.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>
>>> Thanks!
>>>
>>>> Bruce - since we dropped the remaining NSM IPv6 patches for  
>>>> 2.6.28, I
>>>> think we need to add this one to make sure lock recovery  
>>>> continues to
>>>> work.
>>>
>>> So this is a regression?  (If so, when was it introduced?)
>>
>> I think this was introduced when AF_INET6 support was added to
>> nlm_cmp_addr() in commit 781b61a6.  Before that commit,  
>> nlm_cmp_addr()
>> didn't care about the address family; it compared only the
>> sin_addr.s_addr field for equality.
>>
>> This is a regression in the sense that it probably broke lock  
>> recovery
>> in .28, but I don't think this is a problem in any released kernel.
>
> OK, thanks, I've queed this up for 2.6.28, as below.
>
>>
>>> Have you tested lock recovery?  I'll see if I can get some sort of
>>> lock
>>> recovery test running as part of my default regression tests this
>>> weekend....  It seems to be something that hasn't been watched  
>>> closely
>>> enough.
>>
>> Sankar has a lock recovery test.  He didn't report a problem with  
>> lock
>> recovery with the full set of patches I had for 2.6.28.  He never  
>> tested
>> what is actually in .28 now, which is missing those NSM patches.
>>
>> I'm preparing my latest patches for him to try out soon.
>
> (Though confirmation that it's been tested would certainly be
> reassuring--all it takes is grabbing a lock, rebooting a server,
> verifying that the lock is reclaimed, and also doing the same with a
> client and making sure locks are dropped.)

I tested a 2.6.28-rc2 kernel on the server side with and without the  
fix.  I rebooted the client with "echo b > /proc/sysrq_trigger" for  
this test.

If the server doesn't have the fix, I see the "never saw host x.x.x.x"  
message on the server after the client reboots.  If the fix is  
applied, I see the "nlm_host_rebooted (x.x.x.x)" message on the server  
after the client reboots.

So, confirmed that this is a bug in 2.6.28-rc2, and confirmed that the  
below patch addresses the problem.  The NSM logic is the same on the  
client and the server, so I didn't test a server reboot.

> --b.
>
> commit d7dc61d0a70371b1c6557ea8ffbc60fff94c8168
> Author: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
> Date:   Thu Oct 23 00:50:35 2008 -0400
>
>    NLM: Set address family before calling nlm_host_rebooted()
>
>    The nlm_host_rebooted() function uses nlm_cmp_addr() to find an
>    nsm_handle that matches the rebooted peer.  In order for this to  
> work,
>    the passed-in address must have a proper address family.
>
>    This fixes a post-2.6.28 regression introduced by commit  
> 781b61a6, which
>    added AF_INET6 support to nlm_cmp_addr().  Before that commit,
>    nlm_cmp_addr() didn't care about the address family; it compared  
> only
>    the sin_addr.s_addr field for equality.
>
>    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>
> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> index 014f6ce..4dfdcbc 100644
> --- a/fs/lockd/svc4proc.c
> +++ b/fs/lockd/svc4proc.c
> @@ -434,6 +434,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp,  
> struct nlm_reboot *argp,
> 	 * reclaim all locks we hold on this server.
> 	 */
> 	memset(&saddr, 0, sizeof(saddr));
> +	saddr.sin_family = AF_INET;
> 	saddr.sin_addr.s_addr = argp->addr;
> 	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
>
> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> index 548b0bb..3ca89e2 100644
> --- a/fs/lockd/svcproc.c
> +++ b/fs/lockd/svcproc.c
> @@ -466,6 +466,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp,  
> struct nlm_reboot *argp,
> 	 * reclaim all locks we hold on this server.
> 	 */
> 	memset(&saddr, 0, sizeof(saddr));
> +	saddr.sin_family = AF_INET;
> 	saddr.sin_addr.s_addr = argp->addr;
> 	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




