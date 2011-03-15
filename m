Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from milhouse.imppc.org ([213.151.98.37]:51236 "EHLO
	milhouse.imppc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757762Ab1CORZy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 13:25:54 -0400
Message-ID: <4D7FA11F.5020604@imppc.org>
Date: Tue, 15 Mar 2011 18:25:51 +0100
From: Judith Flo Gaya <jflo@imppc.org>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: problem with nfs latency during high IO
References: <4D7B6DE5.8010008@imppc.org> <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com>
In-Reply-To: <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Chuck,

On 03/15/2011 05:24 PM, Chuck Lever wrote:
> Hi Judith-
>
> On Mar 12, 2011, at 7:58 AM, Judith Flo Gaya wrote:
>
>> Hello,
>>
>> I was told some days ago that my problem with my NFS system is related to this bug, as the problem that I'm experiencing is quite similar.
>>
>> The bug : https://bugzilla.redhat.com/show_bug.cgi?id=469848
>>
>> The link itself explains quite well my issue, I'm just truing to copy a big file (36Gb) to my nfs server and when I try to get an ls -l command to the same folder where I'm copying data, the command gets stuck for some time. This amount of time changes from a few secs to SOME minutes (9' is the current record).
>> I can live with some seconds of delay, but minutes is something quite unacceptable.
>>
>> As this is an nfs server running on a red hat system (an HP ibrix x9300 with Red Hat 5.3 x86_64, kernel 2.6.18-128) I was told to apply the patch suggested from the bug on my clients.
>>
>> Unfortunately my clients are running fedora core 14 (x86_64, kernel 2.6.35.6-45) and I can't find the file that they are referring to, the file fs/nfs/inode.c is not there and I can't find the rpm that contains it.
>>
>> As the bug is a very very old one, I took it for granted that is already applied to fedora, but I wanted to make sure that it is looking at the file.
>>
>> Can you help me on this? I'm I wrong in my supposition (is the patch really applied)? is it possible that my problem is somewhere else?
>
> This sounds like typical behavior.
But it is not like this when I use a RHEL6 as a client to those servers, 
in this case, the ls only last for some seconds, nothing like the 
minutes that it takes from my fedora.
>
> POSIX requires that the mtime and file size returned by stat(2) ('ls -l') reflect the most recent write(2).  On NFS, the server sets both of these fields.  If a client is caching dirty data, and an application does a stat(2), the client is forced to flush the dirty data so that the server can update mtime and file size appropriately.  The client then does a GETATTR, and returns those values to the requesting application.
>
ok, sorry, I know this is a very stupid question but. what do you mean 
by dirty data?
BTW i understand the time issue, but again, if the version of the kernel 
that the red hat has installed allows me to get the information soon, 
why a newer kernel in fedora does not?

> The problem is that Linux caches writes aggressively.  That makes flushing before the GETATTR take a long time in some cases.  On some versions of Linux, it could be an indefinite amount of time; recently we added a bit of logic to make the GETATTR code path hold up additional application writes so it would be able to squeeze in the GETATTR to get a consistent snapshot of mtime and size.
>
I thought that the purpose of the patch was specifically to allow the 
client to get the stat(2) info faster than before, so that  this 
aggressive behavior doesn't impact so much the performance of the stat 
petition.
> Another issue is: what if other clients are writing to the file?  Those writes won't be seen on your client, either in the form of data changes or mtime/size updates, until your client's attribute cache times out (or the file is unlocked or closed).
>
I didn't consider it, big issue indeed. Then how is RHEL doing it not to 
have the problem???
> The best you can do for now is to lower the amount of dirty data the client allows to be outstanding, thus reducing the amount of time it takes for a flush to complete.  This is done with a sysctl, I believe "vm.dirty_ratio," and affects all file systems on the client.  Alternately, the client file system in question can be mounted with "sync" to cause writes to go to the server immediately, but that has other significant performance implications.
>
I'll give it a try and let you know how the new tests are doing.
I already considered the sync parameter but of course the performance of 
the copy lowers to unacceptable times (from 6min to 40min)

Thanks,
j
