Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:52200 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab1COWKu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 18:10:50 -0400
Subject: Re: problem with nfs latency during high IO
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D7FE0E8.5050701@imppc.org>
Date: Tue, 15 Mar 2011 18:10:37 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <16BF52F0-4D1A-4B68-ADEE-DC70255A139C@oracle.com>
References: <4D7B6DE5.8010008@imppc.org> <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com> <4D7FA11F.5020604@imppc.org> <21A84B17-E061-4441-9181-100AC8E473E2@oracle.com> <4D7FDB14.6090908@imppc.org> <9CC4990D-6969-4788-8B52-BA5AF2743DE3@oracle.com> <4D7FE0E8.5050701@imppc.org>
To: Judith Flo Gaya <jflo@imppc.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 15, 2011, at 5:58 PM, Judith Flo Gaya wrote:

> 
> 
> On 3/15/11 10:28 PM, Chuck Lever wrote:
>> 
>>>>>> POSIX requires that the mtime and file size returned by stat(2) ('ls -l') reflect the most recent write(2).  On NFS, the server sets both of these fields.  If a client is caching dirty data, and an application does a stat(2), the client is forced to flush the dirty data so that the server can update mtime and file size appropriately.  The client then does a GETATTR, and returns those values to the requesting application.
>>>>>> 
>>>>> ok, sorry, I know this is a very stupid question but. what do you mean by dirty data?
>>>> Dirty data is data that your application has written to the file but which hasn't been flushed to the server's disk.  This data resides in the client's page cache, on its way to the server.
>>> ok, understood. Then the sysctl change that you suggest, I've been checking both distributions, RHEL6 and FC14 and they share the same value... I assume by this that changing this value will not "help", am I right?
>> It should improve behavior somewhat in both cases, but the delay won't go away entirely.  This was a workaround we gave EL5 customers before this bug was addressed.  In the Fedora case I wouldn't expect a strongly deterministic improvement, but the average wait for "ls -l" should go down somewhat.
> I saw that the value was 20, I don't know the impact of changing the number by units or tens... Should I test with 10 or this is too much? I assume that the behavior will change immediately right?

I believe the dirty ratio is the percentage of physical memory that can be consumed by one file's dirty data before the VM starts flushing its pages asynchronously.  Or it could be the amount of dirty data allowed across all files... one file or many doesn't make any difference if you are writing a single very large file.

If your client memory is large, a small number should work without problem.  One percent of a 16GB client is still quite a bit of memory.  The current setting means you can have 20% of said 16GB client, or 3.2GB, of dirty file data on that client before it will even think about flushing it.  Along comes "ls -l" and you will have to wait for the client to flush 3.2GB before it can send the GETATTR.

I believe this setting does take effect immediately, but you will have to put the setting in /etc/sysctl.conf to make it last across a reboot.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




