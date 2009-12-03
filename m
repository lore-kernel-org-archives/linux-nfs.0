From: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
Subject: Re: rpc.statd problem: lockd: cannot monitor server
Date: Thu, 03 Dec 2009 11:24:42 +0100
Message-ID: <4B1791EA.1050606@bull.net>
References: <4B154EE7.8050700@bull.net>	<98062189-30B8-4AF6-8F6F-4534495230C2@oracle.com>	<4B163FF9.9050700@bull.net> <20091202072928.14b9399c@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:49854 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755534AbZLCK1q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 05:27:46 -0500
In-Reply-To: <20091202072928.14b9399c-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton wrote:
> On Wed, 02 Dec 2009 11:22:49 +0100
> Diego Moreno <Diego.Moreno-Lazaro@bull.net> wrote:
> 
>>
>> Chuck Lever wrote:
>>> On Dec 1, 2009, at 12:14 PM, Diego Moreno wrote:
>>>> Hi guys,
>>>>
>>>> We are having a problem with locks in NFSv3 with Fedora11. I've been 
>>>> searching this problem in the list for a while but I haven't found it.
>>>>
>>>> The problem is in Fedora11, kernel 2.6.29.6-217.2.16.fc11 and 
>>>> nfs-utils-1.1.5-6.fc11
>>>>
>>>> When I try to make two locks with two different process I get the 
>>>> message "No locks available". rpc.statd is running on client and 
>>>> server, also lockd. If I try with just one process I obtain the same 
>>>> result.
>>>>
>>>> I tried to debug with wireshark and I can see client is not trying to 
>>>> make a lock. I also tried to enable NLM debug and I get next messages:
>>>>
>>>> Syslog:
>>>>
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> get host myserver
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> get host myserver
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> nsm_monitor(myserver)
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> get host myserver
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> get host myserver
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> nsm_monitor(myserver)
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> xdr_dec_stat_res status 1 state -1
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern notice kernel lockd: 
>>>> cannot monitor myserver
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> release host myserver
>>>> 1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
>>>> release host myserver
>>>> 1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd 
>>>> creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or directory
>>>> 1259574201 2009 Nov 30 10:43:21 myclient daemon notice rpc.statd 
>>>> STAT_FAIL to myclient for SM_MON of 10.0.4.60
>>>> 1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd 
>>>> creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or directory
>>> Statd can't create the monitor record for this remote peer for some 
>>> reason.  Check that /var/lib/nfs/statd and /var/lib/nfs/statd/sm exist, 
>>> and are permitted so that rpc.statd can create files in it.  Check which 
>>> uid and gid statd is running under: I think F11 uses 29 for both.
>>>
>> Thanks Chuck. That made the trick. Directory /var/lib/nfs/statd/ was 
>> empty in client and server. Adding these directories locking works. But 
>> it's just a workaround as I have 30 more clients having the same 
>> problem. I'm going to try to find out why this is happening. Maybe it is 
>> a bug in fedora installation? When are supposed the files under 
>> "/var/lib/nfs/statd/" to be created?
>>
>> statd is running under the right uid and gid and /var/lib/nfs/statd is 
>> owned by rpcuser as it should be.
>>
> 
> Sounds like a packaging bug, but when I look at CVS for that nfs-utils
> version it looks ok:
> 
> %files
> 
> [...]
> 
> %dir %attr(700,rpcuser,rpcuser) /var/lib/nfs/statd
> %dir %attr(700,rpcuser,rpcuser) /var/lib/nfs/statd/sm
> %dir %attr(700,rpcuser,rpcuser) /var/lib/nfs/statd/sm.bak
> 
> ...if you uninstall and reinstall the nfs-utils package on one of these
> hosts, do these directories get put in place correctly?
> 

That's right Jeff. Uninstalling and reinstalling nfs-utils everything 
worked fine and now statd files are there with locks working as they should.

Thanks!

