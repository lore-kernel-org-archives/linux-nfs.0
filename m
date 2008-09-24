From: Ric Wheeler <rwheeler@redhat.com>
Subject: Re: NFS and mobile clients - can it work?
Date: Wed, 24 Sep 2008 09:26:53 -0400
Message-ID: <48DA401D.2040804@redhat.com>
References: <18646.58594.377630.950531@notabene.brown> <48D9E9E6.8000706@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34619 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbYIXN05 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 09:26:57 -0400
In-Reply-To: <48D9E9E6.8000706@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Suresh Jayaraman wrote:
> Neil Brown wrote:
>   
>>  Suppose I have a mobile client such as a notebook computer which
>>  changes networks from time to time - e.g. when "docked" it uses a
>>  wired network, but when I "undock" it uses a wireless network.  And
>>  as I move around it might change from one wireless network to
>>  another.
>>     
>
> This is quite a common scenario these days.
>
>   
>>  Is it at all reasonable to expect that I could have an NFS mounted
>>  filesystem that continues to work across all of those changes?
>>     
>
> I think it is reasonable to expect with the changing network paradigm of
> mobile computing. Successful protocols/implementations always have
> adapted themselves to the changing (network) needs :)
>   

The other place to address this is in the networking layer itself. If I 
remember correctly, there is support in IPV6 for "mobile IP" which might 
allow you to do this:

http://www.ietf.org/rfc/rfc2002.txt

I have no idea how much of this made it into working systems,

ric


>   
>>  I think that the only way to get the client to close and re-open the
>>  socket would be to wait for 5 minutes with no IO requests.  But that
>>  would be hard to ensure.  Any attempt to access any file will trigger
>>  a request which will keep retrying which will keep the socket active,
>>  so the client won't close it.... It doesn't seem to work anyway.  The
>>  RPC client appears to try to connect from the same source IP address,
>>  though I haven't checked the code to be sure of this.
>>
>>  Would it be worthwhile/practical to have a 'remount' mount option to
>>  request that the socket be closed and re-opened?
>>     
>
> or better name would be 'reconnect'?
>
>   
>>  If there were any active locks, there is probably nothing useful that
>>  can be done for them.  Unless the client manages to send a NOTIFY to
>>  the server before changing IP address, the server will never drop the
>>  locks.   Maybe "-o remount,reopen" would only work if "-o nolocks"
>>  were in force.  It's not an ideal solution, but it might be better
>>  than the current situations?
>>     
>
> Definitely, it can make mobile clients life easier. And it looks to me
> that all of these can be done at the userspace itself.
>
>   
>>  I'm not sure whether NFSv4 makes this easier or harder.  Can you
>>  continue a client session (SET_CLIENTID) from a different IP address?
>>  Can you change the callback address for a CLIENT once it is created?
>>     
>
> I think 'nolock' and 'nfs4' can't be used together and nfs4 always will
> enable locking.
>
>
> Thanks,
>
>   

