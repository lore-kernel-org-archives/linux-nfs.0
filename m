Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from milhouse.imppc.org ([213.151.98.37]:51553 "EHLO
	milhouse.imppc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163Ab1COVrv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 17:47:51 -0400
Message-ID: <4D7FE0E8.5050701@imppc.org>
Date: Tue, 15 Mar 2011 22:58:00 +0100
From: Judith Flo Gaya <jflo@imppc.org>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: problem with nfs latency during high IO
References: <4D7B6DE5.8010008@imppc.org> <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com> <4D7FA11F.5020604@imppc.org> <21A84B17-E061-4441-9181-100AC8E473E2@oracle.com> <4D7FDB14.6090908@imppc.org> <9CC4990D-6969-4788-8B52-BA5AF2743DE3@oracle.com>
In-Reply-To: <9CC4990D-6969-4788-8B52-BA5AF2743DE3@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 3/15/11 10:28 PM, Chuck Lever wrote:
>>>>>> Can you help me on this? I'm I wrong in my supposition (is the patch really applied)? is it possible that my problem is somewhere else?
>>>>> This sounds like typical behavior.
>>>> But it is not like this when I use a RHEL6 as a client to those servers, in this case, the ls only last for some seconds, nothing like the minutes that it takes from my fedora.
>>> Which Fedora systems, exactly?  The fix I described below is almost certainly in RHEL 6.
>> Fedora Core 14, 64 bit, 2.6.35.6-45
> Right, you mentioned that in your OP.  Sorry.
no problem
>>>>> POSIX requires that the mtime and file size returned by stat(2) ('ls -l') reflect the most recent write(2).  On NFS, the server sets both of these fields.  If a client is caching dirty data, and an application does a stat(2), the client is forced to flush the dirty data so that the server can update mtime and file size appropriately.  The client then does a GETATTR, and returns those values to the requesting application.
>>>>>
>>>> ok, sorry, I know this is a very stupid question but. what do you mean by dirty data?
>>> Dirty data is data that your application has written to the file but which hasn't been flushed to the server's disk.  This data resides in the client's page cache, on its way to the server.
>> ok, understood. Then the sysctl change that you suggest, I've been checking both distributions, RHEL6 and FC14 and they share the same value... I assume by this that changing this value will not "help", am I right?
> It should improve behavior somewhat in both cases, but the delay won't go away entirely.  This was a workaround we gave EL5 customers before this bug was addressed.  In the Fedora case I wouldn't expect a strongly deterministic improvement, but the average wait for "ls -l" should go down somewhat.
I saw that the value was 20, I don't know the impact of changing the 
number by units or tens... Should I test with 10 or this is too much? I 
assume that the behavior will change immediately right?
j
