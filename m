From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] statd: not unlinking host files
Date: Mon, 8 Dec 2008 18:48:22 -0500
Message-ID: <E1EBCB84-864D-4463-811F-4B2610BCABFA@oracle.com>
References: <493A8D71.20603@RedHat.com> <20081208233355.GB24083@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54497 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452AbYLHXso (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Dec 2008 18:48:44 -0500
In-Reply-To: <20081208233355.GB24083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 8, 2008, at Dec 8, 2008, 6:33 PM, J. Bruce Fields wrote:
> On Sat, Dec 06, 2008 at 09:34:25AM -0500, Steve Dickson wrote:
>> Again working with the state file code, I notice that statd was
>> not unlinking hosts files when the kernel sent up the
>> sm_unmon messages. This following patch address the reason why...
>>
>> Comments?
>
> Bizarre--thanks for catching that.
>
> But it looks like these are actually the only two callers to xunlink?
> In which case, we should just ditch the "check" parameter entirely and
> avoid some confusion....

It looks like xunlink() doesn't check error returns properly either.   
alloca() is a convenience, but the price is a SIGSEGV if the stack  
frame can't be extended.

For a system-level daemon like rpc.statd, I would rather see a proper  
implementation of this using malloc(3) or automatic storage, and  
ensuring that sprintf doesn't overrun its buffer.  This also makes it  
possible to track the buffer allocation here using valgrind.  alloca()  
is a completely inline implementation, according to its man page.

I'm not sure why statd has it's own implementation of xstrdup and  
xmalloc here as well; support/nfs/* already has both of these.  It  
would be worth getting rid of these too.

> (I wonder how it ever got this way in the first case?)

Likely that rpc.statd was integrated into nfs-utils a long time ago  
from somewhere else that needed the switch argument.

>
>
> --b.
>
>>
>> steved.
>>
>> commit f8536d0e210a8151900f8c68185927790239eb62
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Sat Dec 6 09:30:43 2008 -0500
>>
>>    statd: not unlinking host files
>>
>>    Statd is not unlinking host files during SM_UNMON and
>>    SM_UNMON_ALL calls because the given host is still on the run-time
>>    notify list (rtnl) and the check flag is set when xunlink() is
>>    called. But the next thing the caller of xunlink() does is
>>    remove the host from the rtnl list which means the
>>    unlink will never happen.
>>
>>    So in cases where xunlink() is immediately follow by a call
>>    to nlist_free() (which removes the host from the list) the
>>    check flag to xunlink() is not set.
>>
>>    Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
>> index a6a1d9c..7d6e4da 100644
>> --- a/utils/statd/monitor.c
>> +++ b/utils/statd/monitor.c
>> @@ -352,7 +352,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct  
>> svc_req *rqstp)
>> 			/* PRC: do the HA callout: */
>> 			ha_callout("del-client", mon_name, my_name, -1);
>>
>> -			xunlink(SM_DIR, clnt->dns_name, 1);
>> +			xunlink(SM_DIR, clnt->dns_name, 0);
>> 			nlist_free(&rtnl, clnt);
>>
>> 			return (&result);
>> @@ -404,7 +404,7 @@ sm_unmon_all_1_svc(struct my_id *argp, struct  
>> svc_req *rqstp)
>> 			temp = NL_NEXT(clnt);
>> 			/* PRC: do the HA callout: */
>> 			ha_callout("del-client", mon_name, my_name, -1);
>> -			xunlink(SM_DIR, clnt->dns_name, 1);
>> +			xunlink(SM_DIR, clnt->dns_name, 0);
>> 			nlist_free(&rtnl, clnt);
>> 			++count;
>> 			clnt = temp;
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




