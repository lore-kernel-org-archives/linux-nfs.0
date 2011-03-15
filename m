Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22143 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756765Ab1COV2e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 17:28:34 -0400
Subject: Re: problem with nfs latency during high IO
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D7FDB14.6090908@imppc.org>
Date: Tue, 15 Mar 2011 17:28:20 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <9CC4990D-6969-4788-8B52-BA5AF2743DE3@oracle.com>
References: <4D7B6DE5.8010008@imppc.org> <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com> <4D7FA11F.5020604@imppc.org> <21A84B17-E061-4441-9181-100AC8E473E2@oracle.com> <4D7FDB14.6090908@imppc.org>
To: Judith Flo Gaya <jflo@imppc.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 15, 2011, at 5:33 PM, Judith Flo Gaya wrote:

> 
> 
> On 3/15/11 7:03 PM, Chuck Lever wrote:
>> On Mar 15, 2011, at 1:25 PM, Judith Flo Gaya wrote:
>> 
>>> Hello Chuck,
>>> 
>>> On 03/15/2011 05:24 PM, Chuck Lever wrote:
>>>> Hi Judith-
>>>> 
>>>> On Mar 12, 2011, at 7:58 AM, Judith Flo Gaya wrote:
>>>> 
>>>>> Hello,
>>>>> 
>>>>> I was told some days ago that my problem with my NFS system is related to this bug, as the problem that I'm experiencing is quite similar.
>>>>> 
>>>>> The bug : https://bugzilla.redhat.com/show_bug.cgi?id=469848
>>>>> 
>>>>> The link itself explains quite well my issue, I'm just truing to copy a big file (36Gb) to my nfs server and when I try to get an ls -l command to the same folder where I'm copying data, the command gets stuck for some time. This amount of time changes from a few secs to SOME minutes (9' is the current record).
>>>>> I can live with some seconds of delay, but minutes is something quite unacceptable.
>>>>> 
>>>>> As this is an nfs server running on a red hat system (an HP ibrix x9300 with Red Hat 5.3 x86_64, kernel 2.6.18-128) I was told to apply the patch suggested from the bug on my clients.
>>>>> 
>>>>> Unfortunately my clients are running fedora core 14 (x86_64, kernel 2.6.35.6-45) and I can't find the file that they are referring to, the file fs/nfs/inode.c is not there and I can't find the rpm that contains it.
>>>>> 
>>>>> As the bug is a very very old one, I took it for granted that is already applied to fedora, but I wanted to make sure that it is looking at the file.
>>>>> 
>>>>> Can you help me on this? I'm I wrong in my supposition (is the patch really applied)? is it possible that my problem is somewhere else?
>>>> This sounds like typical behavior.
>>> But it is not like this when I use a RHEL6 as a client to those servers, in this case, the ls only last for some seconds, nothing like the minutes that it takes from my fedora.
>> Which Fedora systems, exactly?  The fix I described below is almost certainly in RHEL 6.
> Fedora Core 14, 64 bit, 2.6.35.6-45

Right, you mentioned that in your OP.  Sorry.

>>>> POSIX requires that the mtime and file size returned by stat(2) ('ls -l') reflect the most recent write(2).  On NFS, the server sets both of these fields.  If a client is caching dirty data, and an application does a stat(2), the client is forced to flush the dirty data so that the server can update mtime and file size appropriately.  The client then does a GETATTR, and returns those values to the requesting application.
>>>> 
>>> ok, sorry, I know this is a very stupid question but. what do you mean by dirty data?
>> Dirty data is data that your application has written to the file but which hasn't been flushed to the server's disk.  This data resides in the client's page cache, on its way to the server.
> ok, understood. Then the sysctl change that you suggest, I've been checking both distributions, RHEL6 and FC14 and they share the same value... I assume by this that changing this value will not "help", am I right?

It should improve behavior somewhat in both cases, but the delay won't go away entirely.  This was a workaround we gave EL5 customers before this bug was addressed.  In the Fedora case I wouldn't expect a strongly deterministic improvement, but the average wait for "ls -l" should go down somewhat.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




