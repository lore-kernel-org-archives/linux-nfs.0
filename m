Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mls01.adon.li ([80.248.193.146]:45589 "EHLO mls01.adon.li"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055Ab1INAHO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 20:07:14 -0400
Message-ID: <4E6FE4D1.20209@web.de>
Date: Wed, 14 Sep 2011 01:18:41 +0200
From: supertimothy <supertimothy@web.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 and gracetime / leasetime grace_period
References: <000801cc71f9$9cc45650$d64d02f0$@web.de> <20110913124440.GA22118@fieldses.org>
In-Reply-To: <20110913124440.GA22118@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Am 13.09.2011 14:44, schrieb J. Bruce Fields:
> On Tue, Sep 13, 2011 at 11:43:37AM +0200, Tim wrote:
>> But how does the notification of clients work with nfsv4?
> There is no notification.  Clients poll the server regularly, and that's
> how they find out there's been a reboot.
>
Ah polling, that explains a lot.
>> The problem I can see is the same as described here:
>> http://www.digipedia.pl/usenet/thread/18978/22974/
>>
>> So we have different values:
>>
>> /proc/fs/nfsd/nfsv4gracetime
>> /proc/fs/nfsd/nfsv4leasetime
>> /proc/sys/fs/nfs/nlm_grace_period
>>
>> If I set graceteime and grace_period to a low value, I get a faster
>> failover. But what do they stand for and do I need nfsv4leasetime to ?
>> If I set them all to 10 seconds, could that be "dangerous" (assume the
>> server can handle the additional load)?
> It's probably OK.  The clients will have to send an rpc to the server at
> least every 10 seconds, or they lose their state.  So if there's a
> chance they wouldn't be able to get through for 10 seconds, you could
> have a problem.
Thanks for clarifying this! I brought the time down to about 15 secs in 
failover situation, that is really OK for me.
>> I guess there isnt an easy way to delete all the locks on serverside and
>> explicitely tell the clients: Hey, the server has rebooted, please get a new
>> lock for all your files :-)
>> I just would like to make failover a bit faster.
> We do need to think about how to make that faster, but that wouldn't be
> the solution.  The problem is that the new server needs to wait before
> granting any new locks or opens until it knows all the clients have had
> the chance to reclaim their old ones.  The only way the server currently
> hsa to do that is to wait out the grace period (== the previous server's
> lease time).

Thanks a lot for your answer Bruce!

Some more questions here - I try to unterstand this and I am a bit 
struggling with RFC3530. I'd be glad if you/someone could tell me if I'm 
wrong..

/proc/fs/nfsd/nfsv4leasetime
The server gives out leases that are valid for this time. The client has 
to renew its lease until nfsv4leasetime times out or the server will 
release the concerning lock.

/proc/fs/nfsd/nfsv4gracetime
After a failover (or reboot), the other server starts. As soon as it is 
up and running, the grace period starts during which no client is 
allowed to write or get a new lock. The time should be chosen so that 
all open locks can be renewed which should be possible whithin 
nfsv4leasetime, because the client has to send a RENEW until 
nfsv4leasetime is over. Thats why leasetime should be smaller than 
gracetime.
Lets say the server needs longer than leasetime to boot. Is the 
leasetime pronlonged until the client gets a signal and then sends a 
RENEW or is it just invalid and the server has to drop the locks after 
gracetime?

/proc/sys/fs/nfs/nlm_grace_period
This is the part I don't understand what it is for. I read it has to be 
shrunk too (I set it to 10 - which works). Standard value is 0.

Thanks!
Tim
