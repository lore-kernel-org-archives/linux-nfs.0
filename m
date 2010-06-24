Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from newman.cs.indiana.edu ([129.79.247.4]:60545 "EHLO
	newman.cs.indiana.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab0FXWaM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jun 2010 18:30:12 -0400
Message-ID: <4C23CE73.7040006@indiana.edu>
Date: Thu, 24 Jun 2010 17:30:27 -0400
From: Rob Henderson <robh@indiana.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Runaway kernel slab memory usage when user over quota
References: <4C1F7B58.4090802@indiana.edu> <20100624160738.GC17827@fieldses.org>
In-Reply-To: <20100624160738.GC17827@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields wrote:
> (Changed cc to new list.)
> 
> On Mon, Jun 21, 2010 at 10:46:48AM -0400, Rob Henderson wrote:
>> We've been fighting a problem with runaway kernel slab memory usage on our file servers ever since moving from nfsv3 to nfsv4 and think I've finally identified the trigger.  We are using disk quotas and the problem seems to arise when a user (whose home directory is on the nfsv4 server) goes over quota.  I've suspected this was the cause for quite some time but just recently caught things in the act and collected evidence to support this theory.  Here was the scenario for one such incident.
> 
> Thanks for the report.
> 
> What distributions and kernels (client and server side) are involved?

It has always been RHEL5 clients and servers (we are using RHEL5 exclusively so don't have any data for other distros).  We've seen it with every RHEL release kernel since last summer which is when we made the wholesale migration to nfsv4.

>> 1) We have alerts to warn us when the slab usage goes over 650K and I got one such warning.
>> 2) I started monitoring the nfs network traffic and noticed one system hitting the server quite hard.
>> 3) I checked this system and found a user logged in who was over quota.
>> 4) At this point, the slab usage was still rising and was getting dangerously close to 800MB which is when the server dies.
> 
> Could you capture the network traffic while the user over quota is
> attempting file operations?

I *might* have this from some earlier instrumentation we did.  I'll check on that and will definitely get this the next time it happens if I don't have it.

> 
>> 5) I increased the user in question's disk quota and the Slab usage immediately came down to around 600-650MB and stabilized.
>> 6) After a couple days, I noticed that the usage was still hanging in the 600-650MB range which is higher than I like to see.
> 
> How are you measuring slab usage?  Also, does /proc/slabinfo tell you
> which slab specifically is responsible?

I have /proc/meminfo and /proc/slabinfo data.  Here is the data for one 10 minute increment when the problem was happening:

05-18-20:01:52
==============
>From /proc/meminfo
    Slab:           638504 kB
>From /proc/slabinfo
    nfsd4_delegations   4060   4121    596   13    2 : tunables   54   27    8 : slabdata    317    317      0
    nfsd4_stateids    105807 130327     72   53    1 : tunables  120   60    8 : slabdata   2459   2459      0
    nfsd4_files         4606   4949     36  101    1 : tunables  120   60    8 : slabdata     49     49      0
    nfsd4_stateowners 841522 841522    344   11    1 : tunables   54   27    8 : slabdata  76502  76502      0


05-18-20:11:52
==============
>From /proc/meminfo
    Slab:           677036 kB
>From /proc/slabinfo
    nfsd4_delegations   4085   4121    596   13    2 : tunables   54   27    8 : slabdata    317    317      0
    nfsd4_stateids    105889 130327     72   53    1 : tunables  120   60    8 : slabdata   2459   2459    324
    nfsd4_files         4673   4949     36  101    1 : tunables  120   60    8 : slabdata     49     49      0
    nfsd4_stateowners 938910 939037    344   11    1 : tunables   54   27    8 : slabdata  85367  85367    129

> 
>> 7) I rebooted the workstation that the over quota user was still logged into and the usage *immediately* dropped to the 450MB range.
>>
>>
>> Since this time, there have been two other times when the slab usage started to rise quickly and in both cases I was able to head off any problems by getting the offending user under quota.
>>
>> Here are some other random notes:
>>
>>  - During these incidents, if nothing is done the server will typically go from a slab usage of 600MB to 800MB (and crash) in a timeframe of about an hour.
>>  - We are running RHEL5 with all updates on all servers and clients.
>>  - The servers in question are running 32bit kernels.  We are looking at upgrading to 64bit as a stop-gap measure.
>>  - We never saw this behavior in the many years we were using nfsv3.  We've been using nfsv4 for about a year now and started experiencing this behavior shortly after the migration.
> 
> I'm working just 3 days between vacations and may not get to this
> promptly.
> 
> Might also be worth attempting to find a small test case that will
> reproduce the same behavior.

I haven't tried to reproduce the problem but it is certainly possible that I could set up a testbed to do this.  I'll work on this.


> 
> Off-hand one explanation might be a memory leak on an error path
> somewhere--presumably an error path that's only hit in frequently in the
> case when some operation fails due to a quota being exceeded.  I don't
> know what operation that would be, though.

Nor do I but if I had to guess, I'd say it is somehow related to something firefox is doing.  No real reason for saying this, but I've just seen other odd behavior related to the way firefox (and thunderbird) seem to be doing sqlite3 file locking.  I also know that in at least one case when this happened, the user who was over quota was just browsing the web using firefox at the time.

Thanks!

   --Rob
