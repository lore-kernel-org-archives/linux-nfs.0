From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: multiple instances of rpc.statd
Date: Sun, 27 Apr 2008 22:59:11 -0500
Message-ID: <48154B8F.7050301@gmail.com>
References: <200804251531.21035.bs@q-leap.de> <4811E0D7.4070608@gmail.com> <20080425220727.GA9597@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:3157 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761755AbYD1D7O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2008 23:59:14 -0400
Received: by an-out-0708.google.com with SMTP id d31so1176225and.103
        for <linux-nfs@vger.kernel.org>; Sun, 27 Apr 2008 20:59:12 -0700 (PDT)
In-Reply-To: <20080425220727.GA9597@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Apr 25, 2008 at 09:47:03AM -0400, Wendy Cheng wrote:
>   
>> Bernd Schubert wrote:
>>     
>>> Hello,
>>>
>>> on servers with heartbeat managed resources one rather often has the 
>>> situation one exports different directories from different resources.
>>>
>>> It now may happen all resources are running on one host, but they can 
>>> also run from different hosts. The situation gets even more complicated 
>>> if the server is also a nfs client.
>>>
>>> In principle having different nfs resources works fine, only the statd 
>>> state directory is a problem. Or in principle the statd concept at all. 
>>> Actually we would need to have several instances of statd running using 
>>> different directories. These then would have to be migrated from one 
>>> server to the other on resource movement. However, as far I understand 
>>> it, there does not even exist the basic concept for this, doesn't it? 
>>>
>>>   
>>>       
>> The efforts have been attempted (to remedy this issue) and a complete  
>> set of patches have been (kept) submitting for the past two years. The   
>> patch acceptance progress is very slow (I guess people just don't want  
>> to get bothered with cluster issues ?).
>>     
>
> We definitely want to get this all figured out....
>
>   
>> Anyway, the kernel side has the basic infrastructure to handle the  
>> problem (it stores the incoming clients IP address as part of its  
>> book-keeping record) - just a little bit tweak will do the job. However,  
>> the user side statd directory needs to get re-structured. I didn't  
>> publish the user side directory structure script during my last round of  
>> submission. Forking statd into multiple threads do not solve all the  
>> issues. Check out:
>> https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html
>>     
>
> So for basic v2/v3 failover, what remains is some statd -H scripts, and
> some form of grace period control?  Is there anything else we're
> missing?
>
>
>   
The submitted patch set is reasonably complete ... .

There was another thought about statd patches though - mostly because of
the concerns over statd's responsiveness. It depended so much on network
status and clients' participations.  I was hoping NFS V4 would catch up
by the time v2/v3 grace period patches got accepted into mainline
kernel. Ideally the v2/v3 lock reclaiming logic could use (or at least
did a similar implementation) the communication channel established by
v4 servers - that is,

1. Enable grace period as previous submitted patches on secondary server.
2. Drop the locks on primary server (and chained the dropped locks into
a lock-list).
3. Send the lock-list via v4 communication channel (or similar
implementation) from primary server to backup server.
4. Reclaim the lock base on the lock-list on backup server.

In short, it would be nice to replace the existing statd lock reclaiming
logic with the above steps if all possible during active-active
failover. For reboot, on the other hand, should stay same as today's
statd logic without changes.

-- Wendy


