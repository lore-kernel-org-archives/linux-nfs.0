Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail3.conversis.de ([213.203.208.210]:43015 "EHLO
	mail3.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474AbaCCXD5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 18:03:57 -0500
Message-ID: <53150A5B.80501@conversis.de>
Date: Tue, 04 Mar 2014 00:03:55 +0100
From: Dennis Jacobfeuerborn <dennisml@conversis.de>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Temporary hangs when using locking with apache+nfsv4
References: <53141788.9030209@conversis.de> <20140303104315.1f949cb4@tlielax.poochiereds.net>
In-Reply-To: <20140303104315.1f949cb4@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03.03.2014 16:43, Jeff Layton wrote:
> On Mon, 03 Mar 2014 06:47:52 +0100
> Dennis Jacobfeuerborn <dennisml@conversis.de> wrote:
>
>> Hi,
>> I'm experimenting with using NFSv4 as storage for web servers and while
>> regular file access seems to work fine as soon as I bring flock() into
>> play things become more problematic.
>> I've create a tiny test php script that basically opens a file, locks it
>> using flock(), writes that fact into a log file (on a local filesystem),
>> performs a usleep(1000), writes into the log that it is about to unlock
>> the file and finally unlocks it.
>> I invoke that script using ab with a concurrency of 20 for a few
>> thousand requests.
>>
>
> Is all the activity from a single client, or are multiple clients
> contending for the lock?
>

"ab" is a benchmarking tool that simulates multiple clients using 
threads but I invoke only a single instance of it on a single system if 
that matters.

>> The result is that while 99% of the request respond quickly a few
>> request seem to hang for up to 30 seconds. According to the log file
>> they must eventually succeed since I see all expected entries and the
>> locking seems to work as well since all entries are in the expected order.
>>
>> Is it expected that these long delays happen? When I comment the locking
>> function out these hangs disappear.
>> Are there some knobs to tune NFS and make it behave better in these
>> situations?
>>
>
> NFSv4 locking is inherently unfair. If you're doing a blocking lock,
> then the client is expected to poll for it. So, long delays are
> possible if you just happen to be unlucky and keep missing the lock.

That's likely what is happening and I'm going to extend the test script 
with additional logging to verify this.

The script is also deliberately a bit more aggressive to test the 
behavior of the locking because I wanted to test the improved locking 
reliability of NFSv4 vs v3. The real-world test case is a CMS (Typo3) 
that serves pages from a cache but ises lock files when the cached 
version of that pages expires and has to be regenerated to prevent 
multiple processes re-generating the page at the same time.
So in the real-world case there will probably less contention and a few 
seconds between locking and unlocking. Also I have to check if the lock 
used by the CMS is blocking which seems unlikely since that would block 
all parallel request at least for the duration of the rendering of the page.

Regards,
   Dennis

