Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:29457 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab2GaWaA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2012 18:30:00 -0400
Subject: Re: [PATCH 4/4] rpc.gssd: don't call poll() twice a second.
Mime-Version: 1.0 (Apple Message framework v1280)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120731212744.GC1826@pad.fieldses.org>
Date: Tue, 31 Jul 2012 15:29:51 -0700
Cc: Steve Dickson <SteveD@redhat.com>, Jim Rees <rees@umich.edu>,
        linux-nfs@vger.kernel.org
Message-Id: <844B5000-C257-4EB9-84D7-F6961A8A9F6C@oracle.com>
References: <20120731205931.GA32161@fieldses.org> <1343768449-32205-4-git-send-email-bfields@redhat.com> <9C74193E-FB49-48C3-A828-50EDE37C95AD@oracle.com> <20120731212744.GC1826@pad.fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 31, 2012, at 2:27 PM, J. Bruce Fields wrote:

> On Tue, Jul 31, 2012 at 02:23:36PM -0700, Chuck Lever wrote:
>> 
>> On Jul 31, 2012, at 2:00 PM, J. Bruce Fields wrote:
>> 
>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>> 
>>> Use ppoll instead.
>>> 
>>> (This breaks compatibility with kernels before 2.6.16 and glibc before
>>> 2.4).
>> 
>> I think I prefer seeing this wrapped with some autoconf machinery to allow nfs-utils to continue to build on earlier systems.
> 
> I was assuming we could drop support for older systems.

We went to a lot of trouble to get the IPv6 stuff to build correctly on older systems, and we still heard complaints.

> If not, then'd I'd much prefer to go back to the self-pipe trick than to
> deal with autoconf and  ifdef'ing out all this stuff.

This patch is a tiny change.  I don't think autoconf in this case is onerous.  I'm happy to help you with it.

> --b.
> 
>> 
>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>> ---
>>> utils/gssd/gssd_main_loop.c |   12 +++++-------
>>> 1 file changed, 5 insertions(+), 7 deletions(-)
>>> 
>>> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
>>> index 142c8c5..2d20fa2 100644
>>> --- a/utils/gssd/gssd_main_loop.c
>>> +++ b/utils/gssd/gssd_main_loop.c
>>> @@ -186,13 +186,14 @@ gssd_run()
>>> 	struct sigaction	dn_act = {
>>> 		.sa_handler = dir_notify_handler
>>> 	};
>>> -	sigset_t		set;
>>> +	sigset_t		set, emptyset;
>>> 
>>> 	sigemptyset(&dn_act.sa_mask);
>>> 	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
>>> 
>>> -	/* just in case the signal is blocked... */
>>> +	sigemptyset(&emptyset);
>>> 	sigemptyset(&set);
>>> +	/* just in case the signal is blocked... */
>>> 	sigaddset(&set, DNOTIFY_SIGNAL);
>>> 	sigprocmask(SIG_UNBLOCK, &set, NULL);
>>> 
>>> @@ -210,16 +211,13 @@ gssd_run()
>>> 				exit(1);
>>> 			}
>>> 		}
>>> -		/* race condition here: dir_changed could be set before we
>>> -		 * enter the poll, and we'd never notice if it weren't for the
>>> -		 * timeout. */
>>> -		ret = poll(pollarray, pollsize, POLL_MILLISECS);
>>> +		ret = ppoll(pollarray, pollsize, NULL, &emptyset);
>>> 		if (ret < 0) {
>>> 			if (errno != EINTR)
>>> 				printerr(0,
>>> 					 "WARNING: error return from poll\n");
>>> 		} else if (ret == 0) {
>>> -			/* timeout */
>>> +			printerr(0, "WARNING: unexpected timeout\n");
>>> 		} else { /* ret > 0 */
>>> 			scan_poll_results(ret);
>>> 		}
>>> -- 
>>> 1.7.9.5
>>> 
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



