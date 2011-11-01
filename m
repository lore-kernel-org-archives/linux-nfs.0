Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40660 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753966Ab1KAOWc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 10:22:32 -0400
Message-ID: <4EB000A6.9040508@netapp.com>
Date: Tue, 01 Nov 2011 10:22:30 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Added fault injection
References: <1319455259-3136-1-git-send-email-bjschuma@netapp.com> <20111028212450.GA7441@fieldses.org> <4EAFFD65.4010407@netapp.com> <20111101141746.GD32248@fieldses.org>
In-Reply-To: <20111101141746.GD32248@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 01 Nov 2011 10:17:46 AM EDT, J. Bruce Fields wrote:
> On Tue, Nov 01, 2011 at 10:08:37AM -0400, Bryan Schumaker wrote:
>> On Fri 28 Oct 2011 05:24:50 PM EDT, J. Bruce Fields wrote:
>>> On Mon, Oct 24, 2011 at 07:20:57AM -0400, bjschuma@netapp.com wrote:
>>> ...
>>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>>> index db34a58..e67f30c 100644
>>>> --- a/fs/nfsd/nfsctl.c
>>>> +++ b/fs/nfsd/nfsctl.c
>>> ...
>>>> @@ -1130,6 +1131,9 @@ static int __init init_nfsd(void)
>>>>  	retval = nfs4_state_init(); /* nfs4 locking state */
>>>>  	if (retval)
>>>>  		return retval;
>>>> +	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
>>>> +	if (retval)
>>>> +		goto out_cleanup_fault_injection;
>>>>  	nfsd_stat_init();	/* Statistics */
>>>>  	retval = nfsd_reply_cache_init();
>>>>  	if (retval)
>>>> @@ -1161,6 +1165,8 @@ out_free_cache:
>>>>  out_free_stat:
>>>>  	nfsd_stat_shutdown();
>>>>  	nfsd4_free_slabs();
>>>> +out_cleanup_fault_injection:
>>>> +	nfsd_fault_inject_cleanup();
>>>
>>> Check the cleanup here again....  The slabs are allocated in state_init,
>>> so you need to do that on nfsd_fault_inject_init, but you *don't* need
>>> the fault_inject_cleanup in that case, since fault_inject_init cleanup
>>> cleans up after itself--that's needed only on later failures.
>>
>> Would it be better to change the fault_inject_init() function so it 
>> doesn't clean up after itself?  This would keep it consistent with the 
>> other nfsd init functions.
>
> I don't think so.  The pattern here is pretty common throughout the
> kernel; it's approximately:
>
> 	do_thing1();
> 	err = do_thing2();
> 	if (err)
> 		goto undo_thing1;
> 	err = do_thing3();
> 	if (err)
> 		goto undo_thing2;
> 	...
>
> Functions are no-ops on failure, and the caller's just responsible for
> cleaning up previous stuff.

Ok, I won't change that.

>
>> I didn't realize that slabs were initialized in the state_init()
>> function, I'll fix that.
>
> I'll admit that's confusing.  Any suggestion to make it clearer welcome.

Sure.  The comment after the call to nfs4_state_init() is "nfs4 locking 
state".  Maybe this could be changed to "nfs4 locking state and slabs"? 
 I can make this change and send it as a separate patch if you would 
like.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


