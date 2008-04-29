From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: multiple instances of rpc.statd
Date: Tue, 29 Apr 2008 12:20:56 -0400
Message-ID: <20080429162056.GB20420@fieldses.org>
References: <200804251531.21035.bs@q-leap.de> <4811E0D7.4070608@gmail.com> <20080425220727.GA9597@fieldses.org> <48154B8F.7050301@gmail.com> <20080428182612.GC22037@fieldses.org> <48162340.6060509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34215 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441AbYD2QU6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2008 12:20:58 -0400
In-Reply-To: <48162340.6060509@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 28, 2008 at 03:19:28PM -0400, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> On Sun, Apr 27, 2008 at 10:59:11PM -0500, Wendy Cheng wrote:
>>   
>>>
>>>> So for basic v2/v3 failover, what remains is some statd -H scripts, and
>>>> some form of grace period control?  Is there anything else we're
>>>> missing?
>>>>       
>>> The submitted patch set is reasonably complete ... .
>>>
>>> There was another thought about statd patches though - mostly because of
>>> the concerns over statd's responsiveness. It depended so much on network
>>> status and clients' participations.  I was hoping NFS V4 would catch up
>>> by the time v2/v3 grace period patches got accepted into mainline
>>> kernel. Ideally the v2/v3 lock reclaiming logic could use (or at least
>>> did a similar implementation) the communication channel established by
>>> v4 servers - that is,
>>>
>>> 1. Enable grace period as previous submitted patches on secondary server.
>>> 2. Drop the locks on primary server (and chained the dropped locks into
>>> a lock-list).
>>>     
>>
>> What information exactly would be on that lock list?
>>   
>
> Can't believe I get myself into this ... I'm supposed to be a disk  
> firmware person *now* .. Anyway,
>
> Are the lock state finalized in v4 yet ?

You mean, have we figured out what to send across for a transparent
migration?  Somebody did a prototype that I think we set aside for a
while, but I don't recall if it tried to handle truly transparent
migration, or whether it just sent across the v4 equivalent of the statd
data; I'll check.

--b.

> Can we borrow the concepts (and  
> saved lock states) from v4 ? We certainly can define the saved state  
> useful for v3 independent of v4, say client IP, file path, lock range,  
> lock type, and user id ? Need to re-read linux source to make sure it is  
> doable though.
>
>>   
>>> 3. Send the lock-list via v4 communication channel (or similar
>>> implementation) from primary server to backup server.
>>> 4. Reclaim the lock base on the lock-list on backup server.
>>>     
>>
>> So at this step it's the server itself reclaiming those locks, and
>> you're talking about a completely transparent migration that doesn't
>> look to the client like a reboot?
>>   
>
> Yes, that's the idea .. never implement any prototype code yet - so not  
> sure how feasible it would be.
>> My feeling has been that that's best done after first making sure we can
>> handle the case where the client reclaims the locks, since the latter is
>> easier, and is likely to involve at least some of the same work.  I
>> could be wrong.
>>   
>
> Makes sense .. so the steps taken may be:
>
> 1. Push the patch sets that we originally submitted. This is to make  
> sure we have something working.
> 2. Prototype the new logic, parallel with v4 development, observe and  
> learn the results from step 1 based on user feedbacks.
> 3. Integrate the new logic, if it turns out to be good.
>
>> Exactly which data has to be transferred from the old server to the new?
>> (Lock types, ranges, fh's, owners, and pid's, for established locks; do
>> we also need to hand off blocking locks?  Statd data still needs to be
>> transferred.  Ideally rpc reply caches.  What else?)
>>   
>
> All statd has is the client network addresses (that is already part of  
> current NLM states anyway). Yes, rpc reply cache is important (and  
> that's exactly the motivation for this thread of discussion). Eventually  
> the rpc reply cache needs to get transferred. As long as the  
> communication channel is established, there is no reason for lock states  
> not taking this advantages.
>
>>   
>>> In short, it would be nice to replace the existing statd lock reclaiming
>>> logic with the above steps if all possible during active-active
>>> failover. For reboot, on the other hand, should stay same as today's
>>> statd logic without changes.
>>>     
>
> As mentioned before, cluster issues are not trivial. Take one step at a  
> time .. So the next task we should be focusing may be the grace period  
> patch. Will see what I can do to help out here.
>
> -- Wendy
>
