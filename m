From: Peter Staubach <staubach@redhat.com>
Subject: Re: about NLM/NSM
Date: Mon, 27 Oct 2008 17:20:46 -0400
Message-ID: <490630AE.4000807@redhat.com>
References: <55BA1E9645B3441FA782D9032BDC9288@nrchpcvx1f5w93> <20081027185515.GB23767@fieldses.org> <49061511.4050304@redhat.com> <20081027201323.GA25467@fieldses.org> <49062F3E.6090206@redhat.com> <20081027211740.GC25467@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: hexf <hexiaofeng-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48828 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668AbYJ0VU4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Oct 2008 17:20:56 -0400
In-Reply-To: <20081027211740.GC25467@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Oct 27, 2008 at 05:14:38PM -0400, Peter Staubach wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Mon, Oct 27, 2008 at 03:22:57PM -0400, Peter Staubach wrote:
>>>   
>>>       
>>>> J. Bruce Fields wrote:
>>>>     
>>>>         
>>>>> On Mon, Oct 27, 2008 at 02:49:27PM +0800, hexf wrote:
>>>>>         
>>>>>           
>>>>>> We are using nfsv3. Now we meet a demand. If a client which hold a
>>>>>> lock crash, after it reboot, its statd daemon can notify the nfs
>>>>>> server to release the lock.  But if this client will not reboot for
>>>>>> some reason(or will reboot after a long time), then the lock it
>>>>>> holding will not be released.In nfsv3 and nlmv4,it seems there is no
>>>>>> time-out mechnism for this situation. How would we solve this
>>>>>> question? My colleague advise me to modify the code of NLM/NSM to meet
>>>>>> this demand,but is seems quite a complicated work.Can you give me some
>>>>>> advice?
>>>>>>             
>>>>>>             
>>>>> It might be possible to modify the server so that it dropped all locks
>>>>> from a client it hadn't heard from in a while.  However, nfsv2/v3
>>>>> clients are not required to contact the server regularly while they hold
>>>>> locks.  So you may end up revoking locks held by perfectly good
>>>>> functioning clients.
>>>>>
>>>>> As an ugly workaround, rebooting the server will clear the problem, as
>>>>> it will notify clients to recover their locks on restart, and any dead
>>>>> clients will fail to recover their locks.
>>>>>
>>>>>         
>>>>>           
>>>> Didn't Wendy Cheng submit some patches to implement a
>>>> "clearlocks" sort of functionality?  What happened with
>>>> them?
>>>>     
>>>>         
>>> Yes, but that's motivated by the case of migrating all clients using one
>>> export; so it'll drop all locks held on a single filesystem, or all
>>> locks acquired using a single server (not client!) ip address.
>>>
>>> So if we want some finer-grained interface then that's yet to be
>>> designed.
>>>   
>>>       
>> Sorry, I guess that I was remembering incorrectly.  I was
>> thinking that she was looking for something like the clearlocks
>> functionality so that file systems could be migrated around
>> cleanly.
>>     
>
> That's what she was working on (and we merged), yes.
>
> But it doesn't help clear just the set of locks held by a single client.
>
>   
>> It seems for this situation, we could use this sort of variation.
>>     
>
> I'm losing track of what those two "this"'s refer to!
>   

Sorry -- :-)

For the situation of needing to clear locks belonging to long
dead and not returning clients, we could use a variation of
Wendy's proposal which works using the client IP as the key.

It is a rope with a very large and suspicious looking knot on
the end though...

       ps
