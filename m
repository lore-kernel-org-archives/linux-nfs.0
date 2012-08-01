Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876Ab2HAMgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 08:36:11 -0400
Message-ID: <501922AD.5010301@RedHat.com>
Date: Wed, 01 Aug 2012 08:35:57 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@redhat.com>, Jim Rees <rees@umich.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] rpc.gssd: don't call poll() twice a second.
References: <20120731205931.GA32161@fieldses.org> <1343768449-32205-4-git-send-email-bfields@redhat.com> <9C74193E-FB49-48C3-A828-50EDE37C95AD@oracle.com> <20120731212744.GC1826@pad.fieldses.org> <844B5000-C257-4EB9-84D7-F6961A8A9F6C@oracle.com>
In-Reply-To: <844B5000-C257-4EB9-84D7-F6961A8A9F6C@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2012 06:29 PM, Chuck Lever wrote:
> 
> On Jul 31, 2012, at 2:27 PM, J. Bruce Fields wrote:
> 
>> On Tue, Jul 31, 2012 at 02:23:36PM -0700, Chuck Lever wrote:
>>>
>>> On Jul 31, 2012, at 2:00 PM, J. Bruce Fields wrote:
>>>
>>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>>>
>>>> Use ppoll instead.
>>>>
>>>> (This breaks compatibility with kernels before 2.6.16 and glibc before
>>>> 2.4).
>>>
>>> I think I prefer seeing this wrapped with some autoconf machinery to allow nfs-utils to continue to build on earlier systems.
>>
>> I was assuming we could drop support for older systems.
> 
> We went to a lot of trouble to get the IPv6 stuff to build correctly on older systems, and we still heard complaints.
> 
>> If not, then'd I'd much prefer to go back to the self-pipe trick than to
>> deal with autoconf and  ifdef'ing out all this stuff.
> 
> This patch is a tiny change.  I don't think autoconf in this case is onerous.  I'm happy to help you with it.
I think it would be work the effort... Let me know if I can help...

steved.
 
> 
>> --b.
>>
>>>
>>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>>> ---
>>>> utils/gssd/gssd_main_loop.c |   12 +++++-------
>>>> 1 file changed, 5 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
>>>> index 142c8c5..2d20fa2 100644
>>>> --- a/utils/gssd/gssd_main_loop.c
>>>> +++ b/utils/gssd/gssd_main_loop.c
>>>> @@ -186,13 +186,14 @@ gssd_run()
>>>> 	struct sigaction	dn_act = {
>>>> 		.sa_handler = dir_notify_handler
>>>> 	};
>>>> -	sigset_t		set;
>>>> +	sigset_t		set, emptyset;
>>>>
>>>> 	sigemptyset(&dn_act.sa_mask);
>>>> 	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
>>>>
>>>> -	/* just in case the signal is blocked... */
>>>> +	sigemptyset(&emptyset);
>>>> 	sigemptyset(&set);
>>>> +	/* just in case the signal is blocked... */
>>>> 	sigaddset(&set, DNOTIFY_SIGNAL);
>>>> 	sigprocmask(SIG_UNBLOCK, &set, NULL);
>>>>
>>>> @@ -210,16 +211,13 @@ gssd_run()
>>>> 				exit(1);
>>>> 			}
>>>> 		}
>>>> -		/* race condition here: dir_changed could be set before we
>>>> -		 * enter the poll, and we'd never notice if it weren't for the
>>>> -		 * timeout. */
>>>> -		ret = poll(pollarray, pollsize, POLL_MILLISECS);
>>>> +		ret = ppoll(pollarray, pollsize, NULL, &emptyset);
>>>> 		if (ret < 0) {
>>>> 			if (errno != EINTR)
>>>> 				printerr(0,
>>>> 					 "WARNING: error return from poll\n");
>>>> 		} else if (ret == 0) {
>>>> -			/* timeout */
>>>> +			printerr(0, "WARNING: unexpected timeout\n");
>>>> 		} else { /* ret > 0 */
>>>> 			scan_poll_results(ret);
>>>> 		}
>>>> -- 
>>>> 1.7.9.5
>>>>
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
